/*
 * Display - SSD1306 OLED 中文显示 + 日记滚动
 * 基于 U8g2_for_Adafruit_GFX 实现中文支持
 */
#include "Display.h"
#include "config.h"

// 用于wrapText的临时缓冲区
#define WRAP_BUF_SIZE 2048
static char wrap_buf[WRAP_BUF_SIZE];

bool Display::begin() {
  Wire.begin(OLED_SDA_PIN, OLED_SCL_PIN);
  if (!oled.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("ERR: OLED init failed");
    ready = false;
    return false;
  }
  
  // 初始化 U8g2_for_Adafruit_GFX
  u8g2.begin(oled);
  
  oled.clearDisplay();
  oled.setTextColor(SSD1306_WHITE);
  oled.setTextSize(1);
  oled.display();
  ready = true;
  Serial.println("OK: OLED + U8g2 ready");
  return true;
}

// ============================================================
// 原有英文状态显示方法（保持兼容）
// ============================================================

void Display::showBoot() {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);  // 使用U8g2字体（英文）
  oled.clearDisplay();
  u8g2.setCursor(8, 16);
  u8g2.print("Stardust");
  u8g2.setCursor(8, 32);
  u8g2.print("v1.1");
  u8g2.setCursor(8, 48);
  u8g2.print("Stardust Avatar");
  oled.display();
}

void Display::showWiFiConnecting() {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("WiFi connecting...");
  u8g2.setCursor(0, 26);
  u8g2.print("(BLE config needed)");
  oled.display();
}

void Display::showWiFiConnected(const char* ip) {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("WiFi OK");
  u8g2.setCursor(0, 26);
  u8g2.print(ip);
  oled.display();
}

void Display::showSDInit() {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("SD Card...");
  oled.display();
}

void Display::showFATReady(uint32_t dataStart) {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("FAT32 OK");
  u8g2.setCursor(0, 26);
  char buf[32];
  snprintf(buf, sizeof(buf), "DATA @ %lu", dataStart);
  u8g2.print(buf);
  oled.display();
}

void Display::showSyncProgress(int current, int total) {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("Syncing...");

  // 大号数字显示
  u8g2.setFont(u8g2_font_ncenB14_tr);
  char numBuf[16];
  snprintf(numBuf, sizeof(numBuf), "%d/%d", current, total);
  u8g2.setCursor(20, 40);
  u8g2.print(numBuf);

  // 进度条
  u8g2.setFont(u8g2_font_ncenB08_tr);
  int barW = 108;
  int barH = 8;
  int barX = 10;
  int barY = 52;
  oled.drawRect(barX, barY, barW, barH, SSD1306_WHITE);
  int fill = (total > 0) ? (barW * current / total) : 0;
  oled.fillRect(barX + 1, barY + 1, fill, barH - 2, SSD1306_WHITE);

  oled.display();
}

void Display::showSyncDone(int count) {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("Sync complete");
  
  u8g2.setFont(u8g2_font_ncenB14_tr);
  char numBuf[16];
  snprintf(numBuf, sizeof(numBuf), "%d OK", count);
  u8g2.setCursor(20, 40);
  u8g2.print(numBuf);
  
  u8g2.setFont(u8g2_font_ncenB08_tr);
  u8g2.setCursor(0, 56);
  u8g2.print("diaries on SD");
  oled.display();
}

void Display::showIdle(const char* date, int count) {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 12);
  u8g2.print(date);
  u8g2.setCursor(0, 32);
  char buf[32];
  snprintf(buf, sizeof(buf), "%d diaries", count);
  u8g2.print(buf);
  u8g2.setCursor(0, 52);
  u8g2.print("Stardust");
  oled.display();
}

void Display::showError(const char* msg) {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("ERR:");
  u8g2.setCursor(0, 26);
  u8g2.print(msg);
  oled.display();
}

