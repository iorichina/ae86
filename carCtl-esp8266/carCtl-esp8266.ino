#ifndef ESP8266
#define ESP8266
#endif

#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <WebSocketsServer.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <Hash.h>
#include <stdio.h>
#include <SoftwareSerial.h>
#include "UTF8ToGB2312.h"

// D1->GPIO5, for car #5
#define bottom_left_D1_GPIO5 5
int bottom_left_duty = 0;
// D2->GPIO4, for car #7
#define top_left_D2_GPIO4 4
int top_left_duty = 0;

// D5->GPIO14, for car #6
#define top_right_D5_GPIO14 14
int top_right_duty = 0;
// D6->GPIO12, for car #8
#define bottom_right_D6_GPIO12 12
int bottom_right_duty = 0;

// D0->GPIO16
#define ttsRx 16
// D3->GPIO0
#define ttsTx 0

#define USE_SERIAL Serial

#include "wifi_config.h" // <<< create file and add wifi config ```const char* ssid = ; const char* password = ;```

ESP8266WebServer server(80);
WebSocketsServer webSocket = WebSocketsServer(9998);
SoftwareSerial ttsSerial(ttsRx, ttsTx);

void carCtr()
{
  // front
  analogWrite(top_left_D2_GPIO4, top_left_duty);
  analogWrite(top_right_D5_GPIO14, top_right_duty);
  // back
  analogWrite(bottom_left_D1_GPIO5, bottom_left_duty);
  analogWrite(bottom_right_D6_GPIO12, bottom_right_duty);
  // tts
  if (top_left_duty > 0 && bottom_right_duty > 0)
  {
    ttsSendString("右转弯，嘟，嘟");
  }
  else if (top_right_duty > 0 && bottom_left_duty > 0)
  {
    ttsSendString("左转弯，嘟，嘟");
  }
}
void parseDuty(uint32_t motion)
{
  top_left_duty = (motion >> 24) & 0xFF;
  top_right_duty = (motion >> 16) & 0xFF;
  bottom_left_duty = (motion >> 8) & 0xFF;
  bottom_right_duty = (motion)&0xFF;
}

long long wsCtrTs = millis();
void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length)
{

  switch (type)
  {
  case WStype_DISCONNECTED:
    USE_SERIAL.printf("[%u] Disconnected!\n", num);
    parseDuty(0);
    carCtr();
    break;
  case WStype_CONNECTED:
  {
    IPAddress ip = webSocket.remoteIP(num);
    USE_SERIAL.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

    // send message to client
    webSocket.sendTXT(num, "Connected");
  }
  break;
  case WStype_TEXT:
    USE_SERIAL.printf("[%u] get Text: %s\n", num, payload);

    if (payload[0] == '#')
    {
      // we get motion data
      uint32_t motion = (uint32_t)strtoul((const char *)&payload[1], NULL, 16);

      // decode motion data #top_left,top_right,bottom_left,bottom_right
      parseDuty(motion);

      carCtr();
      wsCtrTs = millis();
    }

    break;
  }
}

void ttsSendString(String str)
{
  ttsSerial.print(GB.get(str));
}

long long ttsTs = millis();
void tts()
{
  long long newTs = millis();
  long long diff = newTs - ttsTs;
  if (diff < 10000)
  {
    return;
  }
  if (bottom_left_duty == 0 && top_left_duty == 0 && top_right_duty == 0 && bottom_right_duty == 0)
  {
    if (diff < 15000)
    {
      return;
    }
    ttsTs = newTs;
    long randNumber = random(12);
    switch (randNumber)
    {
    case 0:
      ttsSendString("快点，出发啦");
      break;
    case 1:
      ttsSendString("小哥哥小姐姐，一起来玩呀");
      break;
    case 2:
      ttsSendString("没油了，快充电吧");
      break;
    case 3:
      ttsSendString("啊，我还能再抢救一下");
      break;
    case 4:
      ttsSendString("用力踩刹车也步会前进的");
      break;
    case 5:
      ttsSendString("脑子里永远有方向");
      break;
    case 6:
      ttsSendString("快走，有怪兽");
      break;
    case 7:
      ttsSendString("打雷啦，下雨回家收衣服啦");
      break;
    case 8:
      ttsSendString("我从没见过如此厚颜无耻之徒");
      break;
    case 9:
      ttsSendString("同学，你没放手刹");
      break;
    default:
      ttsSendString("雨一直下，头顶有点湿");
      break;
    }
  }
  ttsTs = newTs;
  if (top_left_duty > 0 && top_right_duty > 0)
  {
    long randNumber = random(10);
    switch (randNumber)
    {
    case 0:
      ttsSendString("快让开，我没踩刹车");
      break;
    case 1:
      ttsSendString("今天的风儿，甚至喧嚣");
      break;
    case 2:
      ttsSendString("你说啥？车速太快了，听不到");
      break;
    case 3:
      ttsSendString("蜗牛安知兔子跑得快不快");
      break;
    case 4:
      ttsSendString("挂4挡，挂6挡，全速前进");
      break;
    case 5:
      ttsSendString("快上车，没时间解释了");
      break;
    case 6:
      ttsSendString("叭，叭，别加塞");
      break;
    case 7:
      ttsSendString("开车的时候不要做奇怪的梦");
      break;
    case 8:
      ttsSendString("你以为没超速，实际上你没超速");
      break;
    default:
      ttsSendString("嘟，嘟，嘟嘟");
      break;
    }
    return;
  }

  if (bottom_left_duty < 0 && bottom_right_duty < 0)
  {
    ttsSendString("倒车，请不要剐蹭，你赔不起");
    return;
  }
}

