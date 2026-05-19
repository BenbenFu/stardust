/*
 * FAT32FS - FAT32 读写文件系统
 * 支持日记文件的读取和写入
 */
#ifndef FAT32FS_H
#define FAT32FS_H

#include <Arduino.h>
#include "SDDriver.h"

// 最多缓存的文件名数量
#define MAX_DIR_ENTRIES 100

class FAT32FS {
public:
  bool begin(SDDriver* sd);

  // Initialize FAT tables (called by begin)
  bool initFAT();

  // === 写入 ===
  bool writeFile(const char* name8, const char* ext3,
                 const char* data, uint16_t len);
  bool writeDiary(const char* date8, const char* content, uint16_t len);
  bool fileExists(const char* name8, const char* ext3);

  // === 读取（新增） ===
  // 读取文件内容到缓冲区，返回实际读取的字节数
  uint16_t readFile(const char* name8, const char* ext3,
                    char* buf, uint16_t maxLen);
  // 读取日记文件
  uint16_t readDiary(const char* date8, char* buf, uint16_t maxLen);

  // === 目录遍历 ===
  // 获取日记文件列表（按名称升序）
  int listDiaries(char names[][13], int maxCount);
  // 获取日记总数
  int getDiaryCount();

  // === 调试 ===
  void debugDumpFAT(uint32_t firstCluster, uint32_t count) { dumpFATSummary(firstCluster, count); }
  void debugCompareFAT(uint32_t firstCluster, uint32_t count) { compareFATMirrors(firstCluster, count); }

  // === 访问器 ===
  uint32_t getPartStart() const { return partStart; }
  uint32_t getAbsData()   const { return absData; }
  uint32_t getAbsFAT1()   const { return absFAT1; }
  uint32_t getAbsFAT2()   const { return absFAT2; }

private:
  SDDriver* sd = nullptr;

  uint32_t partStart = 0;
  uint16_t rsvdSecCnt = 0;
  uint32_t fatSz32 = 0;
  uint8_t  secPerClus = 0;
  uint8_t  numFATs = 0;
  uint32_t totalSec = 0;
  uint32_t rootClus = 2;
  uint32_t totalClusters = 0;
  uint32_t allocStartCluster = 256;

  uint32_t absFAT1 = 0;
  uint32_t absFAT2 = 0;
  uint32_t absData = 0;

  // 目录条目缓存
  char cachedNames[MAX_DIR_ENTRIES][13];
  int cachedCount = 0;
  bool cacheValid = false;

  bool parseMBR();
  bool parseDBR();
  uint32_t readFATEntry(uint32_t cluster);
  bool writeFATEntry(uint32_t cluster, uint32_t value);
  uint32_t clusterToSector(uint32_t cluster);
  uint32_t readFATEntryFrom(uint32_t fatBase, uint32_t cluster);
  void compareFATMirrors(uint32_t firstCluster, uint32_t count);
  bool checkFATHeader();
  uint32_t findFreeCluster();
  void dumpFATSummary(uint32_t firstCluster, uint32_t count);
  bool verifyFile(uint32_t dirSector, int dirSlot, uint32_t firstCluster, uint32_t size);
  
  // 新增：目录读取辅助
  bool findFile(const char* name8, const char* ext3, 
               uint32_t& outCluster, uint32_t& outSize);
  void invalidateCache();
  void refreshCache();
  
  // FSInfo 扇区支持
  bool readFSInfo();
  bool writeFSInfo();
  void updateFSInfoAfterAlloc(uint32_t cluster);
  
  // FSInfo 扇区支持
  uint32_t fsInfoSectorRel = 1;  // DBR中记录的FSInfo相对扇区号，默认为1
  uint32_t fsFreeCount = 0xFFFFFFFF;  // FSI_Free_Count，0xFFFFFFFF表示未知
  uint32_t fsNextFree = 0xFFFFFFFF;   // FSI_Nxt_Free，0xFFFFFFFF表示未知

  // 清理写入失败后的资源
  void cleanupFailedWrite(uint32_t cluster, uint32_t slotSector, int slot);
};

#endif