void Display::showBLEWaiting() {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  u8g2.setCursor(0, 10);
  u8g2.print("No WiFi config");
  u8g2.setCursor(0, 26);
  u8g2.print("Use BLE remote");
  u8g2.setCursor(0, 42);
  u8g2.print("to configure WiFi");
  u8g2.setCursor(0, 58);
  u8g2.print("Stardust v1.7");
  oled.display();
}

// ============================================================
// 新增中文显示方法
// ============================================================

// 计算UTF-8字符串的显示宽度（像素）
// 中文字符 16px，ASCII 半角 8px
uint16_t Display::calcUtf8Width(const char* str, uint8_t font_height) {
  uint16_t width = 0;
  if (!str) return 0;
  
  while (*str) {
    uint8_t c = (uint8_t)*str;
    uint8_t len = ChineseHelper::utf8CharLen(c);
    
    if (len == 1) {
      // ASCII 字符
      width += 8;  // 8像素宽度
    } else {
      // 中文或其他多字节字符
      width += 16; // 16像素宽度
    }
    str += len;
  }
  return width;
}

void Display::printChinese(uint8_t x, uint8_t y, const char* utf8_str) {
  if (!ready || !utf8_str) return;
  u8g2.setCursor(x, y);
  u8g2.print(utf8_str);
}

void Display::printChineseCenter(const char* utf8_str, uint8_t y) {
  if (!ready || !utf8_str) return;
  uint16_t w = calcUtf8Width(utf8_str, 16);
  uint8_t x = (128 > w) ? ((128 - w) / 2) : 0;
  printChinese(x, y, utf8_str);
}

// ============================================================
// 日记滚动相关
// ============================================================

// 内部：加载指定索引的日记内容
bool Display::loadDiary(int index) {
  if (!diaryReader || index < 0 || index >= totalDiaries) {
    return false;
  }
  
  char filename[32];
  if (diaryReader(index, filename, sizeof(filename), scrollContent, 4096)) {
    scrollContentLen = strlen(scrollContent);
    Serial.printf("DiaryScroll: loaded #%d '%s' (%d bytes)\n", 
                  index, filename, scrollContentLen);
    return true;
  } else {
    Serial.printf("DiaryScroll: failed to load #%d\n", index);
    scrollContent[0] = '\0';
    scrollContentLen = 0;
    return false;
  }
}

void Display::startDiaryScroll(DiaryReader reader, int totalDiaryCount) {
  if (!ready) return;
  
  diaryReader = reader;
  totalDiaries = totalDiaryCount;
  currentDiaryIndex = 0;
  scrolling = true;
  inPause = false;
  scrollY = 64;  // 从屏幕下方开始
  
  // 分配内容缓冲区
  if (scrollContent) {
    free(scrollContent);
    scrollContent = nullptr;
  }
  scrollContent = (char*)malloc(4096);
  if (!scrollContent) {
    Serial.println("ERR: scroll buffer alloc failed");
    scrolling = false;
    return;
  }
  scrollContent[0] = '\0';
  scrollContentLen = 0;
  
  Serial.printf("DiaryScroll: start, total=%d\n", totalDiaries);
  
  // 先显示"正在阅读..."提示
  oled.clearDisplay();
  u8g2.setFont(u8g2_font_ncenB08_tr);
  u8g2.setCursor(20, 30);
  u8g2.print("Reading...");
  oled.display();
  
  // 加载第一篇日记
  if (totalDiaries > 0) {
    loadDiary(0);
  }
  
  lastScrollTime = millis();
}

void Display::stopDiaryScroll() {
  scrolling = false;
  if (scrollContent) {
    free(scrollContent);
    scrollContent = nullptr;
  }
  Serial.println("DiaryScroll: stopped");
}

// 播放指定索引的日记
void Display::playDiary(int index) {
  if (!ready || !diaryReader) return;
  
  // 边界检查
  if (totalDiaries <= 0) return;
  
  // 循环索引
  if (index < 0) index = totalDiaries - 1;
  if (index >= totalDiaries) index = 0;
  
  currentDiaryIndex = index;
  
  // 加载日记内容
  loadDiary(index);
  
  // 重置滚动位置
  scrollY = 64;
  scrolling = true;
  inPause = false;
  lastScrollTime = millis();
  
  Serial.printf("DiaryScroll: play #%d\n", index);
}

