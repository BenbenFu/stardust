/*
 * DiarySync - WiFi + HTTPS + JSON extraction + FAT32 writing.
 */
#include "DiarySync.h"
#include "config.h"
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <Preferences.h>
#include <set>
#include <String.h>

Preferences wifiPrefs;

bool DiarySync::begin(FAT32FS* filesystem) {
  fs = filesystem;

  httpBuf = (char*)ps_malloc(HTTP_BUF_SIZE);
  if (!httpBuf) {
    Serial.println("ERR: HTTP buffer alloc failed");
    return false;
  }
  Serial.printf("OK: HTTP buffer %u KB (PSRAM)\n", HTTP_BUF_SIZE / 1024);
  return true;
}

bool DiarySync::connectWiFi() {
  // 从 Preferences 读取 WiFi 凭据
  wifiPrefs.begin(WIFI_PREF_NS, true);  // 只读模式
  String savedSsid = wifiPrefs.getString(WIFI_PREF_SSID_KEY, "");
  String savedPass = wifiPrefs.getString(WIFI_PREF_PASS_KEY, "");
  wifiPrefs.end();
  
  if (savedSsid.length() == 0) {
    Serial.println("WiFi: No saved credentials found (use BLE to configure)");
    return false;
  }
  
  Serial.printf("WiFi: Loading saved credentials for \"%s\"...\n", savedSsid.c_str());
  
  // 如果已经连接且是同一个 SSID，直接返回成功
  if (WiFi.status() == WL_CONNECTED && WiFi.SSID() == savedSsid) {
    Serial.printf("WiFi: Already connected, IP: %s\n", WiFi.localIP().toString().c_str());
    return true;
  }
  
  // 断开旧连接
  WiFi.disconnect();
  delay(100);
  
  // 连接到保存的 WiFi
  WiFi.begin(savedSsid.c_str(), savedPass.c_str());

  int t = 0;
  while (WiFi.status() != WL_CONNECTED && t < 40) {
    delay(500);
    Serial.print(".");
    t++;
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("OK: WiFi connected! IP %s\n", WiFi.localIP().toString().c_str());
    return true;
  }

  Serial.println("ERR: WiFi connection failed");
  return false;
}

std::set<String> DiarySync::scanExistingDates() {
  std::set<String> dates;

  // listDiaries() will internally refresh cache
  int count = fs->getDiaryCount();
  
  if (count == 0) {
    Serial.println("Found 0 existing entries on SD card");
    return dates;
  }
  
  char names[count][13];
  fs->listDiaries(names, count);
  
  for (int i = 0; i < count; i++) {
    String name = String(names[i]);  // "T260509Z.TXT"
    
    if (name.length() >= 12 && name[0] == 'T') {
      // TYYMMDDX.TXT format -> convert to YYYY-MM-DD
      char year[5] = "20xx";
      year[2] = name[1];
      year[3] = name[2];
      String dateStr = String(year) + "-" + String(name[3]) + String(name[4]) + "-" + String(name[5]) + String(name[6]);
      dates.insert(dateStr);
    } else if (name.length() >= 14) {
      // YYYY-MM-DD.txt format
      String dateStr = name.substring(0, 10);
      dates.insert(dateStr);
    }
  }

  Serial.printf("Found %d existing entries on SD card\n", dates.size());
  return dates;
}

