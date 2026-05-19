/*
 * DiarySync - WiFi + HTTPS + JSON extraction + FAT32 writing.
 */
#ifndef DIARY_SYNC_H
#define DIARY_SYNC_H

#include <Arduino.h>
#include <set>
#include <String.h>
#include "FAT32FS.h"

// Callback type for sync progress: (current, total)
typedef void (*SyncProgressCb)(int current, int total);

class DiarySync {
public:
  bool begin(FAT32FS* fs);
  bool connectWiFi();

  // Runs one sync pass. Returns the number of newly written diaries.
  int sync();

  // Set a callback to receive progress updates during sync.
  void onProgress(SyncProgressCb cb);

private:
  FAT32FS* fs = nullptr;
  char* httpBuf = nullptr;
  uint32_t httpBufLen = 0;
  SyncProgressCb progressCb = nullptr;

  // Fetch diaries from Supabase with given URL (supports pagination)
  uint32_t fetchDiaries(const char* url);
  // Scan SD card for existing diary dates
  std::set<String> scanExistingDates();
  // Parse JSON and write to SD card
  int parseAndWriteDiaries();

  static void dateToStr8(const char* date, char* out);
  static int hexValue(char c);
  static bool appendUtf8(char* out, int& oi, int maxLen, uint32_t cp);
  static bool parseJsonString(char*& p, char* out, int maxLen);
};

#endif
