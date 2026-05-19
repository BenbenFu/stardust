/*
 * SDDriver - minimal SPI block driver for SD/SDHC/SDXC cards.
 */
#ifndef SD_DRIVER_H
#define SD_DRIVER_H

#include <Arduino.h>
#include <SPI.h>
#include "config.h"

class SDDriver {
public:
  bool init();
  bool readSector(uint32_t sector, uint8_t* buf);
  bool writeSector(uint32_t sector, const uint8_t* buf);
  bool writeSectorRaw(uint32_t sector, const uint8_t* buf);

  uint8_t secBuf[512];

  bool waitCardReady(uint32_t timeoutMs);
  void setHighSpeed();

private:
  bool blockAddressing = true;

  uint8_t spiTransfer(uint8_t data);
  bool waitReady(uint32_t timeoutMs);
  void spiDeselect();
  void spiSelect();
  uint8_t sendCmd(uint8_t cmd, uint32_t arg);
  uint32_t commandAddress(uint32_t sector) const;
};

#endif
