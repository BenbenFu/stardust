/*
 * Xingxie diary sync prototype.
 *
 * Modules:
 * - config.h: WiFi, Supabase, and pin constants
 * - SDDriver: SPI sector read/write
 * - FAT32FS: FAT32 directory/FAT writer/reader
 * - DiarySync: HTTPS fetch, JSON extraction, diary writing
 * - Display: SSD1306 OLED status display + Chinese + scroll
 * - BLECtrl: BLE GATT server for remote control + WiFi provisioning
 *
 * v1.8: Added Book of Answers mode (MODE command, PREV/NEXT/PLAY navigation)
 * v1.7: Added BLE WiFi provisioning (Preferences storage)
 */

#include "config.h"
#include "SDDriver.h"
#include "FAT32FS.h"
#include "DiarySync.h"
#include "Display.h"
#include "BLECtrl.h"

SDDriver sdDriver;
FAT32FS fat32;
DiarySync diarySync;
Display display;
BLECtrl bleCtrl;

#ifdef BOARD_HAS_PSRAM
extern "C" {
  bool psramInit();
}
#endif

// 系统状态
enum SystemState {
  STATE_BOOT,
  STATE_SYNCING,
  STATE_SCROLLING,
  STATE_IDLE,
  STATE_BLE_ONLY,  // WiFi 未配网，等待 BLE 配网
  STATE_ANSWERS,   // 答案之书模式
  STATE_MENU       // 功能菜单
};
SystemState systemState = STATE_BOOT;

// 显示模式
enum DisplayMode {
  MODE_DIARY,
  MODE_ANSWERS,
  MODE_MENU
};
DisplayMode displayMode = MODE_DIARY;

// 菜单选中项
int menuIndex = 0;

// 日记列表缓存
#define MAX_DIARY_LIST 50
char diaryList[MAX_DIARY_LIST][13];
int diaryCount = 0;

// 答案之书数据
#define MAX_ANSWERS 500
#define MAX_ANSWER_LEN 128
char* answerLines = nullptr;    // 答案文本缓冲（PSRAM）
int answerCount = 0;            // 答案总条数
int* answerOffsets = nullptr;   // 每条答案在缓冲中的偏移量
int answerLens[MAX_ANSWERS];    // 每条答案的长度
int currentAnswerIndex = 0;     // 当前显示的答案索引

// BLE 配网成功后是否需要同步
bool needsPostProvisionSync = false;

// 前向声明
void onSyncProgress(int current, int total);
void handleBLECommand(const String& cmd);
void performPostProvisionSync();

// 日记阅读器回调（供Display调用）
bool readDiaryByIndex(int index, char* filename, uint16_t filename_max,
                      char* content, uint16_t content_max) {
  if (index < 0 || index >= diaryCount) {
    return false;
  }
  
  // 从文件名提取8+3格式
  const char* name = diaryList[index];
  char name8[9] = {0};
  char ext3[4] = {0};
  
  // 解析 "TYYMMDDZ.TXT" 格式
  int ni = 0;
  for (int i = 0; i < 8 && name[i] && name[i] != '.'; i++) {
    name8[ni++] = name[i];
  }
  name8[ni] = '\0';
  
  // 找扩展名
  const char* ext = strchr(name, '.');
  if (ext) {
    ext++;
    int ei = 0;
    while (ei < 3 && ext[ei]) {
      ext3[ei++] = ext[ei];
    }
    ext3[ei] = '\0';
  } else {
    strcpy(ext3, "TXT");
  }
  
  // 复制文件名
  strncpy(filename, name, filename_max - 1);
  filename[filename_max - 1] = '\0';
  
  // 读取内容
  uint16_t readLen = fat32.readDiary(name8, content, content_max);
  return readLen > 0;
}

