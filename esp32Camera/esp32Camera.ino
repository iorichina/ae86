#include "esp_camera.h"
#include <WiFi.h>
#include <string.h>
#include "FS.h"
#include "SD_MMC.h"
#include <SPI.h>
#include <SD.h>
#include <time.h>
//
// WARNING!!! PSRAM IC required for UXGA resolution and high JPEG quality
//            Ensure ESP32 Wrover Module or other board with PSRAM is selected
//            Partial images will be transmitted if image exceeds buffer size
//
#define CAMERA_MODEL_HONGKE // Has PSRAM
#include "camera_pins.h"

//const char *sta_ssid = "ssid";
//const char *sta_password = "pwd";
//const char *ap_ssid = "my_ssid";
//const char *ap_password = "my_pwd";
#include "wifi_config.h"

void startCameraServer();
void sd_init();
int psram_init();

void setup()
{
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();
  sd_init();
  psram_init();

  reconnect();
//  startAp();
  
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  // if PSRAM IC present, init with UXGA resolution and higher JPEG quality
  //                      for larger pre-allocated frame buffer.
  if (psramFound())
  {
    config.frame_size = FRAMESIZE_UXGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
  }
  else
  {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }

  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK)
  {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }

  sensor_t *s = esp_camera_sensor_get();
  // initial sensors are flipped vertically and colors are a bit saturated
  if (s->id.PID == OV3660_PID)
  {
    s->set_vflip(s, 1);       // flip it back
    s->set_brightness(s, 1);  // up the brightness just a bit
    s->set_saturation(s, -2); // lower the saturation
  }
  // drop down frame size for higher initial frame rate
  s->set_framesize(s, FRAMESIZE_QVGA);

  startCameraServer();
}
void startAp() {
  IPAddress local_IP(192,168,5,1);//手动设置的开启的网络的ip地址
  IPAddress gateway(192,168,5,1);  //手动设置的网关IP地址
  IPAddress subnet(255,255,255,0); //手动设置的子网掩码
  WiFi.mode(WIFI_AP);
  WiFi.softAPConfig(local_IP, gateway, subnet);
  WiFi.softAP(ap_ssid, ap_password);
  Serial.println();
  Serial.print("Started AP ssid[");
  Serial.print(ap_ssid);
  Serial.print("], pwd[");
  Serial.print(ap_password);
  Serial.println("]");
  Serial.print("open url for stream:http://");
  Serial.print(WiFi.softAPIP());
  Serial.println(":81/stream");
}
void reconnect()
{
  if (WiFi.status() == WL_CONNECTED)
  {
    Serial.print("Local ip:");
    Serial.println(WiFi.localIP());
    return;
  }
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(sta_ssid);
  WiFi.begin(sta_ssid, sta_password);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected, local ip:");
  Serial.println(WiFi.localIP());
  Serial.print("open url for stream:http://");
  Serial.print(WiFi.localIP());
  Serial.println(":81/stream");
}
void loop()
{
  reconnect();
  // put your main code here, to run repeatedly:
  delay(10000);
}
