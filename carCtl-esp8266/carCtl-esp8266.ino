/*
   WebSocketServer_LEDcontrol.ino

    Created on: 26.11.2015

*/

#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <WebSocketsServer.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <Hash.h>
#include <stdio.h>

// D1->GPIO5, for car #5
#define bottom_left_pin 5
int bottom_left_duty = 0;
// D2->GPIO4, for car #7
#define top_left_pin 4
int top_left_duty = 0;

// D5->GPIO14, for car #6
#define top_right_pin 14
int top_right_duty = 0;
// D6->GPIO12, for car #8
#define bottom_right_pin 12
int bottom_right_duty = 0;

#define USE_SERIAL Serial

#include "wifi_config.h" // <<< create file and add wifi config ```const char* ssid = ; const char* password = ;```

ESP8266WebServer server(80);
WebSocketsServer webSocket = WebSocketsServer(9998);

void carCtr()
{
  // front
  analogWrite(top_left_pin, top_left_duty);
  analogWrite(top_right_pin, top_right_duty);
  // back
  analogWrite(bottom_left_pin, bottom_left_duty);
  analogWrite(bottom_right_pin, bottom_right_duty);
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
      uint32_t motion = (uint32_t)strtol((const char *)&payload[1], NULL, 16);

      // decode motion data #top_left,top_right,bottom_left,bottom_right
      parseDuty(motion);

      carCtr();
      wsCtrTs = millis();
    }

    break;
  }
}

long long ts = millis();
void setup()
{
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

  pinMode(top_left_pin, OUTPUT);
  pinMode(top_right_pin, OUTPUT);
  pinMode(bottom_left_pin, OUTPUT);
  pinMode(bottom_right_pin, OUTPUT);

  digitalWrite(top_left_pin, 1);
  digitalWrite(top_right_pin, 1);
  digitalWrite(bottom_left_pin, 1);
  digitalWrite(bottom_right_pin, 1);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.println("Connecting to wifi");

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

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
    server.send(200, "text/html", "<html><head><script>var connection = new WebSocket('ws://'+location.hostname+':9998/', ['arduino']);connection.onopen = function () {  connection.send('Connect ' + new Date()); }; connection.onerror = function (error) {    console.log('WebSocket Error ', error);};connection.onmessage = function (e) {  console.log('Server: ', e.data);};function sendRGB() {  var r = parseInt(document.getElementById('FORWARD_LEFT').value).toString(16);  var g = parseInt(document.getElementById('FORWARD_RIGHT').value).toString(16);  var b = parseInt(document.getElementById('BACK_LEFT').value).toString(16);  var z = parseInt(document.getElementById('BACK_RIGHT').value).toString(16);  if(r.length < 2) { r = '0' + r; }   if(g.length < 2) { g = '0' + g; }   if(b.length < 2) { b = '0' + b; }   if(z.length < 2) { z = '0' + z; }   var rgb = '#'+r+g+b+z;    console.log('RGBZ: ' + rgb); connection.send(rgb); }</script></head><body>LED Control:<br/><br/>FORWARD_LEFT: <input id=\"FORWARD_LEFT\" type=\"range\" min=\"0\" max=\"255\" step=\"1\" oninput=\"sendRGB();\" /><br/>FORWARD_RIGHT: <input id=\"FORWARD_RIGHT\" type=\"range\" min=\"0\" max=\"255\" step=\"1\" oninput=\"sendRGB();\" /><br/>BACK_LEFT: <input id=\"BACK_LEFT\" type=\"range\" min=\"0\" max=\"255\" step=\"1\" oninput=\"sendRGB();\" /><br/>BACK_RIGHT: <input id=\"BACK_RIGHT\" type=\"range\" min=\"0\" max=\"255\" step=\"1\" oninput=\"sendRGB();\" /><br/></body></html>"); });

  server.begin();

  // Add service to MDNS
  MDNS.addService("http", "tcp", 80);
  MDNS.addService("ws", "tcp", 9998);

  digitalWrite(top_left_pin, 0);
  digitalWrite(top_right_pin, 0);
  digitalWrite(bottom_left_pin, 0);
  digitalWrite(bottom_right_pin, 0);

  ts = millis();
  pinMode(LED_BUILTIN, OUTPUT);   // Initialize the LED_BUILTIN pin as an output
  digitalWrite(LED_BUILTIN, LOW); // Turn the LED on (Note that LOW is the voltage level
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
  if (millis() - wsCtrTs > 1500)
  {
    parseDuty(0);
    // carCtr();
   }
}