// 更新BLE状态
void updateBLEStatus() {
  char buf[160];
  const char* stateStr = display.getStateString();

  if (displayMode == MODE_MENU) {
    snprintf(buf, sizeof(buf),
             "{\"state\":\"%s\",\"mode\":\"menu\",\"menuIndex\":%d,\"menuTotal\":%d}",
             stateStr, menuIndex, APP_MENU_COUNT);
    bleCtrl.updateStatus(buf);
  } else if (displayMode == MODE_ANSWERS) {
    snprintf(buf, sizeof(buf),
             "{\"state\":\"%s\",\"diary\":%d,\"total\":%d,\"scrolling\":false,\"mode\":\"answers\",\"answer\":%d,\"answerTotal\":%d}",
             stateStr, display.getCurrentDiaryIndex(), display.getTotalDiaryCount(),
             currentAnswerIndex + 1, answerCount);
    bleCtrl.updateStatus(buf);
  } else {
    snprintf(buf, sizeof(buf),
             "{\"state\":\"%s\",\"diary\":%d,\"total\":%d,\"scrolling\":%s,\"mode\":\"diary\"}",
             stateStr, display.getCurrentDiaryIndex(), display.getTotalDiaryCount(),
             display.isScrolling() ? "true" : "false");
    bleCtrl.updateStatus(buf);
  }
}

// ========== 答案之书 ==========

// 从 SD 卡加载 Answers.txt
bool loadAnswers() {
  if (answerLines != nullptr) {
    // 已经加载过了
    return answerCount > 0;
  }
  
  Serial.println("Answers: Loading ANSWERS.TXT from SD...");
  
  // 分配缓冲区
  answerLines = (char*)ps_malloc(65536);  // 64KB 足够
  if (!answerLines) {
    Serial.println("ERR: Answers buffer alloc failed");
    return false;
  }
  
  // 读取文件
  uint16_t readLen = fat32.readFile("ANSWERS", "TXT", answerLines, 65535);
  if (readLen == 0) {
    Serial.println("Answers: ANSWERS.TXT not found or empty");
    display.showAnswerNotFound();
    free(answerLines);
    answerLines = nullptr;
    return false;
  }
  answerLines[readLen] = '\0';
  
  // 分配偏移量数组
  answerOffsets = (int*)ps_malloc(MAX_ANSWERS * sizeof(int));
  if (!answerOffsets) {
    Serial.println("ERR: Answer offsets alloc failed");
    free(answerLines);
    answerLines = nullptr;
    return false;
  }
  
  // 按 \n 分割成行
  answerCount = 0;
  int pos = 0;
  while (answerLines[pos] != '\0' && answerCount < MAX_ANSWERS) {
    // 跳过开头的换行
    while (answerLines[pos] == '\n' || answerLines[pos] == '\r') pos++;
    if (answerLines[pos] == '\0') break;
    
    // 记录这一行的起始位置
    answerOffsets[answerCount] = pos;
    
    // 找到行尾
    int lineStart = pos;
    while (answerLines[pos] != '\0' && answerLines[pos] != '\n' && answerLines[pos] != '\r') {
      pos++;
    }
    answerLens[answerCount] = pos - lineStart;
    answerCount++;
  }
  
  Serial.printf("Answers: Loaded %d answers (%d bytes)\n", answerCount, readLen);
  return answerCount > 0;
}

// 获取指定索引的答案文本（临时截断，不修改原数据）
const char* getAnswerText(int index) {
  if (index < 0 || index >= answerCount || !answerLines) return "";
  // 在行尾临时插入 \0 来截断
  static int lastIdx = -1;
  if (lastIdx >= 0 && lastIdx < answerCount) {
    // 恢复上次截断的位置
    int end = answerOffsets[lastIdx] + answerLens[lastIdx];
    answerLines[end] = '\n';  // 恢复换行符
  }
  
  int end = answerOffsets[index] + answerLens[index];
  char saved = answerLines[end];
  answerLines[end] = '\0';
  lastIdx = index;
  
  return &answerLines[answerOffsets[index]];
}

// 显示当前答案
void showCurrentAnswer() {
  if (answerCount == 0) {
    display.showAnswerNotFound();
    return;
  }
  const char* text = getAnswerText(currentAnswerIndex);
  Serial.printf("Answers: Showing #%d: %.60s\n", currentAnswerIndex, text);
  display.showAnswer(text);
}

