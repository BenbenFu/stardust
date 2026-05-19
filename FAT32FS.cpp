/*
 * FAT32FS - small FAT32 writer used by the diary sync prototype.
 */
#include "FAT32FS.h"
#include <string.h>

bool FAT32FS::begin(SDDriver* driver) {
  sd = driver;
  cacheValid = false;
  cachedCount = 0;

  Serial.println("  parseMBR...");
  if (!parseMBR()) {
    Serial.println("ERR: MBR parse failed");
    return false;
  }

  Serial.println("  parseDBR...");
  if (!parseDBR()) {
    Serial.println("ERR: DBR parse failed");
    return false;
  }

  absFAT1 = partStart + rsvdSecCnt;
  absFAT2 = absFAT1 + fatSz32;
  absData = absFAT2 + fatSz32;

  Serial.printf("FAT32: FAT1=%lu FAT2=%lu DATA=%lu\n", absFAT1, absFAT2, absData);

  // After a failed write/abort, the SD card may need time to settle its internal
  // state. Wait for card ready before reading FAT.
  Serial.println("  Waiting for SD card to settle...");
  sd->waitCardReady(1000);

  // Initialize FAT tables (critical for fresh filesystem)
  Serial.println("  initFAT...");
  if (!initFAT()) {
    Serial.println("ERR: FAT init failed");
    return false;
  }

  Serial.println("OK: FAT32 ready");
  dumpFATSummary(0, 140);
  compareFATMirrors(0, 260);
  readFSInfo();
  return true;
}

// Initialize FAT tables with proper EOC markers
// OPTIMIZED: Only initialize critical entries, skip bulk zeroing
// (unallocated FAT entries are already 0x00000000 after format)
bool FAT32FS::initFAT() {
  // FAT32 requires special handling for first 3 entries:
  // FAT[0] = 0x0FFFFFF8 (media descriptor + end of cluster chain)
  // FAT[1] = 0x0FFFFFFF (end of root cluster chain)
  // FAT[rootClus] = 0x0FFFFFFF (end of root directory cluster chain)
  // All other entries = 0x00000000 (free cluster) - already 0 after format

  uint8_t fatBuf[512];
  bool needsInit = false;

  // Check if FAT already has correct magic values (FAT[0] = 0x0FFFFFF8)
  if (!sd->readSector(absFAT1, fatBuf)) return false;
  if (!(fatBuf[0] == 0xF8 && fatBuf[1] == 0xFF && 
        fatBuf[2] == 0xFF && fatBuf[3] == 0xFF)) {
    needsInit = true;
  }

  // Also check FAT[1] and root cluster entry
  if (!needsInit) {
    uint32_t fat1 = fatBuf[4] | (fatBuf[5] << 8) | (fatBuf[6] << 16) | (fatBuf[7] << 24);
    if ((fat1 & 0x0FFFFFFF) != 0x0FFFFFFF) {
      needsInit = true;
    }
  }

  if (!needsInit) {
    // Quick check: verify root cluster entry is also correct
    uint32_t rootOff = rootClus * 4;
    uint32_t rootSecOff = rootOff / 512;
    uint32_t rootOffInSec = rootOff % 512;
    if (rootSecOff > 0) {
      if (!sd->readSector(absFAT1 + rootSecOff, fatBuf)) return false;
    }
    uint32_t rootEntry = (fatBuf[rootOffInSec] | (fatBuf[rootOffInSec + 1] << 8) |
                          (fatBuf[rootOffInSec + 2] << 16) | (fatBuf[rootOffInSec + 3] << 24)) & 0x0FFFFFFF;
    if (rootEntry != 0x0FFFFFFF) {
      needsInit = true;
    }
  }

  if (!needsInit) {
    Serial.println("  FAT already valid, skipping init...");
    return true;
  }

  // Only need to fix up 3 critical FAT entries, not the whole table
  Serial.println("  FAT needs init, fixing critical entries...");

  // FAT[0] and FAT[1] are in sector 0 of FAT1/FAT2
  memset(fatBuf, 0, 512);
  fatBuf[0] = 0xF8; fatBuf[1] = 0xFF; fatBuf[2] = 0xFF; fatBuf[3] = 0xFF;
  fatBuf[4] = 0xFF; fatBuf[5] = 0xFF; fatBuf[6] = 0xFF; fatBuf[7] = 0x0F;
  if (!sd->writeSector(absFAT1, fatBuf)) return false;
  if (!sd->writeSector(absFAT2, fatBuf)) {
    // FAT2 may be in an inconsistent state due to prior aborted writes.
    // FAT1 is valid, so the filesystem can still work (FAT2 is mirror only).
    // The next sync will attempt to write FAT2 entries again.
    Serial.println("WARN: FAT2 sector 0 write failed during init (transient flash state?)");
    Serial.println("WARN: continuing with FAT1 only. Recommend reformat card if this persists.");
  } else {
    Serial.printf("    FAT[0-1] written to FAT1 and FAT2\n");
  }

  // FAT[rootClus] - set root directory cluster as EOC
  uint32_t rootOff = rootClus * 4;
  uint32_t rootSec = absFAT1 + rootOff / 512;
  uint32_t rootOffInSec = rootOff % 512;
  if (!sd->readSector(rootSec, fatBuf)) return false;
  fatBuf[rootOffInSec] = 0xFF;
  fatBuf[rootOffInSec + 1] = 0xFF;
  fatBuf[rootOffInSec + 2] = 0xFF;
  fatBuf[rootOffInSec + 3] = 0x0F;
  if (!sd->writeSector(rootSec, fatBuf)) return false;
  if (!sd->writeSector(absFAT2 + rootOff / 512, fatBuf)) {
    Serial.printf("WARN: FAT[rootClus=%lu] FAT2 write failed during init\n", rootClus);
    Serial.println("WARN: continuing with FAT1 only.");
  } else {
    Serial.printf("    FAT[rootClus=%lu] written to FAT1 and FAT2\n", rootClus);
  }

  Serial.println("  FAT init complete");
  return true;
}

