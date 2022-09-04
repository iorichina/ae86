# ae86

## 1、介绍
自研小车，包括控制芯片程序、摄像头程序、硬件组装方法等

## 2、软件架构
软件架构说明


## 3、Arduino使用说明

### （1）Arduino IDE配置
1. 下载esp32开发板库

下载链接：<link>https://pan.baidu.com/s/11VeqqeqsaVGWoVlMKvHGPg?pwd=ij54</link>

或者git仓库下载<link>https://github.com/espressif/arduino-esp32</link><pre>git checkout 1.0.6</pre>（v1.0.6支持win7）

2. 安装esp32开发库

esp32开发库安装目录为`arduino安装目录/hardware/`，
或操作系统`文档/Arduino/hardware/`；

下载压缩包解压到`开发库安装目录`即可；

git仓库clone到`开发库安装目录/espressif/esp32/`，然后在该目录中开启cmd，执行
```
git submodule update --init --recursive
cd tools
.\get.exe
```
git仓库操作方法详细可以查看官方文档<link>https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html</link>

### （2）摄像头开发板
1.  开发板类型 ESP32-CAM
2.  工具->开发板 ESP32 Arduino -> HK ESP32-CAM-MB
3.  ESP32-D0WDQ6 (revision 1)
4.  Features: WiFi, BT, Dual Core, 240MHz
5.  Crystal is 40MHz
7.  Flash size: 4MB
8.  baud rate 460800

### (3) MH-ET ESP32开发板（电压、红外）
1. 开发板类型： ESP32 Dev Module
2. 管脚：ESP32 DEVKIT PINOUT
3. 模组：[ESP32-WROOM-32E](https://www.espressif.com.cn/sites/default/files/documentation/esp32-wroom-32e_esp32-wroom-32ue_datasheet_cn.pdf")
4. 


## 4、开发目录说明

### （1）carCtl-nodeMCU
小车控制代码
* wifi配置文件：carCtl-nodeMCU\car\start.lua
* 修改WIFI的ssid和pwd 参数

### （2）esp32Camera
HTTP摄像头
* wifi配置在目录下新建 wifi_config.h
<pre>
const char *sta_ssid = "******";
const char *sta_password = "******";
</pre>

### （3）ESP32cam-rtsp
RTSP和HTTP摄像头
* wifi配置在目录下新建 wifikeys.h
<pre>
const char *sta_ssid = "******";
const char *sta_password = "******";
const char *ap_ssid = "******";
const char *ap_password = "******";
</pre>

