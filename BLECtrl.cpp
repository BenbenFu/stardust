/*
 * BLECtrl - ESP32 BLE Control Module
 * 
 * Handles BLE GATT server for Web Bluetooth remote control
 * Includes WiFi provisioning support
 */
#include "BLECtrl.h"
#include "config.h"

// 外部回调：WiFi 配网成功时触发同步
void (*onWiFiProvisionedCb)(void) = nullptr;

// ============================================================
// BLE Server Callbacks (standalone, uses pCtrl pointer)
// ============================================================

void BLECtrl::ServerCallbacks::onConnect(BLEServer* pServer) {
  pCtrl->deviceConnected = true;
  BLEDevice::startAdvertising();
  Serial.println("BLE: Client connected");
}

void BLECtrl::ServerCallbacks::onDisconnect(BLEServer* pServer) {
  pCtrl->deviceConnected = false;
  Serial.println("BLE: Client disconnected");
}

// ============================================================
// BLE Command Callbacks
// ============================================================

void BLECtrl::CmdCallbacks::onWrite(BLECharacteristic* pCharacteristic) {
  String rxStr = pCharacteristic->getValue();          // 先接收Arduino String
  std::string rxValue(rxStr.c_str());                  // 用c_str()转成std::string
  
  if (rxValue.length() > 0) {
    // Extract command string (handle both short and multi-chunk commands)
    String cmd = "";
    for (size_t i = 0; i < rxValue.length() && i < 128; i++) {
      char c = rxValue[i];
      if (c >= 32 && c < 127) {  // Printable ASCII
        cmd += c;
      }
    }
    
    if (cmd.length() > 0) {
      cmd.trim();
      
      // 检查是否是 WiFi 命令（直接在回调中处理，不经过 pendingCmdBuf）
      if (cmd.startsWith("WIFI:")) {
        Serial.printf("BLE: WiFi command: %s\n", cmd.c_str());
        pCtrl->handleWiFiCommand(cmd.c_str());
        return;
      }
      
      // 普通命令存入缓冲区
      //portENTER_CRITICAL(&cmdMux);
      strncpy(pCtrl->pendingCmdBuf, cmd.c_str(), 127);
      pCtrl->pendingCmdBuf[127] = '\0';
      pCtrl->commandReady = true;
      //portEXIT_CRITICAL(&cmdMux);
      
      Serial.printf("BLE: Received command: %s\n", cmd.c_str());
    }
  }
}

// ============================================================
// WiFi Provisioning Methods
// ============================================================