bool FAT32FS::parseMBR() {
  Serial.println("    reading sector 0...");
  if (!sd->readSector(0, sd->secBuf)) return false;
  if (sd->secBuf[510] != 0x55 || sd->secBuf[511] != 0xAA) {
    Serial.println("ERR: Invalid MBR signature");
    return false;
  }

  for (int i = 0; i < 4; i++) {
    int base = 0x1BE + i * 16;
    uint8_t pt = sd->secBuf[base + 4];
    if (pt == 0x0B || pt == 0x0C) {
      partStart = sd->secBuf[base + 8] | (sd->secBuf[base + 9] << 8) |
                  (sd->secBuf[base + 10] << 16) | (sd->secBuf[base + 11] << 24);
      Serial.printf("MBR: part%d type=0x%02X LBA=%lu\n", i, pt, partStart);
      return true;
    }
  }

  Serial.println("ERR: No FAT32 partition found");
  return false;
}

bool FAT32FS::parseDBR() {
  if (!sd->readSector(partStart, sd->secBuf)) return false;

  rsvdSecCnt = sd->secBuf[14] | (sd->secBuf[15] << 8);
  secPerClus = sd->secBuf[13];
  numFATs    = sd->secBuf[16];
  totalSec   = sd->secBuf[32] | (sd->secBuf[33] << 8) |
               (sd->secBuf[34] << 16) | (sd->secBuf[35] << 24);
  fatSz32    = sd->secBuf[36] | (sd->secBuf[37] << 8) |
               (sd->secBuf[38] << 16) | (sd->secBuf[39] << 24);
  rootClus   = sd->secBuf[44] | (sd->secBuf[45] << 8) |
               (sd->secBuf[46] << 16) | (sd->secBuf[47] << 24);

  // Read BPB_FSInfo (offset 0x30): sector number of FSInfo within reserved area
  uint16_t bpbFSInfo = sd->secBuf[48] | (sd->secBuf[49] << 8);
  fsInfoSectorRel = (bpbFSInfo > 0) ? bpbFSInfo : 1;
  Serial.printf("DBR: FSInfo sector (rel)=%u\n", fsInfoSectorRel);

  Serial.printf("DBR: Rsvd=%u FATSz=%lu SPC=%u NF=%u Root=%lu\n",
                rsvdSecCnt, fatSz32, secPerClus, numFATs, rootClus);

  if (secPerClus == 0 || fatSz32 == 0 || numFATs == 0 || rootClus < 2) {
    Serial.println("ERR: Invalid DBR parameters");
    return false;
  }

  uint32_t dataSec = totalSec - (rsvdSecCnt + numFATs * fatSz32);
  totalClusters = dataSec / secPerClus;
  Serial.printf("DBR: TotalSec=%lu DataSec=%lu Clusters=%lu\n",
                totalSec, dataSec, totalClusters);
  return true;
}

uint32_t FAT32FS::clusterToSector(uint32_t cluster) {
  return absData + (cluster - 2) * secPerClus;
}

uint32_t FAT32FS::readFATEntry(uint32_t cluster) {
  return readFATEntryFrom(absFAT1, cluster);
}

uint32_t FAT32FS::readFATEntryFrom(uint32_t fatBase, uint32_t cluster) {
  uint32_t off = cluster * 4;
  uint32_t sec = fatBase + off / 512;
  uint32_t o = off % 512;
  if (!sd->readSector(sec, sd->secBuf)) return 0xFFFFFFFF;
  return (sd->secBuf[o] | (sd->secBuf[o + 1] << 8) |
          (sd->secBuf[o + 2] << 16) | (sd->secBuf[o + 3] << 24)) & 0x0FFFFFFF;
}

