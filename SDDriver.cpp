/*
 * SDDriver - minimal SPI block driver for SD/SDHC/SDXC cards.
 */
#include "SDDriver.h"

uint8_t SDDriver::spiTransfer(uint8_t data) {
  return SPI.transfer(data);
}

bool SDDriver::waitReady(uint32_t timeoutMs) {
  uint32_t start = millis();
  while (millis() - start < timeoutMs) {
    if (spiTransfer(0xFF) == 0xFF) return true;
    delay(1);
  }
  return false;
}

void SDDriver::spiDeselect() {
  digitalWrite(SD_CS_PIN, HIGH);
  spiTransfer(0xFF);
}

void SDDriver::spiSelect() {
  digitalWrite(SD_CS_PIN, LOW);
}

uint32_t SDDriver::commandAddress(uint32_t sector) const {
  return blockAddressing ? sector : sector * 512UL;
}

uint8_t SDDriver::sendCmd(uint8_t cmd, uint32_t arg) {
  spiDeselect();
  spiSelect();
  if (!waitReady(500)) {
    spiDeselect();
    return 0xFF;
  }

  spiTransfer(0x40 | cmd);
  spiTransfer((arg >> 24) & 0xFF);
  spiTransfer((arg >> 16) & 0xFF);
  spiTransfer((arg >> 8) & 0xFF);
  spiTransfer(arg & 0xFF);

  uint8_t crc = 0xFF;
  if (cmd == 0) crc = 0x95;
  else if (cmd == 8) crc = 0x87;
  spiTransfer(crc);

  uint8_t resp = 0xFF;
  for (int i = 0; i < 10; i++) {
    resp = spiTransfer(0xFF);
    if ((resp & 0x80) == 0) break;
  }
  return resp;
}

bool SDDriver::init() {
  SPI.begin(SD_SCK_PIN, SD_MISO_PIN, SD_MOSI_PIN, SD_CS_PIN);
  // Start at 400kHz for card identification (CMD0, CMD8, ACMD41)
  SPI.beginTransaction(SPISettings(400000, MSBFIRST, SPI_MODE0));

  pinMode(SD_CS_PIN, OUTPUT);
  digitalWrite(SD_CS_PIN, HIGH);

  for (int i = 0; i < 80; i++) spiTransfer(0xFF);

  bool cmd0Ok = false;
  for (int retry = 0; retry < 10; retry++) {
    if (sendCmd(0, 0) == 0x01) {
      cmd0Ok = true;
      break;
    }
    delay(50);
    spiDeselect();
    for (int i = 0; i < 20; i++) spiTransfer(0xFF);
  }
  if (!cmd0Ok) {
    Serial.println("ERR: CMD0");
    return false;
  }
  Serial.println("OK: CMD0");

  if (sendCmd(8, 0x000001AA) != 0x01) {
    Serial.println("ERR: CMD8");
    spiDeselect();
    return false;
  }
  for (int i = 0; i < 4; i++) spiTransfer(0xFF);
  spiDeselect();
  Serial.println("OK: CMD8");

  for (int i = 0; i < 1000; i++) {
    sendCmd(55, 0);
    spiDeselect();
    if (sendCmd(41, 0x40000000) == 0x00) {
      spiDeselect();
      Serial.println("OK: ACMD41");
      goto acmd41_ok;
    }
    spiDeselect();
    delay(10);
  }
  Serial.println("ERR: ACMD41 timeout");
  return false;

acmd41_ok:
  if (sendCmd(58, 0) != 0x00) {
    Serial.println("ERR: CMD58");
    spiDeselect();
    return false;
  }
  uint8_t ocr0 = spiTransfer(0xFF);
  uint8_t ocr1 = spiTransfer(0xFF);
  uint8_t ocr2 = spiTransfer(0xFF);
  uint8_t ocr3 = spiTransfer(0xFF);
  spiDeselect();

  blockAddressing = (ocr0 & 0x40) != 0;
  Serial.printf("OK: CMD58 OCR=%02X%02X%02X%02X addr=%s\n",
                ocr0, ocr1, ocr2, ocr3, blockAddressing ? "block" : "byte");

  Serial.println("OK: SD init done (100kHz)");
  Serial.flush();

  // Switch to high speed for data operations
  setHighSpeed();
  return true;
}

void SDDriver::setHighSpeed() {
  // Use 10 MHz for data reads/writes - safe for most SD cards
  // On ESP32, endTransaction restores default settings, then setFrequency applies
  SPI.endTransaction();
  SPI.setFrequency(10000000);
  Serial.println("OK: SD high-speed mode (10 MHz)");
}