void BLECtrl::handleWiFiCommand(const char* cmd) {
  // WIFI:SCAN - 扫描附近 WiFi（异步：只设标志，在 update() 中执行）
  if (strcmp(cmd, "WIFI:SCAN") == 0) {
    Serial.println("BLE: WiFi scan requested (pending)");
    sendWiFiStatus("{\"wifi\":\"scanning\"}");
    wifiScanPending = true;   // 在 update() 中异步执行，避免阻塞 BLE 回调线程
    return;
  }
  
  // WIFI:SET_SSID:ssid - 暂存 SSID
  if (strncmp(cmd, "WIFI:SET_SSID:", 14) == 0) {
    const char* ssid = cmd + 14;
    strncpy(wifiProv.ssid, ssid, 32);
    wifiProv.ssid[32] = '\0';
    wifiProv.ssidSet = true;
    Serial.printf("BLE: SSID set to: %s\n", wifiProv.ssid);
    sendWiFiStatus("{\"wifi\":\"ssid_set\",\"ssid\":\"***\"}");
    return;
  }
  
  // WIFI:SET_PASS:password - 暂存密码
  if (strncmp(cmd, "WIFI:SET_PASS:", 14) == 0) {
    const char* pass = cmd + 14;
    strncpy(wifiProv.password, pass, 64);
    wifiProv.password[64] = '\0';
    wifiProv.passwordSet = true;
    Serial.printf("BLE: Password set (length: %d)\n", strlen(wifiProv.password));
    sendWiFiStatus("{\"wifi\":\"password_set\"}");
    return;
  }
  
  // WIFI:CONNECT - 连接并保存 WiFi
  if (strcmp(cmd, "WIFI:CONNECT") == 0) {
    Serial.println("BLE: WiFi connect requested");
    if (!wifiProv.ssidSet || !wifiProv.passwordSet) {
      Serial.println("BLE: SSID or password not set!");
      sendWiFiStatus("{\"wifi\":\"error\",\"msg\":\"SSID or password not set\"}");
      return;
    }
    
    sendWiFiStatus("{\"wifi\":\"connecting\",\"ssid\":\"***\"}");
    
    if (connectAndSaveWiFi(wifiProv.ssid, wifiProv.password)) {
      // 连接成功，触发同步回调
      char _ipBuf[20];
      snprintf(_ipBuf, sizeof(_ipBuf), "%s", WiFi.localIP().toString().c_str());
      char _wifiOkBuf[80];
      snprintf(_wifiOkBuf, sizeof(_wifiOkBuf), "{\"wifi\":\"connected\",\"ip\":\"%s\"}", _ipBuf);
      sendWiFiStatus(_wifiOkBuf);
      if (onWiFiProvisionedCb != nullptr) {
        Serial.println("BLE: Triggering sync callback...");
        onWiFiProvisionedCb();
      }
    } else {
      sendWiFiStatus("{\"wifi\":\"failed\",\"msg\":\"Connection failed\"}");
    }
    return;
  }
  
  // WIFI:STATUS - 查询当前 WiFi 状态
  if (strcmp(cmd, "WIFI:STATUS") == 0) {
    char status[256];
    if (WiFi.status() == WL_CONNECTED) {
      snprintf(status, sizeof(status), 
               "{\"wifi\":\"connected\",\"ssid\":\"%s\",\"rssi\":%d,\"ip\":\"%s\"}",
               WiFi.SSID().c_str(), WiFi.RSSI(), WiFi.localIP().toString().c_str());
    } else {
      // 检查是否有保存的凭据
      wifiPrefs.begin(WIFI_PREF_NS, true);  // 只读模式
      bool hasSsid = wifiPrefs.isKey(WIFI_PREF_SSID_KEY);
      wifiPrefs.end();
      
      if (hasSsid) {
        snprintf(status, sizeof(status), "{\"wifi\":\"disconnected\",\"saved\":true}");
      } else {
        snprintf(status, sizeof(status), "{\"wifi\":\"disconnected\",\"saved\":false}");
      }
    }
    sendWiFiStatus(status);
    return;
  }
  
  // WIFI:CLEAR - 清除保存的 WiFi 凭据
  if (strcmp(cmd, "WIFI:CLEAR") == 0) {
    wifiPrefs.begin(WIFI_PREF_NS, false);  // 写模式
    wifiPrefs.remove(WIFI_PREF_SSID_KEY);
    wifiPrefs.remove(WIFI_PREF_PASS_KEY);
    wifiPrefs.end();
    
    // 清除暂存状态
    wifiProv.ssid[0] = '\0';
    wifiProv.password[0] = '\0';
    wifiProv.ssidSet = false;
    wifiProv.passwordSet = false;
    
    Serial.println("BLE: WiFi credentials cleared");
    sendWiFiStatus("{\"wifi\":\"cleared\"}");
    return;
  }
  
  // WIFI:JOIN:ssid|password - 兼容旧命令格式（单个 SSID 和密码用 | 分隔）
  if (strncmp(cmd, "WIFI:JOIN:", 10) == 0) {
    const char* data = cmd + 10;
    char* pipe = strchr(data, '|');
    if (pipe) {
      size_t ssidLen = pipe - data;
      if (ssidLen < 33) {
        strncpy(wifiProv.ssid, data, ssidLen);
        wifiProv.ssid[ssidLen] = '\0';
        strncpy(wifiProv.password, pipe + 1, 64);
        wifiProv.password[64] = '\0';
        wifiProv.ssidSet = true;
        wifiProv.passwordSet = true;
        
        Serial.printf("BLE: WiFi JOIN - SSID: %s\n", wifiProv.ssid);
        sendWiFiStatus("{\"wifi\":\"connecting\",\"ssid\":\"***\"}");
        
        if (connectAndSaveWiFi(wifiProv.ssid, wifiProv.password)) {
          char _ipBuf2[20];
          snprintf(_ipBuf2, sizeof(_ipBuf2), "%s", WiFi.localIP().toString().c_str());
          char _wifiOkBuf2[80];
          snprintf(_wifiOkBuf2, sizeof(_wifiOkBuf2), "{\"wifi\":\"connected\",\"ip\":\"%s\"}", _ipBuf2);
          sendWiFiStatus(_wifiOkBuf2);
          if (onWiFiProvisionedCb != nullptr) {
            Serial.println("BLE: Triggering sync callback...");
            onWiFiProvisionedCb();
          }
        } else {
          sendWiFiStatus("{\"wifi\":\"failed\",\"msg\":\"Connection failed\"}");
        }
      }
    } else {
      sendWiFiStatus("{\"wifi\":\"error\",\"msg\":\"Invalid format, use SSID|PASSWORD\"}");
    }
    return;
  }
  
  Serial.printf("BLE: Unknown WiFi command: %s\n", cmd);
}

