#include "OV2640.h"
#include <WiFi.h>
#include <WebServer.h>
#include <WiFiClient.h>

#include "SimStreamer.h"
#include "OV2640Streamer.h"
#include "CRtspSession.h"

//
// WARNING!!! PSRAM IC required for UXGA resolution and high JPEG quality
//            Ensure ESP32 Wrover Module or other board with PSRAM is selected
//            Partial images will be transmitted if image exceeds buffer size
//
#define CAMERA_MODEL_HONGKE // Has PSRAM
#include "camera_pins.h"

// #define ENABLE_OLED //if want use oled ,turn on thi macro
#define SOFTAP_MODE // If you want to run our own softap turn this on
#include "wifikeys.h"

#define ENABLE_WEBSERVER
#define ENABLE_RTSPSERVER

#ifdef ENABLE_OLED
#include "SSD1306.h"
#define OLED_ADDRESS 0x3c
#define I2C_SDA 14
#define I2C_SCL 13
SSD1306Wire display(OLED_ADDRESS, I2C_SDA, I2C_SCL, GEOMETRY_128_32);
bool hasDisplay; // we probe for the device at runtime
#endif

#ifdef ENABLE_WEBSERVER
WebServer server(80);
#endif

#ifdef ENABLE_RTSPSERVER
WiFiServer rtspServer(8554);
#endif

OV2640 cam;
#ifdef ENABLE_WEBSERVER
void handle_jpg_stream(void)
{
    WiFiClient client = server.client();
    String response = "HTTP/1.1 200 OK\r\n";
    response += "Content-Type: multipart/x-mixed-replace; boundary=frame\r\n\r\n";
    server.sendContent(response);

    while (1)
    {
        cam.run();
        if (!client.connected())
            break;
        response = "--frame\r\n";
        response += "Content-Type: image/jpeg\r\n\r\n";
        server.sendContent(response);

        client.write((char *)cam.getfb(), cam.getSize());
        server.sendContent("\r\n");
        if (!client.connected())
            break;
    }
}

void handle_jpg(void)
{
    WiFiClient client = server.client();

    cam.run();
    if (!client.connected())
    {
        return;
    }
    String response = "HTTP/1.1 200 OK\r\n";
    response += "Content-disposition: inline; filename=capture.jpg\r\n";
    response += "Content-type: image/jpeg\r\n\r\n";
    server.sendContent(response);
    client.write((char *)cam.getfb(), cam.getSize());
}

void handleNotFound()
{
    String message = "Server is running!\n\n";
    message += "URI: ";
    message += server.uri();
    message += "\nMethod: ";
    message += (server.method() == HTTP_GET) ? "GET" : "POST";
    message += "\nArguments: ";
    message += server.args();
    message += "\n";
    server.send(200, "text/plain", message);
}
#endif

#ifdef ENABLE_OLED
#define LCD_MESSAGE(msg) lcdMessage(msg)
#else
#define LCD_MESSAGE(msg)
#endif

#ifdef ENABLE_OLED
void lcdMessage(String msg)
{
    if (hasDisplay)
    {
        display.clear();
        display.drawString(128 / 2, 32 / 2, msg);
        display.display();
    }
}
#endif

bool apStarted = false;
IPAddress startAp()
{
    if (apStarted)
    {
        return WiFi.softAPIP();
    }

    WiFi.mode(WIFI_AP);
    apStarted = true;
    IPAddress local_IP(192, 168, 5, 1); //手动设置的开启的网络的ip地址
    IPAddress gateway(192, 168, 5, 1);  //手动设置的网关IP地址
    IPAddress subnet(255, 255, 255, 0); //手动设置的子网掩码
    WiFi.softAPConfig(local_IP, gateway, subnet);
    WiFi.softAP(ap_ssid, ap_password);

    Serial.println();
    Serial.print("Started AP ssid[");
    Serial.print(ap_ssid);
    Serial.print("], pwd[");
    Serial.print(ap_password);
    Serial.println("]");

    return WiFi.softAPIP();
}