uint32_t DiarySync::fetchDiaries(const char* url) {
  WiFiClientSecure client;
  client.setInsecure();

  Serial.printf("HTTPS -> %s:443\n", SUPABASE_HOST);
  if (!client.connect(SUPABASE_HOST, 443)) {
    Serial.println("ERR: HTTPS connect failed");
    return 0;
  }
  Serial.println("OK: HTTPS connected");

  String path = url;

  client.print("GET " + path + " HTTP/1.1\r\n");
  client.print("Host: " + String(SUPABASE_HOST) + "\r\n");
  client.print("apikey: " + String(SUPABASE_ANON_KEY) + "\r\n");
  client.print("Authorization: Bearer " + String(SUPABASE_ANON_KEY) + "\r\n");
  client.print("Accept: application/json\r\n");
  client.print("Connection: close\r\n\r\n");

  bool isChunked = false;
  uint32_t contentLength = 0;
  while (client.connected()) {
    String line = client.readStringUntil('\n');
    if (line.startsWith("Transfer-Encoding:") && line.indexOf("chunked") >= 0) {
      isChunked = true;
    }
    if (line.startsWith("Content-Length:")) {
      contentLength = line.substring(15).toInt();
    }
    if (line == "\r" || line == "") break;
  }

  uint32_t totalRead = 0;

  if (isChunked) {
    Serial.println("  Chunked transfer");
    while (client.connected() || client.available()) {
      String sizeLine = client.readStringUntil('\n');
      uint32_t chunkSize = strtoul(sizeLine.c_str(), NULL, 16);
      if (chunkSize == 0) break;

      if (totalRead + chunkSize > HTTP_BUF_SIZE - 1) {
        Serial.printf("ERR: Chunk overflow %lu+%lu\n", totalRead, chunkSize);
        break;
      }

      // Fixed: use readBytes instead of byte-by-byte read
      unsigned long deadline = millis() + 10000;
      uint32_t got = 0;
      while (got < chunkSize && millis() < deadline) {
        if (client.available()) {
          int toRead = min((uint32_t)512, chunkSize - got);
          int n = client.readBytes(httpBuf + totalRead, toRead);
          if (n > 0) {
            totalRead += n;
            got += n;
          }
        } else if (!client.connected()) {
          break;
        }
      }

      client.readStringUntil('\n');
    }
  } else {
    Serial.printf("  Content-Length: %lu\n", contentLength);
    if (contentLength == 0 || contentLength > HTTP_BUF_SIZE - 1) {
      Serial.printf("ERR: Bad Content-Length %lu\n", contentLength);
      client.stop();
      return 0;
    }

    // Fixed: use readBytes instead of byte-by-byte read
    unsigned long deadline = millis() + 30000;
    while (totalRead < contentLength && millis() < deadline) {
      if (client.available()) {
        int toRead = min((uint32_t)512, contentLength - totalRead);
        int n = client.readBytes(httpBuf + totalRead, toRead);
        if (n > 0) {
          totalRead += n;
        }
      } else if (!client.connected()) {
        break;
      }
    }
  }

  httpBuf[totalRead] = '\0';
  client.stop();

  Serial.printf("OK: Received %lu bytes\n", totalRead);
  httpBufLen = totalRead;
  return totalRead;
}

void DiarySync::dateToStr8(const char* date, char* out) {
#if USE_DIAG_FILENAMES
  out[0] = 'T';
  out[1] = date[2]; out[2] = date[3];
  out[3] = date[5]; out[4] = date[6];
  out[5] = date[8]; out[6] = date[9];
  out[7] = 'Z';
  out[8] = '\0';
#else
  out[0] = date[0]; out[1] = date[1];
  out[2] = date[2]; out[3] = date[3];
  out[4] = date[5]; out[5] = date[6];
  out[6] = date[8]; out[7] = date[9];
  out[8] = '\0';
#endif
}

int DiarySync::hexValue(char c) {
  if (c >= '0' && c <= '9') return c - '0';
  if (c >= 'a' && c <= 'f') return c - 'a' + 10;
  if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  return -1;
}

bool DiarySync::appendUtf8(char* out, int& oi, int maxLen, uint32_t cp) {
  if (cp <= 0x7F) {
    if (oi + 1 >= maxLen) return false;
    out[oi++] = (char)cp;
  } else if (cp <= 0x7FF) {
    if (oi + 2 >= maxLen) return false;
    out[oi++] = 0xC0 | (cp >> 6);
    out[oi++] = 0x80 | (cp & 0x3F);
  } else if (cp <= 0xFFFF) {
    if (oi + 3 >= maxLen) return false;
    out[oi++] = 0xE0 | (cp >> 12);
    out[oi++] = 0x80 | ((cp >> 6) & 0x3F);
    out[oi++] = 0x80 | (cp & 0x3F);
  } else if (cp <= 0x10FFFF) {
    if (oi + 4 >= maxLen) return false;
    out[oi++] = 0xF0 | (cp >> 18);
    out[oi++] = 0x80 | ((cp >> 12) & 0x3F);
    out[oi++] = 0x80 | ((cp >> 6) & 0x3F);
    out[oi++] = 0x80 | (cp & 0x3F);
  }
  return true;
}