bool FAT32FS::writeFATEntry(uint32_t cluster, uint32_t value) {
  uint8_t fatBuf[512];
  uint32_t maxC = totalClusters + 1;
  if (cluster < 2 || cluster > maxC) {
    Serial.printf("ERR: Cluster %lu out of range, max=%lu\n", cluster, maxC);
    return false;
  }

  uint32_t off = cluster * 4;
  uint32_t f1s = absFAT1 + off / 512;
  uint32_t f2s = absFAT2 + off / 512;
  uint32_t o = off % 512;
  value &= 0x0FFFFFFF;

  if (f1s < absFAT1 || f1s >= absFAT1 + fatSz32) return false;
  if (f2s < absFAT2 || f2s >= absFAT2 + fatSz32) return false;

  // Write FAT1
  if (!sd->readSector(f1s, fatBuf)) return false;
  fatBuf[o] = value & 0xFF;
  fatBuf[o + 1] = (value >> 8) & 0xFF;
  fatBuf[o + 2] = (value >> 16) & 0xFF;
  fatBuf[o + 3] = (fatBuf[o + 3] & 0xF0) | ((value >> 24) & 0x0F);
  if (!sd->writeSector(f1s, fatBuf)) return false;
  if (readFATEntry(cluster) != value) {
    Serial.printf("ERR: FAT1 verify fail cluster=%lu\n", cluster);
    return false;
  }

  // Wait for card to finish programming FAT1 before starting FAT2 write.
  // This is critical: the card may still be busy with FAT1 when we try FAT2.
  sd->waitCardReady(500);

  // Write FAT2 (mirror) with retries
  if (!sd->readSector(f2s, fatBuf)) return false;
  fatBuf[o] = value & 0xFF;
  fatBuf[o + 1] = (value >> 8) & 0xFF;
  fatBuf[o + 2] = (value >> 16) & 0xFF;
  fatBuf[o + 3] = (fatBuf[o + 3] & 0xF0) | ((value >> 24) & 0x0F);

  if (!sd->writeSector(f2s, fatBuf)) {
    Serial.printf("ERR: FAT2 write fail cluster=%lu (card may be in bad state)\n", cluster);
    return false;
  }

  // Verify FAT2 - retry if mismatch (card flash may need extra time)
  sd->waitCardReady(500);
  bool fat2Ok = false;
  for (int retry = 0; retry < 3; retry++) {
    if (retry > 0) {
      sd->waitCardReady(500);
    }
    if (!sd->readSector(f2s, fatBuf)) continue;
    uint32_t verify = (fatBuf[o] | (fatBuf[o + 1] << 8) |
                       (fatBuf[o + 2] << 16) | (fatBuf[o + 3] << 24)) & 0x0FFFFFFF;
    if (verify == value) {
      fat2Ok = true;
      break;
    }
    Serial.printf("WARN: FAT2 verify retry %d cluster=%lu wrote=0x%08lX read=0x%08lX\n",
                  retry, cluster, value, verify);
  }
  if (!fat2Ok) {
    Serial.printf("WARN: FAT2 permanently inconsistent cluster=%lu (FAT1 ok, FAT2 may need reformat)\n", cluster);
    // Continue: FAT1 is correct, filesystem can still work (FAT2 is mirror only)
  }

  return true;
}

bool FAT32FS::checkFATHeader() {
  uint32_t fat0 = readFATEntry(0);
  uint32_t fat1 = readFATEntry(1);
  uint32_t fatRoot = readFATEntry(rootClus);

  bool ok0 = (fat0 & 0x0FFFFFF8) == 0x0FFFFFF8;
  bool ok1 = fat1 >= 0x0FFFFFF8;
  bool okRoot = fatRoot >= 0x0FFFFFF8;
  if (!ok0 || !ok1 || !okRoot) {
    Serial.printf("ERR: FAT header damaged FAT0=%08lX FAT1=%08lX FAT[root]=%08lX\n",
                  fat0, fat1, fatRoot);
    return false;
  }
  return true;
}

uint32_t FAT32FS::findFreeCluster() {
  uint32_t maxC = totalClusters + 1;
  for (uint32_t s = 0; s < fatSz32; s++) {
    if (!sd->readSector(absFAT1 + s, sd->secBuf)) return 0;
    for (int i = 0; i < 128; i++) {
      uint32_t c = s * 128 + i;
      if (c > maxC) return 0;
      if (c < allocStartCluster || c == rootClus) continue;

      uint32_t e = (sd->secBuf[i * 4] | (sd->secBuf[i * 4 + 1] << 8) |
                    (sd->secBuf[i * 4 + 2] << 16) | (sd->secBuf[i * 4 + 3] << 24)) & 0x0FFFFFFF;
      
      if (e == 0) return c;  // 空闲簇
      if (e == 0x0FFFFFF7) {
        Serial.printf("WARN: Bad cluster %lu skipped\n", c);
        continue;  // 跳过坏块
      }
    }
  }
  return 0;
}

