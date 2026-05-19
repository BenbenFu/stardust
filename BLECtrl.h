/*
 * BLECtrl - ESP32 BLE Control Module
 * 
 * Provides BLE GATT server for remote control via Web Bluetooth
 * - Receives commands: PREV, NEXT, SYNC, STOP, PLAY, WIFI:*
 * - Reports status via NOTIFY: {"state":"scrolling","diary":3,"total":14,"scrolling":true}
 * - WiFi provisioning: WIFI:SCAN, WIFI:SET_SSID, WIFI:SET_PASS, WIFI:CONNECT, WIFI:STATUS, WIFI:CLEAR
 */
#ifndef BLE_CTRL_H
#define BLE_CTRL_H

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Preferences.h>
#include <WiFi.h>

// WiFi provisioning state
struct WiFiProvState {
  char ssid[33];     // 暂存的 SSID (max 32 chars + null)
  char password[65];  // 暂存的密码 (max 64 chars + null)
  bool ssidSet;
  bool passwordSet;
};

class BLECtrl {
public:
  BLECtrl();
  ~BLECtrl();
  
  // Initialize BLE server
  bool begin();
  
  // Update - call in main loop() to process connection events
  void update();
  
  // Check if there's a pending command
  bool hasCommand();
  
  // Get the pending command string
  String getCommand();
  
  // Clear the pending command after processing
  void clearCommand();
  
  // Update status - call when state changes, triggers NOTIFY
  void updateStatus(const char* json);
  
  // Convenience: update status with common fields
  void updateStatus(const char* state, int diaryIndex, int totalDiary, bool isScrolling);
  
  // Check if BLE is connected
  bool isConnected() const { return deviceConnected; }

  // ========== WiFi 配网公共接口 ==========
  
  // 发送 WiFi 扫描结果（分批 NOTIFY）
  void sendWiFiScanResult(const char* json);
  
  // 发送 WiFi 连接状态
  void sendWiFiStatus(const char* status);
  
  // 获取配网状态
  WiFiProvState* getWiFiProvState() { return &wifiProv; }

private:
  // BLE members
  BLEServer* pServer;
  BLEService* pService;
  BLECharacteristic* pCmdCharacteristic;
  BLECharacteristic* pStatusCharacteristic;
  BLEAdvertising* pAdvertising;
  
  bool deviceConnected;
  bool oldDeviceConnected;
  
  // Command buffer (protected by spinlock)
  char pendingCmdBuf[128];
  volatile bool commandReady;
  portMUX_TYPE cmdMux;
  
  // Current status string
  String currentStatus;
  
  // WiFi provisioning state
  WiFiProvState wifiProv;

  // Scan request flag (set in BLE callback, executed in update() to avoid blocking)
  volatile bool wifiScanPending;

  // Preferences for WiFi storage
  Preferences wifiPrefs;
  
  // ========== WiFi 配网私有方法 ==========
  
  // 处理 WiFi 命令
  void handleWiFiCommand(const char* cmd);
  
  // 扫描 WiFi 并发送结果
  void scanWiFiNetworks();
  
  // 连接到指定 WiFi 并保存凭据
  bool connectAndSaveWiFi(const char* ssid, const char* password);
  
  // 发送通知（处理长消息分批）
  void sendNotifyChunk(const char* data, size_t len);
  
  // ============================================================
  // Nested callback classes (need access to private members)
  // ============================================================
  class ServerCallbacks : public BLEServerCallbacks {
  public:
    BLECtrl* pCtrl;
    ServerCallbacks(BLECtrl* ctrl) : pCtrl(ctrl) {}
    void onConnect(BLEServer* pServer) override;
    void onDisconnect(BLEServer* pServer) override;
  };
  
  class CmdCallbacks : public BLECharacteristicCallbacks {
  public:
    BLECtrl* pCtrl;
    CmdCallbacks(BLECtrl* ctrl) : pCtrl(ctrl) {}
    void onWrite(BLECharacteristic* pCharacteristic) override;
  };
  
  ServerCallbacks* serverCallbacks;
  CmdCallbacks* cmdCallbacks;
  
  friend class ServerCallbacks;
  friend class CmdCallbacks;
};

// 外部回调：WiFi 配网成功时触发同步（由主程序设置）
extern void (*onWiFiProvisionedCb)(void);

#endif