// 从头开始播放当前日记
void Display::restartCurrentDiary() {
  if (!ready || !diaryReader) return;
  if (totalDiaries <= 0) return;
  
  // 重新加载当前日记
  loadDiary(currentDiaryIndex);
  
  // 重置滚动位置
  scrollY = 64;
  scrolling = true;
  inPause = false;
  lastScrollTime = millis();
  
  Serial.printf("DiaryScroll: restart #%d\n", currentDiaryIndex);
}

// 获取当前滚动状态描述
const char* Display::getStateString() const {
  if (!scrolling && totalDiaries <= 0) {
    return "idle";
  } else if (!scrolling && inPause) {
    return "paused";
  } else if (scrolling) {
    return "scrolling";
  }
  return "idle";
}

void Display::updateScroll() {
  if (!scrolling || !ready) return;
  
  unsigned long now = millis();
  
  // 处理暂停状态
  if (inPause) {
    if (now - lastPauseTime > SCROLL_PAUSE_MS) {
      inPause = false;
      // 滚动完一篇，移动到下一篇
      currentDiaryIndex++;
      if (currentDiaryIndex >= totalDiaries) {
        currentDiaryIndex = 0;  // 循环
      }
      
      // 加载下一篇日记
      loadDiary(currentDiaryIndex);
      
      // 重置滚动位置
      scrollY = 64;
    }
    return;
  }
  
  // 正常滚动
  if (now - lastScrollTime < SCROLL_SPEED_MS) return;
  lastScrollTime = now;
  
  // 计算内容高度（基于行数）
  if (scrollContentLen == 0 || !scrollContent) {
    // 没有内容，显示提示
    oled.clearDisplay();
    u8g2.setFont(u8g2_font_ncenB08_tr);
    u8g2.setCursor(10, 30);
    u8g2.print("No diary content");
    u8g2.setCursor(10, 50);
    char buf[32];
    snprintf(buf, sizeof(buf), "%d/%d", currentDiaryIndex + 1, totalDiaries);
    u8g2.print(buf);
    oled.display();
    return;
  }
  
  // 清除屏幕
  oled.clearDisplay();
  
  // 使用小字体显示日记内容
  u8g2.setFont(u8g2_font_wqy14_t_gb2312);  // 14px GB2312全集字体
  
  // 行缓冲区（按字节计，一行最多约9个中文=27字节UTF-8，留足余量）
  #define LINE_BUF_SIZE 128
  #define LINE_MAX_PIXELS 124
  
  // 中文字符约14px宽，ASCII约7px宽（留余量防溢出截断）
  #define CN_CHAR_PX 15
  #define ASC_CHAR_PX 8
  #define LINE_MAX_PIXELS 124
  
  // 分行显示（基于像素宽度换行）
  int lineY = scrollY;
  const char* p = scrollContent;
  int lineStart = 0;     // 行起始在scrollContent中的字节偏移
  int linePixelW = 0;    // 当前行已占像素宽度
  int lineEnd = 0;       // 行结束位置（不含）
  
  while (*p && lineY < 70) {
    uint8_t c = (uint8_t)*p;
    uint8_t clen = ChineseHelper::utf8CharLen(c);
    
    if (clen == 1 && *p == '\n') {
      // 显式换行：绘制当前行
      lineEnd = p - scrollContent;
      if (lineY >= -SCROLL_LINE_HEIGHT && lineY <= 64) {
        int copyLen = lineEnd - lineStart;
        if (copyLen > LINE_BUF_SIZE - 1) copyLen = LINE_BUF_SIZE - 1;
        char lineBuf[LINE_BUF_SIZE];
        memcpy(lineBuf, scrollContent + lineStart, copyLen);
        lineBuf[copyLen] = '\0';
        u8g2.setCursor(0, lineY);
        u8g2.print(lineBuf);
      }
      lineY += SCROLL_LINE_HEIGHT;
      lineStart = p - scrollContent + 1;
      linePixelW = 0;
      p++;
      continue;
    }
    
    // 计算这个字符的像素宽度
    int charPx = (clen == 1) ? ASC_CHAR_PX : CN_CHAR_PX;
    
    if (linePixelW + charPx > LINE_MAX_PIXELS) {
      // 超出屏幕宽度，自动换行：先绘制当前行
      lineEnd = p - scrollContent;
      if (lineY >= -SCROLL_LINE_HEIGHT && lineY <= 64) {
        int copyLen = lineEnd - lineStart;
        if (copyLen > LINE_BUF_SIZE - 1) copyLen = LINE_BUF_SIZE - 1;
        char lineBuf[LINE_BUF_SIZE];
        memcpy(lineBuf, scrollContent + lineStart, copyLen);
        lineBuf[copyLen] = '\0';
        u8g2.setCursor(0, lineY);
        u8g2.print(lineBuf);
      }
      lineY += SCROLL_LINE_HEIGHT;
      lineStart = p - scrollContent;
      linePixelW = charPx;
    } else {
      linePixelW += charPx;
    }
    
    p += clen;
  }
  
  // 绘制最后一行
  if (lineStart < scrollContentLen && lineY >= -SCROLL_LINE_HEIGHT && lineY <= 64) {
    int copyLen = scrollContentLen - lineStart;
    if (copyLen > LINE_BUF_SIZE - 1) copyLen = LINE_BUF_SIZE - 1;
    char lineBuf[LINE_BUF_SIZE];
    memcpy(lineBuf, scrollContent + lineStart, copyLen);
    lineBuf[copyLen] = '\0';
    u8g2.setCursor(0, lineY);
    u8g2.print(lineBuf);
  }
  
  // 底部显示日记序号和星屑标识
  u8g2.setFont(u8g2_font_ncenB08_tr);
  char buf[32];
  snprintf(buf, sizeof(buf), "%d/%d ~ Stardust", currentDiaryIndex + 1, totalDiaries);
  u8g2.setCursor(0, 58);
  u8g2.print(buf);
  
  oled.display();
  
  // 向上滚动
  scrollY--;
  
  // 检测是否滚动完成（估算总行数）
  // 粗略估算：每行约9个中文字符，每字符3字节UTF-8
  int estimatedLines = (scrollContentLen / 20) + 2;
  int totalHeight = estimatedLines * SCROLL_LINE_HEIGHT;
  if (scrollY < -(totalHeight - 64)) {
    inPause = true;
    lastPauseTime = now;
  }
}