void FAT32FS::dumpFATSummary(uint32_t firstCluster, uint32_t count) {
  uint32_t freeCount = 0;
  uint32_t usedCount = 0;
  uint32_t eocCount = 0;
  uint32_t badCount = 0;
  uint32_t firstFree = 0;

  Serial.printf("FAT scan: [%lu..%lu]\n", firstCluster, firstCluster + count - 1);
  for (uint32_t c = firstCluster; c < firstCluster + count; c++) {
    uint32_t e = readFATEntry(c);
    if (e == 0) {
      if (firstFree == 0 && c >= 2) firstFree = c;
      freeCount++;
    } else if (e >= 0x0FFFFFF8) {
      eocCount++;
    } else if (e == 0x0FFFFFF7) {
      badCount++;
    } else {
      usedCount++;
    }
  }

  Serial.printf("FAT scan result: free=%lu used=%lu eoc=%lu bad=%lu firstFree=%lu\n",
                freeCount, usedCount, eocCount, badCount, firstFree);

  Serial.println("FAT first entries:");
  for (uint32_t c = firstCluster; c < firstCluster + count; c++) {
    uint32_t e = readFATEntry(c);
    Serial.printf("%lu:%08lX ", c, e);
    if (((c - firstCluster + 1) % 4) == 0) Serial.println();
  }
  Serial.println();
}

void FAT32FS::compareFATMirrors(uint32_t firstCluster, uint32_t count) {
  uint32_t diffCount = 0;
  Serial.printf("FAT mirror compare: [%lu..%lu]\n", firstCluster, firstCluster + count - 1);
  for (uint32_t c = firstCluster; c < firstCluster + count; c++) {
    uint32_t f1 = readFATEntryFrom(absFAT1, c);
    uint32_t f2 = readFATEntryFrom(absFAT2, c);
    if (f1 != f2) {
      if (diffCount < 16) {
        Serial.printf("  DIFF cluster %lu FAT1=%08lX FAT2=%08lX\n", c, f1, f2);
      }
      diffCount++;
    }
  }
  Serial.printf("FAT mirror compare result: diff=%lu\n", diffCount);
}

// ========== FSInfo 扇区支持 ==========
bool FAT32FS::readFSInfo() {
  uint32_t fsiAbs = partStart + fsInfoSectorRel;
  if (!sd->readSector(fsiAbs, sd->secBuf)) {
    Serial.printf("FSInfo: read fail LBA %lu\n", fsiAbs);
    fsFreeCount = 0xFFFFFFFF;
    fsNextFree = 0xFFFFFFFF;
    return false;
  }

  // 检查签名
  uint32_t leadSig = sd->secBuf[0] | (sd->secBuf[1] << 8) |
                     (sd->secBuf[2] << 16) | (sd->secBuf[3] << 24);
  uint32_t strucSig = sd->secBuf[0x1E4] | (sd->secBuf[0x1E5] << 8) |
                      (sd->secBuf[0x1E6] << 16) | (sd->secBuf[0x1E7] << 24);

  if (leadSig != 0x52526141 || strucSig != 0x72724161 ||
      sd->secBuf[0x1FE] != 0x55 || sd->secBuf[0x1FF] != 0xAA) {
    Serial.println("FSInfo: invalid signatures, skipping");
    fsFreeCount = 0xFFFFFFFF;
    fsNextFree = 0xFFFFFFFF;
    return false;
  }

  fsFreeCount = sd->secBuf[0x1E8] | (sd->secBuf[0x1E9] << 8) |
                (sd->secBuf[0x1EA] << 16) | (sd->secBuf[0x1EB] << 24);
  fsNextFree = sd->secBuf[0x1EC] | (sd->secBuf[0x1ED] << 8) |
               (sd->secBuf[0x1EE] << 16) | (sd->secBuf[0x1EF] << 24);

  Serial.printf("FSInfo: free=%lu nextFree=%lu\n",
                 (fsFreeCount == 0xFFFFFFFF) ? 0xFFFFFFFF : fsFreeCount,
                 (fsNextFree == 0xFFFFFFFF) ? 0xFFFFFFFF : fsNextFree);
  return true;
}