IPAddress wifiConfig()
{
    IPAddress ip;
#ifdef SOFTAP_MODE
    ip = startAp();
#else
    if (WiFi.status() == WL_CONNECTED)
    {
        // Serial.print("Local ip:");
        // Serial.println(WiFi.localIP());
        return WiFi.localIP();
    }

    Serial.print("WiFi joining ");
    Serial.println(sta_ssid);
    WiFi.mode(WIFI_STA);
    WiFi.begin(sta_ssid, sta_password);
    // WiFi.setAutoConnect(true);   // Wifi设置函数,ture是真，假为false,setAutoConnect为自动连接
    WiFi.setAutoReconnect(true); // Wifi设置函数,ture是真，假为false，setAutoReconnect自动重连
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(F("."));
    }
    Serial.println();
    ip = WiFi.localIP();
    Serial.print(F("WiFi connected @"));
    Serial.println(ip);
#endif

    return ip;
}

camera_config_t camConfig() {
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
        Serial.println("cam needs 234K of framebuffer space");
        config.jpeg_quality = 10;
        config.fb_count = 2;
    }
    else
    {
        config.frame_size = FRAMESIZE_SVGA;
        config.jpeg_quality = 12;
        config.fb_count = 1;
    }
    return config;
}

CStreamer *streamer;
void setup()
{
#ifdef ENABLE_OLED
    hasDisplay = display.init();
    if (hasDisplay)
    {
        display.flipScreenVertically();
        display.setFont(ArialMT_Plain_16);
        display.setTextAlignment(TEXT_ALIGN_CENTER);
    }
#endif
    LCD_MESSAGE("booting");

    Serial.begin(115200);
    Serial.setDebugOutput(true);
    while (!Serial)
    {
        ;
    }
    ///
    Serial.println("booting");
    sd_init();
    psram_init();
    IPAddress ip = wifiConfig();
    ////
    camera_config_t config = camConfig();

    esp_err_t err = cam.init(config);
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

#ifdef ENABLE_WEBSERVER
    server.on("/", HTTP_GET, handle_jpg_stream);
    Serial.print("jpeg stream at http://");
    Serial.print(ip);
    Serial.println("/");

    server.on("/jpg", HTTP_GET, handle_jpg);
    Serial.print("jpeg capture at http://");
    Serial.print(ip);
    Serial.println("/jpg");

    server.onNotFound(handleNotFound);
    server.begin();
#endif

#ifdef ENABLE_RTSPSERVER
    rtspServer.begin();
    Serial.print("rtsp stream at rtsp://");
    Serial.print(ip);
    Serial.print(":8554/mjpeg/1 and rtsp://");
    Serial.print(ip);
    Serial.print(":8554/mjpeg/2");

    // streamer = new SimStreamer(true);             // our streamer for UDP/TCP based RTP transport
    streamer = new OV2640Streamer(cam); // our streamer for UDP/TCP based RTP transport
#endif
}

void loop()
{
    // 已经自动重连
    // wifiConfig();
#ifdef ENABLE_WEBSERVER
    server.handleClient();
#endif

#ifdef ENABLE_RTSPSERVER
    // 下发给客户端的每帧间隔
    uint32_t msecPerFrame = 10;
    static uint32_t lastimage = millis();

    // If we have an active client connection, just service that until gone
    streamer->handleRequests(0); // we don't use a timeout here,
    // instead we send only if we have new enough frames
    uint32_t now = millis();
    if (streamer->anySessions())
    {
        if (now > lastimage + msecPerFrame || now < lastimage)
        { // handle clock rollover
            streamer->streamImage(now);
            lastimage = now;

            // check if we are overrunning our max frame rate
            now = millis();
            // 判断完成下发一帧的时延是否太大，是则打日志告警
            if (now > lastimage + 30)
            {
                printf("warning exceeding max frame rate of %d ms\n", now - lastimage);
            }
        }
    }

    WiFiClient rtspClient = rtspServer.accept();
    if (rtspClient)
    {
        Serial.print("client: ");
        Serial.print(rtspClient.remoteIP());
        Serial.println();
        streamer->addSession(rtspClient);
    }
#endif
}