void Display::wrapText(const char* text, char*** lines, int* lineCount) {
  // 简化实现：返回单个大字符串
  *lines = (char**)malloc(sizeof(char*));
  (*lines)[0] = (char*)malloc(strlen(text) + 1);
  strcpy((*lines)[0], text);
  *lineCount = 1;
}

void Display::freeLines(char*** lines, int lineCount) {
  for (int i = 0; i < lineCount; i++) {
    free((*lines)[i]);
  }
  free(*lines);
  *lines = nullptr;
}

// ============================================================
// 功能菜单
// ============================================================

void Display::showMenu(int selectedIndex, int totalCount) {
  if (!ready || selectedIndex < 0 || selectedIndex >= totalCount) return;

  oled.clearDisplay();

  // 顶部标题 "Stardust"
  u8g2.setFont(u8g2_font_ncenB08_tr);
  printChineseCenter("Stardust", 10);

  // 大号显示选中项名称
  const char* name = APP_MENU[selectedIndex].name;
  u8g2.setFont(u8g2_font_wqy14_t_gb2312);
  printChineseCenter(name, 30);

  // 副标题行（如果图标有值就显示图标字符，否则显示空）
  u8g2.setFont(u8g2_font_ncenB10_tr);
  u8g2.setCursor(10, 48);
  u8g2.print("< PREV");
  u8g2.setCursor(75, 48);
  u8g2.print("NEXT >");

  // 底部圆点指示器（居中）
  int dotTotalW = totalCount * 12;  // 每个圆点占 12px 间距
  int dotStartX = (128 - dotTotalW) / 2;
  for (int i = 0; i < totalCount; i++) {
    if (i == selectedIndex) {
      // 实心圆点 10x10
      oled.fillCircle(dotStartX + i * 12 + 5, 58, 4, SSD1306_WHITE);
    } else {
      // 空心圆点 10x10
      oled.drawCircle(dotStartX + i * 12 + 5, 58, 4, SSD1306_WHITE);
    }
  }

  oled.display();
}