bool FAT32FS::writeFSInfo() {
  uint32_t fsiAbs = partStart + fsInfoSectorRel;
  if (!sd->readSector(fsiAbs, sd->secBuf)) {
    Serial.printf("FSInfo: read for write failed LBA %lu\n", fsiAbs);
    return false;
  }

  // 更新 FSI_Free_Count 和 FSI_Nxt_Free
  sd->secBuf[0x1E8] = fsFreeCount & 0xFF;
  sd->secBuf[0x1E9] = (fsFreeCount >> 8) & 0xFF;
  sd->secBuf[0x1EA] = (fsFreeCount >> 16) & 0xFF;
  sd->secBuf[0x1EB] = (fsFreeCount >> 24) & 0xFF;

  sd->secBuf[0x1EC] = fsNextFree & 0xFF;
  sd->secBuf[0x1ED] = (fsNextFree >> 8) & 0xFF;
  sd->secBuf[0x1EE] = (fsNextFree >> 16) & 0xFF;
  sd->secBuf[0x1EF] = (fsNextFree >> 24) & 0xFF;

  if (!sd->writeSector(fsiAbs, sd->secBuf)) {
    Serial.printf("FSInfo: write failed LBA %lu\n", fsiAbs);
    return false;
  }

  Serial.printf("FSInfo: updated free=%lu nextFree=%lu\n",
                 (fsFreeCount == 0xFFFFFFFF) ? 0xFFFFFFFF : fsFreeCount,
                 (fsNextFree == 0xFFFFFFFF) ? 0xFFFFFFFF : fsNextFree);
  return true;
}

void FAT32FS::updateFSInfoAfterAlloc(uint32_t cluster) {
  // 递减空闲簇计数
  if (fsFreeCount != 0xFFFFFFFF && fsFreeCount > 0) {
    fsFreeCount--;
  }

  // 更新下一个建议分配的簇号
  if (cluster + 1 <= totalClusters + 1) {
    fsNextFree = cluster + 1;
  } else {
    fsNextFree = 0xFFFFFFFF;
  }
}

bool FAT32FS::verifyFile(uint32_t dirSector, int dirSlot, uint32_t firstCluster, uint32_t size) {
  uint32_t fatValue = readFATEntry(firstCluster);
  if (fatValue < 0x0FFFFFF8) {
    Serial.printf("ERR: FAT verify fail cluster=%lu value=0x%08lX\n", firstCluster, fatValue);
    return false;
  }

  if (!sd->readSector(dirSector, sd->secBuf)) return false;
  uint8_t* p = &sd->secBuf[dirSlot * 32];
  uint32_t dirCluster = ((uint32_t)p[20] << 16) | ((uint32_t)p[21] << 24) |
                        p[26] | ((uint32_t)p[27] << 8);
  uint32_t dirSize = p[28] | ((uint32_t)p[29] << 8) |
                     ((uint32_t)p[30] << 16) | ((uint32_t)p[31] << 24);
  if (dirCluster != firstCluster || dirSize != size) {
    Serial.printf("ERR: DIR verify fail cluster=%lu/%lu size=%lu/%lu\n",
                  dirCluster, firstCluster, dirSize, size);
    return false;
  }

  Serial.printf("  verify OK: FAT=EOC DIR cluster=%lu size=%lu\n", dirCluster, dirSize);
  return true;
}

void FAT32FS::invalidateCache() {
  cacheValid = false;
}

void FAT32FS::refreshCache() {
  if (cacheValid) return;
  
  cachedCount = 0;
  bool done = false;

  // ★ 修复：跟随 FAT 链遍历根目录所有簇（根目录可以跨多个簇）
  uint32_t curClus = rootClus;
  while (!done && curClus >= 2 && curClus < 0x0FFFFFF8 && cachedCount < MAX_DIR_ENTRIES) {
    uint32_t rootSec = clusterToSector(curClus);

    for (uint32_t s = 0; s < secPerClus && !done && cachedCount < MAX_DIR_ENTRIES; s++) {
      if (!sd->readSector(rootSec + s, sd->secBuf)) { done = true; break; }
      
      for (int i = 0; i < 16 && cachedCount < MAX_DIR_ENTRIES; i++) {
        uint8_t* ent = &sd->secBuf[i * 32];
        uint8_t fb = ent[0];
        
        if (fb == 0x00) { done = true; break; }  // 目录结束
        if (fb == 0xE5) continue;                 // 已删除
        if (ent[11] == 0x0F) continue;            // 长文件名条目
        
        // 检查是否是.TXT文件
        if (ent[8] == 'T' && ent[9] == 'X' && ent[10] == 'T') {
          // ★ 只缓存日记文件，过滤非日记的 .TXT 文件（如 ANSWERS.TXT）
          // 正常格式：8位数字 (e.g. 20260509.TXT) → ent[0..7] 全是数字
          // 诊断格式：T + 6位 + Z (e.g. T260509Z.TXT) → ent[0]=='T' && ent[7]=='Z'
          int digitCount = 0;
          while (digitCount < 8 && ent[digitCount] >= '0' && ent[digitCount] <= '9') digitCount++;
          bool isDiary = (digitCount == 8) || (ent[0] == 'T' && ent[7] == 'Z');

          if (!isDiary) continue;

          // 提取8+3文件名
          char name[13];
          int ni = 0;
          for (int j = 0; j < 8 && ent[j] != ' '; j++) name[ni++] = ent[j];
          name[ni++] = '.';
          for (int j = 8; j < 11 && ent[j] != ' '; j++) name[ni++] = ent[j];
          name[ni] = '\0';
          
          strncpy(cachedNames[cachedCount], name, 12);
          cachedNames[cachedCount][12] = '\0';
          cachedCount++;
        }
      }
    }

    // 跟随 FAT 链到下一个簇
    if (!done) curClus = readFATEntry(curClus);
  }
  
  // 简单排序（冒泡排序）
  for (int i = 0; i < cachedCount - 1; i++) {
    for (int j = 0; j < cachedCount - 1 - i; j++) {
      if (strcmp(cachedNames[j], cachedNames[j + 1]) > 0) {
        char tmp[13];
        strcpy(tmp, cachedNames[j]);
        strcpy(cachedNames[j], cachedNames[j + 1]);
        strcpy(cachedNames[j + 1], tmp);
      }
    }
  }
  
  cacheValid = true;
  Serial.printf("FAT32: cached %d diary files\n", cachedCount);
}