void BLECtrl::scanWiFiNetworks() {
  Serial.println("BLE: Starting WiFi scan...");
  
  // 发送扫描开始状态
  sendWiFiStatus("{\"wifi\":\"scanning\"}");
  delay(100);  // 等待 scanning 通知发出
  
  // ★ Bug 1 修复：扫描前强制确保 STA 模式，断开可能残留的连接
  WiFi.disconnect(false);   // 不断开清除凭据
  WiFi.mode(WIFI_STA);
  delay(100);
  
  // 触发 WiFi 扫描
  int n = WiFi.scanNetworks(false, true);  // 同步扫描，包含隐藏网络
  Serial.printf("BLE: Found %d networks\n", n);
  
  if (n <= 0) {
    sendWiFiStatus("{\"wifi\":\"scan_done\",\"networks\":[]}");
    return;
  }
  
  // 限制返回数量（BLE NOTIFY 有长度限制）
  int maxNetworks = min(n, 10);
  Serial.printf("BLE: Returning %d networks\n", maxNetworks);
  
  // 构建 JSON 数组（分批发送以避免超过 MTU）
  const size_t MAX_CHUNK = 400;  // 保守值，确保单个 notify 不超过 BLE 实际 payload
  char chunk[MAX_CHUNK + 1];
  
  strcpy(chunk, "{\"wifi\":\"scan_done\",\"networks\":[");
  size_t pos = strlen(chunk);
  
  for (int i = 0; i < maxNetworks; i++) {
    // 获取网络信息
    String ssid = WiFi.SSID(i);
    int rssi = WiFi.RSSI(i);
    int enc = WiFi.encryptionType(i);
    
    // 转义 SSID 中的特殊字符（简化处理）
    char escSsid[65] = {0};
    size_t si = 0;
    for (size_t j = 0; j < ssid.length() && si < 63; j++) {
      char c = ssid.charAt(j);
      if (c == '"' || c == '\\') {
        escSsid[si++] = '\\';
      }
      escSsid[si++] = c;
    }
    
    // 构建条目
    char entry[128];
    int len = snprintf(entry, sizeof(entry), 
                       "%s{\"ssid\":\"%s\",\"rssi\":%d}",
                       (i > 0) ? "," : "", escSsid, rssi);
    
    // 检查是否需要分批发送（每 5 个网络或超过阈值时分片）
    if (pos + len > MAX_CHUNK - 50 || (i > 0 && i % 5 == 0)) {
      // 发送当前批次并开始新批次
      strcat(chunk, "]}");
      sendNotifyChunk(chunk, strlen(chunk));
      
      // 开始新批次
      strcpy(chunk, "{\"wifi\":\"scan_cont\",\"networks\":[");
      pos = strlen(chunk);
    }
    
    // 添加到当前批次
    if (pos + len < MAX_CHUNK) {
      memcpy(chunk + pos, entry, len);
      pos += len;
      chunk[pos] = '\0';
    }
  }
  
  // 发送最后一批
  strcat(chunk, "]}");
  sendNotifyChunk(chunk, strlen(chunk));
  
  // 清理扫描结果
  WiFi.scanDelete();
}