bool DiarySync::parseJsonString(char*& p, char* out, int maxLen) {
  int oi = 0;
  while (*p && *p != '"') {
    if (oi >= maxLen - 1) break;
    if (*p == '\\') {
      p++;
      switch (*p) {
        case '"':  out[oi++] = '"'; break;
        case '\\': out[oi++] = '\\'; break;
        case '/':  out[oi++] = '/'; break;
        case 'b':  out[oi++] = '\b'; break;
        case 'f':  out[oi++] = '\f'; break;
        case 'n':  out[oi++] = '\n'; break;
        case 'r':  out[oi++] = '\r'; break;
        case 't':  out[oi++] = '\t'; break;
        case 'u': {
          int h1 = hexValue(p[1]);
          int h2 = hexValue(p[2]);
          int h3 = hexValue(p[3]);
          int h4 = hexValue(p[4]);
          if (h1 < 0 || h2 < 0 || h3 < 0 || h4 < 0) return false;
          uint32_t cp = ((uint32_t)h1 << 12) | ((uint32_t)h2 << 8) |
                        ((uint32_t)h3 << 4) | h4;
          p += 4;

          if (cp >= 0xD800 && cp <= 0xDBFF && p[1] == '\\' && p[2] == 'u') {
            int l1 = hexValue(p[3]);
            int l2 = hexValue(p[4]);
            int l3 = hexValue(p[5]);
            int l4 = hexValue(p[6]);
            if (l1 >= 0 && l2 >= 0 && l3 >= 0 && l4 >= 0) {
              uint32_t low = ((uint32_t)l1 << 12) | ((uint32_t)l2 << 8) |
                             ((uint32_t)l3 << 4) | l4;
              if (low >= 0xDC00 && low <= 0xDFFF) {
                cp = 0x10000 + (((cp - 0xD800) << 10) | (low - 0xDC00));
                p += 6;
              }
            }
          }

          if (!appendUtf8(out, oi, maxLen, cp)) return false;
          break;
        }
        default:
          out[oi++] = *p;
          break;
      }
    } else {
      out[oi++] = *p;
    }

    p++;
    if (oi >= maxLen - 1) break;
  }

  out[oi] = '\0';
  return *p == '"';
}

void DiarySync::onProgress(SyncProgressCb cb) {
  progressCb = cb;
}

int DiarySync::parseAndWriteDiaries() {
  int count = 0;
  char* p = httpBuf;

  if (httpBufLen < 3 || httpBuf[0] != '[') {
    Serial.println("ERR: Invalid JSON, not an array");
    return 0;
  }

  // Count total diary entries for progress reporting
  int total = 0;
  {
    char* q = httpBuf;
    while ((q = strstr(q, "\"date\":\"")) != nullptr) {
      total++;
      q += 8;
    }
  }
  if (progressCb) progressCb(0, total);

  while (p < httpBuf + httpBufLen) {
    char* dateTag = strstr(p, "\"date\":\"");
    if (!dateTag) break;
    dateTag += 8;

    char dateStr[11] = {0};
    for (int i = 0; i < 10 && dateTag[i] && dateTag[i] != '"'; i++) {
      dateStr[i] = dateTag[i];
    }

    char date8[9];
    dateToStr8(dateStr, date8);
    Serial.printf("\nDIARY: %s -> %.8s.TXT\n", dateStr, date8);

    char* contentTag = strstr(dateTag, "\"content\":");
    if (!contentTag) {
      Serial.println("  SKIP: no content field");
      p = dateTag + 1;
      continue;
    }
    contentTag += 10;

    while (*contentTag == ' ' || *contentTag == '\n' || *contentTag == '\r' || *contentTag == '\t') {
      contentTag++;
    }
    if (strncmp(contentTag, "null", 4) == 0) {
      Serial.println("  SKIP: content is null");
      p = contentTag + 4;
      continue;
    }
    if (*contentTag != '"') {
      Serial.println("  SKIP: content is not a string");
      p = contentTag + 1;
      continue;
    }
    contentTag++;

    char* contentBuf = (char*)ps_malloc(CONTENT_BUF_SIZE);
    if (!contentBuf) {
      Serial.println("ERR: content buffer alloc failed");
      break;
    }

    contentBuf[0] = '\0';

    char* valuePtr = contentTag;
    if (!parseJsonString(valuePtr, contentBuf, CONTENT_BUF_SIZE)) {
      Serial.println("  SKIP: bad JSON string escape");
      free(contentBuf);
      p = contentTag + 1;
      continue;
    }

    int contentLen = strlen(contentBuf);
    Serial.printf("  Content: %d bytes\n", contentLen);

    if (fs->fileExists(date8, "TXT")) {
      Serial.printf("  SKIP: %.8s.TXT exists\n", date8);
      free(contentBuf);
      p = valuePtr + 1;
      continue;
    }

    if (contentLen > 65535) {
      Serial.println("  SKIP: content too large for current single-cluster writer");
      free(contentBuf);
      p = valuePtr + 1;
      continue;
    }

    if (!fs->writeDiary(date8, contentBuf, (uint16_t)contentLen)) {
      Serial.println("  STOP: write failed, aborting sync");
      Serial.println("\n--- Abort FAT check ---");
      fs->debugDumpFAT(0, 140);
      free(contentBuf);
      break;
    }

    count++;
    if (progressCb) progressCb(count, total);
    if (SYNC_MAX_FILES > 0 && count >= SYNC_MAX_FILES) {
      Serial.printf("  STOP: diagnostic sync limit reached (%d)\n", SYNC_MAX_FILES);
      Serial.println("\n--- Post-write FAT check ---");
      fs->debugDumpFAT(0, 140);
      free(contentBuf);
      break;
    }

    free(contentBuf);
    p = valuePtr + 1;
  }

  return count;
}