// ★ FAT32 8.3 文件名比较辅助：C 字符串用 \0 结尾，但 FAT32 目录条目用空格(0x20)填充
// 必须将 name/ext 先用空格补齐再 memcmp，否则 "ANSWERS\0" != "ANSWERS "
static void pad83(char* padded8, const char* name) {
  memset(padded8, ' ', 8);
  for (int i = 0; i < 8 && name[i] && name[i] != ' '; i++) padded8[i] = name[i];
}
static void padExt3(char* padded3, const char* ext) {
  memset(padded3, ' ', 3);
  for (int i = 0; i < 3 && ext[i] && ext[i] != ' '; i++) padded3[i] = ext[i];
}

bool FAT32FS::findFile(const char* name8, const char* ext3,
                       uint32_t& outCluster, uint32_t& outSize) {
  // ★ 修复：跟随 FAT 链遍历根目录所有簇（根目录可以跨多个簇）
  char pn[8], pe[3];
  pad83(pn, name8);
  padExt3(pe, ext3);
  uint32_t curClus = rootClus;
  while (curClus >= 2 && curClus < 0x0FFFFFF8) {
    uint32_t rootSec = clusterToSector(curClus);
    for (uint32_t s = 0; s < secPerClus; s++) {
      if (!sd->readSector(rootSec + s, sd->secBuf)) return false;
      for (int i = 0; i < 16; i++) {
        uint8_t* ent = &sd->secBuf[i * 32];
        uint8_t fb = ent[0];
        if (fb == 0x00) return false;  // 目录结束
        if (fb == 0xE5) continue;      // 已删除
        if (ent[11] == 0x0F) continue; // 长文件名
      
        if (memcmp(ent, pn, 8) == 0 && memcmp(ent + 8, pe, 3) == 0) {
          // 找到文件
          outCluster = ((uint32_t)ent[20] << 16) | ((uint32_t)ent[21] << 24) |
                       ent[26] | ((uint32_t)ent[27] << 8);
          outSize = ent[28] | ((uint32_t)ent[29] << 8) |
                   ((uint32_t)ent[30] << 16) | ((uint32_t)ent[31] << 24);
          return true;
        }
      }
    }
    // 跟随 FAT 链到下一个簇
    curClus = readFATEntry(curClus);
  }
  return false;
}

uint16_t FAT32FS::readFile(const char* name8, const char* ext3,
                           char* buf, uint16_t maxLen) {
  uint32_t firstCluster = 0;
  uint32_t fileSize = 0;
  
  if (!findFile(name8, ext3, firstCluster, fileSize)) {
    Serial.printf("FAT32: file %.8s.%.3s not found\n", name8, ext3);
    return 0;
  }
  
  uint16_t toRead = (fileSize < maxLen - 1) ? fileSize : (maxLen - 1);
  uint16_t readBytes = 0;
  
  // 读取文件簇链
  uint32_t currentCluster = firstCluster;
  while (readBytes < toRead) {
    uint32_t sec = clusterToSector(currentCluster);
    
    for (int s = 0; s < secPerClus && readBytes < toRead; s++) {
      if (!sd->readSector(sec + s, (uint8_t*)buf + readBytes)) {
        Serial.printf("FAT32: read error at cluster=%lu sector=%lu\n", 
                      currentCluster, sec + s);
        buf[readBytes] = '\0';
        return readBytes;
      }
      uint16_t chunk = 512;
      if (readBytes + chunk > toRead) {
        chunk = toRead - readBytes;
      }
      readBytes += chunk;
    }
    
    // 获取下一个簇
    currentCluster = readFATEntry(currentCluster);
    if (currentCluster >= 0x0FFFFFF8) {
      break;  // 文件结束
    }
  }
  
  buf[readBytes] = '\0';
  
  // 跳过UTF-8 BOM（如果存在）
  if (readBytes >= 3 && (uint8_t)buf[0] == 0xEF && 
      (uint8_t)buf[1] == 0xBB && (uint8_t)buf[2] == 0xBF) {
    memmove(buf, buf + 3, readBytes - 3 + 1);  // +1 for null terminator
    readBytes -= 3;
  }
  
  Serial.printf("FAT32: read %.8s.%.3s %lu -> %u bytes\n", name8, ext3, fileSize, readBytes);
  return readBytes;
}