bool BLECtrl::connectAndSaveWiFi(const char* ssid, const char* password) {
  Serial.printf("BLE: Connecting to WiFi: %s\n", ssid);
  
  // 断开现有连接
  if (WiFi.status() == WL_CONNECTED) {
    WiFi.disconnect();
    delay(200);
  }
  
  // 尝试连接
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  Serial.println();
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("BLE: WiFi connected! IP: %s\n", WiFi.localIP().toString().c_str());
    
    // 保存凭据到 Preferences
    wifiPrefs.begin(WIFI_PREF_NS, false);  // 写模式
    wifiPrefs.putString(WIFI_PREF_SSID_KEY, ssid);
    wifiPrefs.putString(WIFI_PREF_PASS_KEY, password);
    wifiPrefs.end();
    
    Serial.println("BLE: WiFi credentials saved to Preferences");
    
    // 重置暂存状态
    wifiProv.ssidSet = false;
    wifiProv.passwordSet = false;
    
    return true;
  }
  
  Serial.println("BLE: WiFi connection failed");
  return false;
}

void BLECtrl::sendWiFiScanResult(const char* json) {
  sendNotifyChunk(json, strlen(json));
}

void BLECtrl::sendWiFiStatus(const char* status) {
  Serial.printf("BLE: WiFi status notify: %s\n", status);
  sendNotifyChunk(status, strlen(status));
}

void BLECtrl::sendNotifyChunk(const char* data, size_t len) {
  if (pStatusCharacteristic != nullptr && deviceConnected && len > 0) {
    // 确保不超过 BLE MTU
    size_t maxLen = min((size_t)512, len);
    pStatusCharacteristic->setValue((uint8_t*)data, maxLen);
    pStatusCharacteristic->notify();
    delay(50);  // 等待 BLE 协议栈完成发送，防止连续 notify 丢包
  }
}

// ============================================================
// BLECtrl Public Methods
// ============================================================

BLECtrl::BLECtrl() 
  : deviceConnected(false)
  , oldDeviceConnected(false)
  , commandReady(false)
  , pServer(nullptr)
  , pService(nullptr)
  , pCmdCharacteristic(nullptr)
  , pStatusCharacteristic(nullptr)
  , pAdvertising(nullptr)
  , serverCallbacks(nullptr)
  , cmdCallbacks(nullptr)
{
  pendingCmdBuf[0] = '\0';
  currentStatus = "{\"state\":\"idle\",\"diary\":0,\"total\":0,\"scrolling\":false}";
  portMUX_INITIALIZE(&cmdMux);
  
  // 初始化 WiFi 配网状态
  wifiProv.ssid[0] = '\0';
  wifiProv.password[0] = '\0';
  wifiProv.ssidSet = false;
  wifiProv.passwordSet = false;
  wifiScanPending = false;  // ★ Bug 2 修复：初始化扫描标志
}

BLECtrl::~BLECtrl() {
  // BLE library manages its own lifecycle, just stop advertising
  if (pAdvertising) {
    pAdvertising->stop();
  }
}