int DiarySync::sync() {
  if (!connectWiFi()) return 0;

  // Step1: Scan existing dates on SD card
  std::set<String> existingDates = scanExistingDates();

  // Step2: Build base URL
  String baseURL;
  if (existingDates.empty()) {
    // Full sync mode (empty SD card)
    baseURL = "/rest/v1/" + String(SUPABASE_TABLE) + "?select=date,content&order=date.asc";
    Serial.println("\nMode: FULL SYNC (empty SD card)");
  } else {
    // Incremental sync mode
    String latestDate = *existingDates.rbegin();
    baseURL = "/rest/v1/" + String(SUPABASE_TABLE) + "?select=date,content&date=gt." + latestDate + "&order=date.asc";
    Serial.println("\nMode: INCREMENTAL SYNC (after " + latestDate + ")");
  }

  // Step3: Paginated download
  const int PAGE_SIZE = SYNC_PAGE_SIZE;
  int offset = 0;
  int totalWritten = 0;
  int pageNum = 0;

  while (true) {
    pageNum++;
    String url = baseURL + "&limit=" + String(PAGE_SIZE) + "&offset=" + String(offset);
    Serial.printf("\n--- Page %d: offset=%d, limit=%d ---\n", pageNum, offset, PAGE_SIZE);

    Serial.println("\n--- Fetch Diaries ---");
    uint32_t jsonLen = fetchDiaries(url.c_str());
    if (jsonLen == 0) {
      Serial.println("ERR: Download failed, stopping");
      break;
    }

    Serial.printf("JSON (%lu bytes): %.200s%s\n",
                  jsonLen, httpBuf, jsonLen > 200 ? "..." : "");

    Serial.println("\n--- Sync to SD ---");
    int written = parseAndWriteDiaries();
    totalWritten += written;
    Serial.printf("Page %d: wrote %d entries\n", pageNum, written);

    // Check if we got less than PAGE_SIZE (means we reached the end)
    int entriesInThisPage = 0;
    char* q = httpBuf;
    while ((q = strstr(q, "\"date\":\"")) != nullptr) {
      entriesInThisPage++;
      q += 8;
    }

    Serial.printf("Entries in this page: %d\n", entriesInThisPage);

    if (entriesInThisPage < PAGE_SIZE) {
      Serial.println("Reached end of data");
      break;
    }

    // Prepare next page
    offset += PAGE_SIZE;

    // Safety: prevent infinite loop
    if (offset > 10000) {
      Serial.println("ERR: Too many pages, stopping");
      break;
    }
  }

  Serial.printf("\nSync complete: %d total entries written\n", totalWritten);
  return totalWritten;
}