uint16_t FAT32FS::readDiary(const char* date8, char* buf, uint16_t maxLen) {
  return readFile(date8, "TXT", buf, maxLen);
}

int FAT32FS::listDiaries(char names[][13], int maxCount) {
  refreshCache();
  
  int count = (cachedCount < maxCount) ? cachedCount : maxCount;
  for (int i = 0; i < count; i++) {
    strncpy(names[i], cachedNames[i], 12);
    names[i][12] = '\0';
  }
  
  return count;
}

int FAT32FS::getDiaryCount() {
  refreshCache();
  return cachedCount;
}

bool FAT32FS::writeFile(const char* name8, const char* ext3,
                        const char* data, uint16_t len) {
  Serial.printf("  writeFile: %.8s.%.3s (%u bytes)\n", name8, ext3, len);

  // DEBUG: dump first 32 bytes of content being written
  Serial.printf("  DEBUG content[0..31]: ");
  for (int i = 0; i < 32 && i < len; i++) {
    Serial.printf("%02X ", (uint8_t)data[i]);
  }
  Serial.println();
  if (len > 32) {
    Serial.printf("  DEBUG content[32..63]: ");
    for (int i = 32; i < 64 && i < len; i++) {
      Serial.printf("%02X ", (uint8_t)data[i]);
    }
    Serial.println();
  }

  // Strip UTF-8 BOM if present (normalize content to avoid write/verify mismatch)
  const char* writeData = data;
  char normBuf[512];
  bool hasBom = (len >= 3 && (uint8_t)data[0] == 0xEF && (uint8_t)data[1] == 0xBB && (uint8_t)data[2] == 0xBF);
  if (hasBom) {
    Serial.printf("  INFO: UTF-8 BOM detected in %u bytes, stripping\n", len);
    if (len - 3 < sizeof(normBuf)) {
      memcpy(normBuf, data + 3, len - 3);
      normBuf[len - 3] = '\0';
      writeData = normBuf;
      len = len - 3;
      Serial.printf("  DEBUG content (after strip)[0..31]: ");
      for (int i = 0; i < 32 && i < len; i++) {
        Serial.printf("%02X ", (uint8_t)writeData[i]);
      }
      Serial.println();
    }
  }

  if (!checkFATHeader()) {
    Serial.println("ERR: abort write because FAT header is not valid");
    return false;
  }

  invalidateCache();  // 使缓存失效

  uint32_t rootSec = clusterToSector(rootClus);
  int emptySlot = -1;
  uint32_t slotSector = 0;
  char pn[8], pe[3];
  pad83(pn, name8);
  padExt3(pe, ext3);

  for (uint32_t s = 0; s < secPerClus; s++) {
    if (!sd->readSector(rootSec + s, sd->secBuf)) return false;
    for (int i = 0; i < 16; i++) {
      uint8_t* ent = &sd->secBuf[i * 32];
      uint8_t fb = ent[0];
      if (fb == 0x00) {
        if (emptySlot < 0) {
          emptySlot = i;
          slotSector = rootSec + s;
        }
        s = secPerClus;
        break;
      }
      if (fb == 0xE5) {
        if (emptySlot < 0) {
          emptySlot = i;
          slotSector = rootSec + s;
        }
        continue;
      }
      if (memcmp(ent, pn, 8) == 0 && memcmp(ent + 8, pe, 3) == 0) {
        Serial.printf("  SKIP: %.8s.%.3s exists\n", name8, ext3);
        return false;
      }
    }
  }

  if (emptySlot < 0) {
    Serial.println("ERR: No dir slot in first root cluster");
    return false;
  }

  uint32_t fc = findFreeCluster();
  if (fc == 0) {
    Serial.println("ERR: Disk full");
    return false;
  }

  uint32_t cSec = clusterToSector(fc);
  uint16_t secSNeeded = (len + 511) / 512;
  if (secSNeeded == 0) secSNeeded = 1;
  if (secSNeeded > secPerClus) {
    Serial.println("ERR: Content > 1 cluster");
    return false;
  }

  for (uint16_t s = 0; s < secSNeeded; s++) {
    memset(sd->secBuf, 0, 512);
    uint16_t off = s * 512;
    uint16_t n = len - off;
    if (n > 512) n = 512;
    memcpy(sd->secBuf, writeData + off, n);
    if (!sd->writeSector(cSec + s, sd->secBuf)) {
      cleanupFailedWrite(fc, slotSector, emptySlot);
      return false;
    }
  }

  if (!writeFATEntry(fc, 0x0FFFFFFF)) {
    cleanupFailedWrite(fc, slotSector, emptySlot);
    return false;
  }

  if (!sd->readSector(slotSector, sd->secBuf)) return false;
  uint8_t* p = &sd->secBuf[emptySlot * 32];
  memset(p, 0, 32);

  memcpy(p, name8, 8);
  memcpy(p + 8, ext3, 3);
  p[11] = 0x20;

  uint16_t fatTime = (12 << 11); // 12:00:00
  uint16_t fatDate = ((2026 - 1980) << 9) | (5 << 5) | 10;
  p[14] = fatTime & 0xFF;       p[15] = (fatTime >> 8) & 0xFF;
  p[16] = fatDate & 0xFF;       p[17] = (fatDate >> 8) & 0xFF;
  p[18] = fatDate & 0xFF;       p[19] = (fatDate >> 8) & 0xFF;
  p[22] = fatTime & 0xFF;       p[23] = (fatTime >> 8) & 0xFF;
  p[24] = fatDate & 0xFF;       p[25] = (fatDate >> 8) & 0xFF;

  p[20] = (fc >> 16) & 0xFF;
  p[21] = (fc >> 24) & 0xFF;
  p[26] = fc & 0xFF;
  p[27] = (fc >> 8) & 0xFF;
  p[28] = len & 0xFF;
  p[29] = (len >> 8) & 0xFF;
  p[30] = (len >> 16) & 0xFF;
  p[31] = (len >> 24) & 0xFF;

  if (!sd->writeSectorRaw(slotSector, sd->secBuf)) {
    cleanupFailedWrite(fc, slotSector, emptySlot);
    return false;
  }
  if (!verifyFile(slotSector, emptySlot, fc, len)) {
    cleanupFailedWrite(fc, slotSector, emptySlot);
    return false;
  }

  // 更新 FSInfo：空闲簇数减1，更新下一个建议分配簇号
  updateFSInfoAfterAlloc(fc);
  if (!writeFSInfo()) {
    Serial.println("WARN: FSInfo write failed (file was written successfully)");
  }

  Serial.printf("  OK: %.8s.%.3s cluster=%lu size=%u\n", name8, ext3, fc, len);
  uint32_t fatWindow = (fc / 128) * 128;
  Serial.printf("  FAT window after write: %lu..%lu\n", fatWindow, fatWindow + 127);
  dumpFATSummary(fatWindow, 128);
  compareFATMirrors(fatWindow, 128);
  return true;
}