// 切换到答案之书模式
void switchToAnswersMode() {
  if (!loadAnswers()) return;
  
  display.pauseScroll();
  displayMode = MODE_ANSWERS;
  display.setMode("answers");
  
  // 随机起始位置
  currentAnswerIndex = random(0, answerCount);
  showCurrentAnswer();
  
  systemState = STATE_ANSWERS;
  updateBLEStatus();
  Serial.println("Mode: Switched to Answers");
}

// 切换到日记模式
void switchToDiaryMode() {
  displayMode = MODE_DIARY;
  display.setMode("diary");

  if (diaryCount > 0) {
    systemState = STATE_SCROLLING;
    display.startDiaryScroll(readDiaryByIndex, diaryCount);
  } else {
    systemState = STATE_IDLE;
    display.showIdle(__DATE__, 0);
  }
  updateBLEStatus();
  Serial.println("Mode: Switched to Diary");
}

// 返回功能菜单
void switchToMenu() {
  display.pauseScroll();
  displayMode = MODE_MENU;
  display.setMode("menu");
  systemState = STATE_MENU;
  display.showMenu(menuIndex, APP_MENU_COUNT);
  updateBLEStatus();
  Serial.printf("Mode: Back to menu (index=%d)\n", menuIndex);
}

// WiFi 配网成功后的同步处理
void performPostProvisionSync() {
  Serial.println("=== Post-provision sync starting ===");
  display.showWiFiConnecting();
  
  diarySync.onProgress(onSyncProgress);
  int written = diarySync.sync();
  
  Serial.println("\n========================================");
  if (written > 0) {
    Serial.printf("  Sync done: %d new diary file(s) written\n", written);
    display.showSyncDone(written);
    
    // 刷新日记列表
    diaryCount = fat32.listDiaries(diaryList, MAX_DIARY_LIST);
  } else {
    Serial.println("  Sync done: no new diary file written");
    display.showSyncDone(0);
  }
  Serial.printf("  Total diaries: %d\n", diaryCount);
  Serial.println("========================================");
  
  // 重新进入日记滚动模式
  delay(1500);
  if (diaryCount > 0) {
    systemState = STATE_SCROLLING;
    display.startDiaryScroll(readDiaryByIndex, diaryCount);
  } else {
    systemState = STATE_IDLE;
    display.showIdle(__DATE__, 0);
  }
  updateBLEStatus();
  
  needsPostProvisionSync = false;
}