long long ts = millis();
void setup()
{
  ttsSerial.begin(9600);
  // USE_SERIAL.begin(921600);
  USE_SERIAL.begin(115200);

  // USE_SERIAL.setDebugOutput(true);

  USE_SERIAL.println();
  USE_SERIAL.println();
  USE_SERIAL.println();

  for (uint8_t t = 4; t > 0; t--)
  {
    USE_SERIAL.printf("[SETUP] BOOT WAIT %d...\n", t);
    USE_SERIAL.flush();
    delay(1000);
  }

  // GPIO PIN
  {
    pinMode(top_left_D2_GPIO4, OUTPUT);
    pinMode(top_right_D5_GPIO14, OUTPUT);
    pinMode(bottom_left_D1_GPIO5, OUTPUT);
    pinMode(bottom_right_D6_GPIO12, OUTPUT);

    digitalWrite(top_left_D2_GPIO4, 1);
    digitalWrite(top_right_D5_GPIO14, 1);
    digitalWrite(bottom_left_D1_GPIO5, 1);
    digitalWrite(bottom_right_D6_GPIO12, 1);
  }

  // wifi
  {
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);
    USE_SERIAL.println("Connecting to wifi");

    // Wait for connection
    while (WiFi.status() != WL_CONNECTED)
    {
      delay(500);
      USE_SERIAL.print(".");
    }

    USE_SERIAL.println("");
    USE_SERIAL.print("Connected to ");
    USE_SERIAL.println(ssid);
    USE_SERIAL.print("IP address: ");
    USE_SERIAL.println(WiFi.localIP());
  }

  // start webSocket server
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);

  if (MDNS.begin("esp8266"))
  {
    USE_SERIAL.println("MDNS responder started");
  }

  // handle index
  server.on("/", []()
            {
    // send index.html
    server.send(200, "text/html", "<html><head><script>var connection=new WebSocket('ws://' + location.hostname + ':9998/', [ 'arduino', ]); connection.onopen=function (){ connection.send('Connect ' + new Date()); sendRGB();}; connection.onerror=function (error){ console.log('WebSocket Error ', error);}; connection.onmessage=function (e){ console.log('Server: ', e.data);}; function sendRGB(){ var rr=parseInt(document.getElementById('FORWARD_LEFT').value); var r=rr.toString(16); var gg=parseInt(document.getElementById('FORWARD_RIGHT').value); var g=gg.toString(16); var bb=parseInt(document.getElementById('BACK_LEFT').value); var b=bb.toString(16); var zz=parseInt(document.getElementById('BACK_RIGHT').value); var z=zz.toString(16); if (r.length < 2){ r='0' + r;} if (g.length < 2){ g='0' + g;} if (b.length < 2){ b='0' + b;} if (z.length < 2){ z='0' + z;} var rgb='#' + r + g + b + z; connection.send(rgb); console.log('RGBZ: ' + rr + '-' + gg + '-' + bb + '-' + zz);} </script></head><body>Controller: <br /><br />FORWARD_LEFT: <input id='FORWARD_LEFT' type='range' value='0' min='0' max='255' step='1' oninput='sendRGB();' /><br />FORWARD_RIGHT: <input id='FORWARD_RIGHT' type='range' value='0' min='0' max='255' step='1' oninput='sendRGB();' /><br />BACK_LEFT: <input id='BACK_LEFT' type='range' value='0' min='0' max='255' step='1' oninput='sendRGB();' /><br />BACK_RIGHT: <input id='BACK_RIGHT' type='range' value='0' min='0' max='255' step='1' oninput='sendRGB();' /><br /></body></html>"); });

  server.begin();

  // Add service to MDNS
  MDNS.addService("http", "tcp", 80);
  MDNS.addService("ws", "tcp", 9998);

  digitalWrite(top_left_D2_GPIO4, 0);
  digitalWrite(top_right_D5_GPIO14, 0);
  digitalWrite(bottom_left_D1_GPIO5, 0);
  digitalWrite(bottom_right_D6_GPIO12, 0);

  ts = millis();
  // D4
  pinMode(LED_BUILTIN, OUTPUT);   // Initialize the LED_BUILTIN pin as an output
  digitalWrite(LED_BUILTIN, LOW); // Turn the LED on (Note that LOW is the voltage level

  randomSeed(analogRead(0));
  ttsSendString("司机，麻烦去蓝翔挖掘机技术学校");
}

void loop()
{
  if (millis() - ts > 2000)
  {
    digitalWrite(LED_BUILTIN, HIGH); // Turn the LED on (Note that LOW is the voltage level
  }
  if (millis() - ts > 4000)
  {
    digitalWrite(LED_BUILTIN, LOW); // Turn the LED on (Note that LOW is the voltage level
    ts = millis();
  }
  webSocket.loop();
  server.handleClient();
  tts();
}