bool BLECtrl::begin() {
  Serial.println("BLE: Initializing...");
  
  // 初始化 Preferences
  wifiPrefs.begin(WIFI_PREF_NS, true);  // 先以只读模式检查
  bool hasSsid = wifiPrefs.isKey(WIFI_PREF_SSID_KEY);
  wifiPrefs.end();
  Serial.printf("BLE: WiFi credentials %s\n", hasSsid ? "exist" : "not found");
  
  // Create BLE Device
  BLEDevice::setMTU(512);
  BLEDevice::init(BLE_DEVICE_NAME);
  
  // Create BLE Server
  pServer = BLEDevice::createServer();
  
  // Create callbacks
  serverCallbacks = new ServerCallbacks(this);
  cmdCallbacks = new CmdCallbacks(this);
  pServer->setCallbacks(serverCallbacks);
  
  // Create BLE Service
  pService = pServer->createService(BLE_SERVICE_UUID);
  
  // Create Command Characteristic (WRITE)
  pCmdCharacteristic = pService->createCharacteristic(
    BLE_CMD_CHAR_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );
  pCmdCharacteristic->setCallbacks(cmdCallbacks);
  pCmdCharacteristic->setAccessPermissions(ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE);
  
  // Create Status Characteristic (READ + NOTIFY)
  pStatusCharacteristic = pService->createCharacteristic(
    BLE_STATUS_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_NOTIFY
  );
  pStatusCharacteristic->setAccessPermissions(ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE);
  
  // Add BLE2902 descriptor for NOTIFY
  // ★ Bug 3 修复：不在服务端强制开启 notify，让客户端通过 startNotifications() 自行订阅
  BLE2902* p2902 = new BLE2902();
  // p2902->setNotifications(true);  // 强制开启会导致客户端未订阅时丢包，已删除
  pStatusCharacteristic->addDescriptor(p2902);
  
  // Set initial status
  pStatusCharacteristic->setValue(currentStatus.c_str());
  
  // Start service
  pService->start();
  
  // Create advertising
  pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(BLE_SERVICE_UUID);
  pAdvertising->setAppearance(0x00);
  pAdvertising->setMinPreferred(0x0D);
  pAdvertising->setMinInterval(0x20);
  pAdvertising->setMaxInterval(0x40);
  
  // Start advertising
  BLEDevice::startAdvertising();
  
  Serial.println("BLE: Server started, advertising...");
  Serial.printf("BLE: Device name: %s\n", BLE_DEVICE_NAME);
  Serial.printf("BLE: Service UUID: %s\n", BLE_SERVICE_UUID);
  
  return true;
}

void BLECtrl::update() {
  // ★ Bug 2 修复：在 loop 线程执行扫描，不阻塞 BLE 回调
  if (wifiScanPending && deviceConnected) {
    wifiScanPending = false;
    scanWiFiNetworks();
  }

  // Handle disconnect/reconnect
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);
    pServer->startAdvertising();
    Serial.println("BLE: Restarted advertising");
    oldDeviceConnected = deviceConnected;
  }
  
  // Detect new connection
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
    Serial.println("BLE: New connection established");
  }
}

bool BLECtrl::hasCommand() {
  return commandReady;
}

String BLECtrl::getCommand() {
  portENTER_CRITICAL(&cmdMux);
  String cmd = String(pendingCmdBuf);
  portEXIT_CRITICAL(&cmdMux);
  return cmd;
}

void BLECtrl::clearCommand() {
  portENTER_CRITICAL(&cmdMux);
  pendingCmdBuf[0] = '\0';
  commandReady = false;
  portEXIT_CRITICAL(&cmdMux);
}

void BLECtrl::updateStatus(const char* json) {
  currentStatus = String(json);
  sendNotifyChunk(json, strlen(json));
}

void BLECtrl::updateStatus(const char* state, int diaryIndex, int totalDiary, bool isScrolling) {
  char buf[128];
  snprintf(buf, sizeof(buf), 
           "{\"state\":\"%s\",\"diary\":%d,\"total\":%d,\"scrolling\":%s}",
           state, diaryIndex, totalDiary, isScrolling ? "true" : "false");
  updateStatus(buf);
}