// 执行BLE命令
void handleBLECommand(const String& cmd) {
  Serial.printf("BLE Command: %s\n", cmd.c_str());

  // ===== 菜单模式 =====
  if (displayMode == MODE_MENU) {
    if (cmd == "PREV") {
      menuIndex--;
      if (menuIndex < 0) menuIndex = APP_MENU_COUNT - 1;
      display.showMenu(menuIndex, APP_MENU_COUNT);
      updateBLEStatus();
    } else if (cmd == "NEXT") {
      menuIndex++;
      if (menuIndex >= APP_MENU_COUNT) menuIndex = 0;
      display.showMenu(menuIndex, APP_MENU_COUNT);
      updateBLEStatus();
    } else if (cmd == "PLAY") {
      // 进入选中的功能
      if (menuIndex == 0) {
        switchToDiaryMode();
      } else if (menuIndex == 1) {
        switchToAnswersMode();
      }
    }
    // 菜单下忽略 MODE/SYNC/STOP
    return;
  }

  // ===== MODE 命令：从任何功能返回菜单 =====
  if (cmd == "MODE") {
    switchToMenu();
    return;
  }

  // ===== 答案之书模式 =====
  if (displayMode == MODE_ANSWERS) {
    if (cmd == "PREV" || cmd == "NEXT" || cmd == "PLAY") {
      // 全部随机：避免连续两次显示同一条
      int newIdx;
      if (answerCount > 1) {
        do {
          newIdx = random(0, answerCount);
        } while (newIdx == currentAnswerIndex);
      } else {
        newIdx = 0;
      }
      currentAnswerIndex = newIdx;
      showCurrentAnswer();
      updateBLEStatus();
    }
    // 答案模式下忽略 SYNC/STOP
    return;
  }
  
  // 日记模式下的命令（原有逻辑）
  if (cmd == "PREV") {
    // 上一篇日记
    if (diaryCount > 0) {
      int newIndex = display.getCurrentDiaryIndex() - 1;
      if (newIndex < 0) newIndex = diaryCount - 1;
      display.playDiary(newIndex);
      Serial.printf("BLE: PREV -> diary #%d\n", newIndex);
    }
    updateBLEStatus();
    
  } else if (cmd == "NEXT") {
    // 下一篇日记
    if (diaryCount > 0) {
      int newIndex = display.getCurrentDiaryIndex() + 1;
      if (newIndex >= diaryCount) newIndex = 0;
      display.playDiary(newIndex);
      Serial.printf("BLE: NEXT -> diary #%d\n", newIndex);
    }
    updateBLEStatus();
    
  } else if (cmd == "SYNC") {
    // 重新同步
    Serial.println("BLE: SYNC command received");
    display.stopDiaryScroll();
    display.showWiFiConnecting();
    
    // 显示同步中
    diarySync.onProgress(onSyncProgress);
    int written = diarySync.sync();
    
    if (written > 0) {
      Serial.printf("BLE Sync: %d new diaries\n", written);
      display.showSyncDone(written);
      diaryCount = fat32.listDiaries(diaryList, MAX_DIARY_LIST);
    } else {
      Serial.println("BLE Sync: no new diaries");
      display.showSyncDone(0);
    }
    
    // 重新进入滚动模式
    delay(1000);
    if (diaryCount > 0) {
      systemState = STATE_SCROLLING;
      display.playDiary(0);  // 从第一篇开始
    } else {
      systemState = STATE_IDLE;
      display.showIdle(__DATE__, 0);
    }
    updateBLEStatus();
    
  } else if (cmd == "STOP") {
    // 停止滚动
    display.pauseScroll();
    Serial.println("BLE: STOP -> scrolling paused");
    updateBLEStatus();
    
  } else if (cmd == "PLAY") {
    // 开始/继续滚动
    if (diaryCount > 0) {
      if (!display.isScrolling() && display.getTotalDiaryCount() > 0) {
        display.resumeScroll();
      } else {
        // 如果没有正在播放任何日记，从头开始
        display.playDiary(display.getCurrentDiaryIndex());
      }
      Serial.println("BLE: PLAY -> scrolling resumed");
    }
    updateBLEStatus();
    
  } else {
    Serial.printf("BLE: Unknown command: %s\n", cmd.c_str());
  }
}

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("\n\n>>> BOOT <<<");

  Serial.println("========================================");
  Serial.println("  Xingxie Diary Sync v1.8");
  Serial.println("  + BLE WiFi Provisioning + Book of Answers");
  Serial.println("========================================");

  // OLED init (do this early so we can show status)
  display.begin();
  display.showBoot();
  delay(1500);

#if WAIT_FOR_SERIAL_START
  Serial.println("Waiting for serial start key...");
  Serial.println("Open Serial Monitor, then send any character within 60s.");
  unsigned long startWait = millis();
  while (!Serial.available() && millis() - startWait < SERIAL_START_TIMEOUT_MS) {
    delay(50);
  }
  if (Serial.available()) {
    while (Serial.available()) Serial.read();
    Serial.println("Start key received.");
  } else {
    Serial.println("Start timeout, continuing automatically.");
  }
#endif

#ifdef BOARD_HAS_PSRAM
  if (psramInit()) {
    Serial.printf("OK: PSRAM %.1f MB\n", ESP.getPsramSize() / 1024.0 / 1024.0);
  } else {
    Serial.println("ERR: PSRAM init failed");
    display.showError("PSRAM fail");
    return;
  }
#else
  Serial.println("OK: PSRAM init (using malloc fallback)");