bool SDDriver::readSector(uint32_t sector, uint8_t* buf) {
  if (sendCmd(17, commandAddress(sector)) != 0x00) {
    Serial.printf("ERR: CMD17 fail LBA %lu\n", sector);
    spiDeselect();
    return false;
  }

  uint16_t t = 10000;
  while (spiTransfer(0xFF) != 0xFE && --t);
  if (t == 0) {
    Serial.printf("ERR: read token timeout LBA %lu\n", sector);
    spiDeselect();
    return false;
  }

  for (int i = 0; i < 512; i++) buf[i] = spiTransfer(0xFF);
  spiTransfer(0xFF);
  spiTransfer(0xFF);
  spiDeselect();
  return true;
}

bool SDDriver::writeSectorRaw(uint32_t sector, const uint8_t* buf) {
  if (sendCmd(24, commandAddress(sector)) != 0x00) {
    Serial.printf("ERR: CMD24 fail LBA %lu\n", sector);
    spiDeselect();
    return false;
  }

  for (int i = 0; i < 10; i++) spiTransfer(0xFF);
  spiTransfer(0xFE);

  for (int i = 0; i < 512; i++) spiTransfer(buf[i]);
  spiTransfer(0xFF);
  spiTransfer(0xFF);

  uint8_t resp = spiTransfer(0xFF);
  if ((resp & 0x1F) != 0x05) {
    Serial.printf("ERR: Data rejected 0x%02X LBA %lu\n", resp, sector);
    spiDeselect();
    return false;
  }

  uint16_t t = 60000;
  while (spiTransfer(0xFF) == 0x00 && --t);
  waitReady(500);
  spiDeselect();
  if (t == 0) {
    Serial.printf("ERR: write busy timeout LBA %lu\n", sector);
    return false;
  }
  return true;
}

bool SDDriver::writeSector(uint32_t sector, const uint8_t* buf) {
  uint8_t verifyBuf[512];
  if (!writeSectorRaw(sector, buf)) {
    Serial.printf("ERR: write fail LBA %lu\n", sector);
    return false;
  }

  // Increased delay: 128GB card may need more time to complete internal write
  // Especially after aborted writes, the card's internal state may be unsettled
  delay(200);

  // Multiple retry attempts with longer delays
  for (int retry = 0; retry < 4; retry++) {
    if (retry > 0) {
      Serial.printf("WARN: verify retry %d LBA %lu\n", retry, sector);
      delay(200);  // Longer delay between retries
    }

    if (!readSector(sector, verifyBuf)) {
      Serial.printf("ERR: verify read fail LBA %lu\n", sector);
      continue;
    }

    if (memcmp(verifyBuf, buf, 512) == 0) {
      if (retry > 0) {
        Serial.printf("OK: verify ok on retry %d LBA %lu\n", retry, sector);
      }
      return true;
    }

    // Debug: print first 16 bytes on every failure for visibility
    Serial.printf("DBG: LBA %lu verify mismatch:\n", sector);
    Serial.printf("  Write: ");
    for (int i = 0; i < 16; i++) Serial.printf("%02X ", buf[i]);
    Serial.println();
    Serial.printf("  Read:  ");
    for (int i = 0; i < 16; i++) Serial.printf("%02X ", verifyBuf[i]);
    Serial.println();
  }

  // 4 retries all failed
  Serial.printf("ERR: data verify mismatch LBA %lu (tried 4 times)\n", sector);
  return false;
}

// Issue CMD13 (SEND_STATUS) to poll card until not busy.
// Returns true if card is ready (response bits 7-0 != 0x00 means ready).
// This helps ensure the card has completed its internal write operation
// before we attempt to read back data.
bool SDDriver::waitCardReady(uint32_t timeoutMs) {
  uint32_t start = millis();
  while (millis() - start < timeoutMs) {
    spiDeselect();
    spiSelect();
    if (!waitReady(500)) {
      spiDeselect();
      delay(10);
      continue;
    }
    spiTransfer(0x40 | 13);  // CMD13
    spiTransfer(0x00);
    spiTransfer(0x00);
    spiTransfer(0x00);
    spiTransfer(0x00);
    spiTransfer(0xFF);  // CRC

    uint8_t resp = 0xFF;
    for (int i = 0; i < 10; i++) {
      resp = spiTransfer(0xFF);
      if ((resp & 0x80) == 0) break;
    }
    // Read R2 response (2 bytes)
    uint8_t r2_lo = spiTransfer(0xFF);
    uint8_t r2_hi = spiTransfer(0xFF);
    spiDeselect();

    // Card is ready if we got a valid R1 response (not 0xFF = timeout)
    if (resp != 0xFF) {
      return true;
    }
    delay(10);
  }
  return false;  // Timeout
}