// ============================================================
// 答案之书显示
// ============================================================

void Display::showAnswer(const char* text) {
  if (!ready || !text) return;
  oled.clearDisplay();

  // 顶部分隔线（靠近屏幕顶部）
  oled.drawLine(0, 2, 127, 2, SSD1306_WHITE);

  // 答案文字区域：三行中文，行高15px
  u8g2.setFont(u8g2_font_wqy14_t_gb2312);

  // 手动换行：按像素宽度逐字计算
  const int SCREEN_W = 128;
  const int LINE_H = 15;
  const int START_Y = 20;  // 第一行基线（距顶部分隔线约18px）
  const int MAX_LINES = 3;  // 最多3行答案

  int lineNum = 0;
  int y = START_Y;
  const char* p = text;

  while (*p && lineNum < MAX_LINES) {
    // 计算这一行能放多少字符
    uint16_t w = 0;
    const char* lineStart = p;
    const char* lineEnd = p;
    
    while (*p && *p != '\n' && *p != '\r') {
      uint8_t c = (uint8_t)*p;
      uint8_t clen = ChineseHelper::utf8CharLen(c);
      uint16_t cw = (clen == 1) ? 8 : 16;  // ASCII 8px, 中文 16px
      
      if (w + cw > SCREEN_W - 8) break;  // 留4px左右边距
      
      w += cw;
      p += clen;
      lineEnd = p;
    }
    
    // 提取这一行
    size_t lineLen = lineEnd - lineStart;
    if (lineLen > 0) {
      char lineBuf[65] = {0};
      if (lineLen > 64) lineLen = 64;
      memcpy(lineBuf, lineStart, lineLen);
      lineBuf[lineLen] = '\0';
      
      // 居中显示
      uint16_t lw = calcUtf8Width(lineBuf, 14);
      uint8_t x = (SCREEN_W > lw) ? ((SCREEN_W - lw) / 2) : 0;
      u8g2.setCursor(x, y);
      u8g2.print(lineBuf);
    }
    
    lineNum++;
    y += LINE_H;
    
    // 跳过换行符
    if (*p == '\n') p++;
    if (*p == '\r') p++;
  }
  
  // 底部分隔线（靠近屏幕底部）
  oled.drawLine(0, 58, 127, 58, SSD1306_WHITE);

  // 底部提示（不显示序号）
  u8g2.setFont(u8g2_font_ncenB08_tr);
  u8g2.setCursor(10, 63);
  u8g2.print("<");
  u8g2.setCursor(50, 63);
  u8g2.print("~");
  u8g2.setCursor(118, 63);
  u8g2.print(">");

  oled.display();
}

void Display::showAnswerNotFound() {
  if (!ready) return;
  u8g2.setFont(u8g2_font_ncenB08_tr);
  oled.clearDisplay();
  oled.drawLine(0, 2, 127, 2, SSD1306_WHITE);
  u8g2.setCursor(8, 30);
  u8g2.print("ANSWERS.TXT");
  u8g2.setCursor(8, 50);
  u8g2.print("not found on SD");
  oled.drawLine(0, 58, 127, 58, SSD1306_WHITE);
  oled.display();
}

// ============================================================
// 应用菜单定义（扩展：加新功能只需在此数组追加一项）
// ============================================================

const AppItem APP_MENU[APP_MENU_COUNT] = {
  {"日记",     "D"},
  {"答案之书", "A"},
};
