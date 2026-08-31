/*
 * OsteoSense - Knee Band Sensor Firmware (ESP32 + MPU6050 BLE Telemetry)
 * Smart India Hackathon 2026 | PS 26004
 * 
 * Hardware Requirements:
 * - ESP32 Development Board (ESP32-WROOM-32)
 * - MPU6050 6-Axis Accelerometer & Gyroscope (I2C: SDA=GPIO21, SCL=GPIO22)
 * 
 * Features:
 * - Reads complementary filtered knee flexion angle at 100Hz
 * - Transmits live BLE GATT Notifications to OsteoSense Flutter app
 */

#include <Wire.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// MPU6050 I2C Address
#define MPU6050_ADDR 0x68

// BLE UUIDs for OsteoSense Service & Telemetry Characteristic
#define SERVICE_UUID           "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;

// MPU6050 Raw Variables
int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;
double pitch = 0, roll = 0;
double kneeAngle = 0;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("OsteoSense App Connected via BLE!");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("BLE Disconnected. Advertising...");
      pServer->getAdvertising()->start();
    }
};

void setupMPU6050() {
  Wire.begin(21, 22); // SDA = 21, SCL = 22
  Wire.beginTransmission(MPU6050_ADDR);
  Wire.write(0x6B); // Power management register
  Wire.write(0);    // Wake up MPU6050
  Wire.endTransmission(true);
}

void setup() {
  Serial.begin(115200);
  Serial.println("Initializing OsteoSense Knee Band BLE Firmware...");

  setupMPU6050();

  // Create BLE Device
  BLEDevice::init("OsteoSense-KneeBand");

  // Create BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  pCharacteristic->addDescriptor(new BLE2902());

  // Start Service
  pService->start();

  // Start Advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06); // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("BLE Knee Sensor Active & Advertising as 'OsteoSense-KneeBand'");
}

void loop() {
  // Read Accelerometer & Gyroscope
  Wire.beginTransmission(MPU6050_ADDR);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU6050_ADDR, 14, true);

  AcX = Wire.read()<<8|Wire.read();
  AcY = Wire.read()<<8|Wire.read();
  AcZ = Wire.read()<<8|Wire.read();
  Tmp = Wire.read()<<8|Wire.read();
  GyX = Wire.read()<<8|Wire.read();
  GyY = Wire.read()<<8|Wire.read();
  GyZ = Wire.read()<<8|Wire.read();

  // Trigonometric Pitch (Knee Flexion Angle Estimation)
  double accAngleY = atan2(AcX, sqrt(pow(AcY, 2) + pow(AcZ, 2))) * 180 / M_PI;
  kneeAngle = 0.96 * (kneeAngle + (GyY / 131.0) * 0.01) + 0.04 * accAngleY;
  kneeAngle = constrain(kneeAngle, 0.0, 130.0);

  if (deviceConnected) {
    // Send 100Hz Telemetry Packet: "KneeAngle,GyY"
    String payload = String(kneeAngle, 1) + "," + String(GyY / 131.0, 1);
    pCharacteristic->setValue(payload.c_str());
    pCharacteristic->notify();
    Serial.println("Telemetry Sent: " + payload);
  }

  delay(10); // 100Hz Sampling Rate
}