#endif

  Serial.println("\n--- SD Card ---");
  display.showSDInit();
  if (!sdDriver.init()) {
    Serial.println("ERR: SD init failed");
    display.showError("SD init fail");
    return;
  }

  Serial.println("--- SD init OK, starting FAT32 ---");
  if (!fat32.begin(&sdDriver)) {
    Serial.println("ERR: FAT32 init failed");
    display.showError("FAT32 fail");
    return;
  }
  display.showFATReady(fat32.getAbsData());
  delay(500);

  // 同步前先获取日记列表
  diaryCount = fat32.listDiaries(diaryList, MAX_DIARY_LIST);
  Serial.printf("Found %d existing diaries on SD\n", diaryCount);

  if (!diarySync.begin(&fat32)) {
    Serial.println("ERR: DiarySync init failed");
    display.showError("Sync init fail");
    return;
  }

  // ========== WiFi 连接尝试（v1.7 新逻辑）==========
  Serial.println("\n--- WiFi Connection ---");
  systemState = STATE_SYNCING;
  display.showWiFiConnecting();
  diarySync.onProgress(onSyncProgress);
  int written = diarySync.sync();

  Serial.println("\n========================================");
  if (WiFi.status() == WL_CONNECTED) {
    // WiFi 连接成功，进行同步
    Serial.println("  WiFi: Connected!");
    Serial.printf("  IP: %s\n", WiFi.localIP().toString().c_str());
    
    if (written > 0) {
      Serial.printf("  Sync done: %d new diary file(s) written\n", written);
      display.showSyncDone(written);
      
      // 刷新日记列表
      diaryCount = fat32.listDiaries(diaryList, MAX_DIARY_LIST);
    } else {
      Serial.println("  Sync done: no new diary file written");
      display.showSyncDone(0);
    }
  } else {
    // WiFi 未连接或未配网
    Serial.println("  WiFi: Not connected (no credentials or connection failed)");
    Serial.println("  Entering BLE-only mode, waiting for WiFi provisioning...");
    display.showBLEWaiting();
    systemState = STATE_BLE_ONLY;
  }
  Serial.printf("  Total diaries: %d\n", diaryCount);
  Serial.println("========================================");
  // ==========================================

  // 短暂显示状态
  delay(1500);
  
  // ========== 启动 BLE ==========
  Serial.println("\n--- BLE Setup ---");
  
  // 初始化随机种子（答案之书随机用）
  randomSeed(esp_random());
  Serial.printf("Random seed: %u\n", esp_random());
  
  // 设置 WiFi 配网成功回调
  onWiFiProvisionedCb = performPostProvisionSync;
  
  if (bleCtrl.begin()) {
    Serial.println("BLE: Server started successfully");
    Serial.println("BLE: WiFi provisioning commands available:");
    Serial.println("  WIFI:SCAN - Scan nearby WiFi networks");
    Serial.println("  WIFI:SET_SSID:<ssid> - Set WiFi SSID");
    Serial.println("  WIFI:SET_PASS:<password> - Set WiFi password");
    Serial.println("  WIFI:CONNECT - Connect and save credentials");
    Serial.println("  WIFI:STATUS - Get current WiFi status");
    Serial.println("  WIFI:CLEAR - Clear saved credentials");
  } else {
    Serial.println("BLE: Failed to start");
  }
  // ==========================================

  // 进入功能菜单
  systemState = STATE_MENU;
  displayMode = MODE_MENU;
  display.setMode("menu");
  menuIndex = 0;
  display.showMenu(0, APP_MENU_COUNT);
  updateBLEStatus();
  Serial.println("Entering menu mode...");
}

void loop() {
  // 1. BLE update - 处理连接状态
  bleCtrl.update();
  
  // 2. 处理BLE命令
  if (bleCtrl.hasCommand()) {
    String cmd = bleCtrl.getCommand();
    bleCtrl.clearCommand();
    handleBLECommand(cmd);
  }
  
  // 3. 驱动滚动显示
  if (display.isScrolling()) {
    display.updateScroll();
  }
  
  // 4. 定期更新BLE状态（每5秒）
  static unsigned long lastStatusUpdate = 0;
  if (millis() - lastStatusUpdate > 5000) {
    lastStatusUpdate = millis();
    updateBLEStatus();
  }
}

void onSyncProgress(int current, int total) {
  display.showSyncProgress(current, total);
}
