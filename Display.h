/*
 * Display - SSD1306 OLED 中文显示 + 日记滚动
 * 基于 U8g2_for_Adafruit_GFX 实现中文支持
 */
#ifndef DISPLAY_H
#define DISPLAY_H

#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <U8g2_for_Adafruit_GFX.h>

// 日记滚动配置
#define SCROLL_SPEED_MS    80    // 每行滚动间隔(ms)
#define SCROLL_PAUSE_MS    2000  // 每段结束暂停(ms)
#define SCROLL_LINE_HEIGHT 15    // 每行像素高度（含行间距）
#define MAX_DIARY_FILES    50     // 最多缓存的文件名数

// 菜单应用项（扩展：加新功能只需在此数组加一项）
struct AppItem {
  const char* name;   // 显示名称（如 "日记"、"答案之书"）
  const char* icon;   // 图标文字（单字符，大字体显示）
};

// 全局应用菜单定义
#define APP_MENU_COUNT 2
extern const AppItem APP_MENU[APP_MENU_COUNT];

class Display {
public:
  bool begin();

  // === 原有状态显示方法（保持英文兼容）===
  void showBoot();
  void showWiFiConnecting();
  void showWiFiConnected(const char* ip);
  void showSDInit();
  void showFATReady(uint32_t dataStart);
  void showSyncProgress(int current, int total);
  void showSyncDone(int count);
  void showIdle(const char* date, int count);
  void showError(const char* msg);

  // === WiFi 配网等待状态 ===
  void showBLEWaiting();

  // === 功能菜单 ===
  void showMenu(int selectedIndex, int totalCount);

  // === 答案之书 ===
  void showAnswer(const char* text);  // 只显示答案文字，不显示序号
  void showAnswerNotFound();

  // === 新增中文显示方法 ===
  // 在指定位置显示UTF-8中文字符串
  void printChinese(uint8_t x, uint8_t y, const char* utf8_str);
  void printChineseCenter(const char* utf8_str, uint8_t y);

  // === 日记滚动相关 ===
  // 开始日记滚动播放（传入日记目录回调函数）
  typedef bool (*DiaryReader)(int index, char* filename, uint16_t filename_max, 
                              char* content, uint16_t content_max);
  void startDiaryScroll(DiaryReader reader, int totalDiaryCount);
  void stopDiaryScroll();
  bool isScrolling() const { return scrolling; }
  void updateScroll();  // 在loop()中调用，处理滚动更新
  
  // === 新增：BLE控制支持 ===
  // 播放指定索引的日记
  void playDiary(int index);
  
  // 获取当前日记索引
  int getCurrentDiaryIndex() const { return currentDiaryIndex; }
  
  // 获取日记总数
  int getTotalDiaryCount() const { return totalDiaries; }
  
  // 获取当前滚动状态描述
  const char* getStateString() const;
  
  // 设置/获取当前模式（"diary" 或 "answers"）
  void setMode(const char* m) { strncpy(modeStr, m, 15); }
  const char* getMode() const { return modeStr; }
  
  // 从头开始播放当前日记
  void restartCurrentDiary();
  
  // 暂停滚动
  void pauseScroll() { scrolling = false; }
  
  // 继续滚动
  void resumeScroll() { 
    if (totalDiaries > 0 && currentDiaryIndex >= 0 && currentDiaryIndex < totalDiaries) {
      scrolling = true; 
      scrollY = 64;
      inPause = false;
    }
  }

  // === 状态 ===
  bool isReady() const { return ready; }

private:
  Adafruit_SSD1306 oled{128, 64, &Wire, -1};
  U8G2_FOR_ADAFRUIT_GFX u8g2;
  bool ready = false;

  // 滚动状态
  bool scrolling = false;
  DiaryReader diaryReader = nullptr;
  int totalDiaries = 0;
  int currentDiaryIndex = 0;
  unsigned long lastScrollTime = 0;
  unsigned long lastPauseTime = 0;
  bool inPause = false;
  
  // 当前日记内容
  char* scrollContent = nullptr;
  uint16_t scrollContentLen = 0;
  int16_t scrollY = 64;  // 初始位置在屏幕下方
  uint16_t contentHeight = 0;  // 计算出的内容总高度
  
  // 当前模式字符串
  char modeStr[16] = "diary";
  
  // 计算UTF-8字符串的显示宽度（像素）
  uint16_t calcUtf8Width(const char* str, uint8_t font_height);
  // 分行UTF-8字符串
  void wrapText(const char* text, char*** lines, int* lineCount);
  void freeLines(char*** lines, int lineCount);
  
  // 内部：加载指定索引的日记内容
  bool loadDiary(int index);
};

// UTF-8辅助函数（供外部使用）
namespace ChineseHelper {
  // 检查UTF-8字符是否是中文字符
  inline bool isChinese(uint8_t c) {
    return (c >= 0xE4 && c <= 0xE9) ||  // 三字节汉字 (0x4E00-0x9FFF)
           (c >= 0xF0 && c <= 0xF0);   // 四字节汉字 (部分)
  }
  // 获取UTF-8字符的字节数
  inline uint8_t utf8CharLen(uint8_t firstByte) {
    if (firstByte < 0x80) return 1;           // ASCII
    if ((firstByte & 0xE0) == 0xC0) return 2; // 2字节
    if ((firstByte & 0xF0) == 0xE0) return 3; // 3字节 (中文)
    if ((firstByte & 0xF8) == 0xF0) return 4; // 4字节
    return 1;
  }
}

#endif