bool FAT32FS::fileExists(const char* name8, const char* ext3) {
  char pn[8], pe[3];
  pad83(pn, name8);
  padExt3(pe, ext3);
  uint32_t curClus = rootClus;
  while (curClus >= 2 && curClus < 0x0FFFFFF8) {
    uint32_t rootSec = clusterToSector(curClus);
    for (uint32_t s = 0; s < secPerClus; s++) {
      if (!sd->readSector(rootSec + s, sd->secBuf)) return false;
      for (int i = 0; i < 16; i++) {
        uint8_t* ent = &sd->secBuf[i * 32];
        uint8_t fb = ent[0];
        if (fb == 0x00) return false;
        if (fb == 0xE5) continue;
        if (memcmp(ent, pn, 8) == 0 && memcmp(ent + 8, pe, 3) == 0) {
          return true;
        }
      }
    }
    curClus = readFATEntry(curClus);
  }

  return false;
}

bool FAT32FS::writeDiary(const char* date8, const char* content, uint16_t len) {
  return writeFile(date8, "TXT", content, len);
}

// Clean up resources after a failed write (delete partial file, mark bad cluster)
void FAT32FS::cleanupFailedWrite(uint32_t cluster, uint32_t slotSector, int slot) {
  Serial.printf("  Cleanup: cluster=%lu\n", cluster);  
  
  // 1. Mark directory entry as deleted
  if (sd->readSector(slotSector, sd->secBuf)) {
    sd->secBuf[slot * 32] = 0xE5;
    sd->writeSectorRaw(slotSector, sd->secBuf);
  }  
  
  // 2. Mark this cluster as bad block (so it won't be reallocated)
  uint32_t maxC = totalClusters + 1;
  if (cluster > 1 && cluster <= maxC) {
    Serial.printf("  Cleanup: marking cluster %lu as BAD\n", cluster);
    writeFATEntry(cluster, 0x0FFFFFF7);  // Mark as bad block
  }
  
  Serial.println("  Cleanup: done");
}
