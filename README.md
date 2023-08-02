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

### （4）Board Type

ESP32 Arduino -> HK ESP32-CAM-MB

esp32包目录下的boards.txt 
（如：C:\Users\Administrator\AppData\Local\Arduino15\packages\esp32\hardware\esp32\2.0.9\boards.txt，或者 C:\Users\Documents\Arduino\hardware\espressif\esp32\boards.txt）
增加
<code>

##############################################################

esp32cammb.name=HK ESP32-CAM-MB

esp32cammb.upload.tool=esptool_py
esp32cammb.upload.maximum_size=3145728
esp32cammb.upload.maximum_data_size=327680
esp32cammb.upload.wait_for_upload_port=true
esp32cammb.upload.speed=460800

esp32cammb.serial.disableDTR=true
esp32cammb.serial.disableRTS=true

esp32cammb.build.mcu=esp32
esp32cammb.build.core=esp32
esp32cammb.build.variant=esp32
esp32cammb.build.board=ESP32_DEV
esp32cammb.build.flash_size=4MB
esp32cammb.build.partitions=huge_app
esp32cammb.build.defines=-DBOARD_HAS_PSRAM -mfix-esp32-psram-cache-issue
esp32cammb.build.code_debug=0

esp32cammb.menu.CPUFreq.240=240MHz (WiFi/BT)
esp32cammb.menu.CPUFreq.240.build.f_cpu=240000000L
esp32cammb.menu.CPUFreq.160=160MHz (WiFi/BT)
esp32cammb.menu.CPUFreq.160.build.f_cpu=160000000L
esp32cammb.menu.CPUFreq.80=80MHz (WiFi/BT)
esp32cammb.menu.CPUFreq.80.build.f_cpu=80000000L
esp32cammb.menu.CPUFreq.40=40MHz (40MHz XTAL)
esp32cammb.menu.CPUFreq.40.build.f_cpu=40000000L
esp32cammb.menu.CPUFreq.26=26MHz (26MHz XTAL)
esp32cammb.menu.CPUFreq.26.build.f_cpu=26000000L
esp32cammb.menu.CPUFreq.20=20MHz (40MHz XTAL)
esp32cammb.menu.CPUFreq.20.build.f_cpu=20000000L
esp32cammb.menu.CPUFreq.13=13MHz (26MHz XTAL)
esp32cammb.menu.CPUFreq.13.build.f_cpu=13000000L
esp32cammb.menu.CPUFreq.10=10MHz (40MHz XTAL)
esp32cammb.menu.CPUFreq.10.build.f_cpu=10000000L

esp32cammb.menu.FlashMode.qio=QIO
esp32cammb.menu.FlashMode.qio.build.flash_mode=dio
esp32cammb.menu.FlashMode.qio.build.boot=qio
esp32cammb.menu.FlashMode.dio=DIO
esp32cammb.menu.FlashMode.dio.build.flash_mode=dio
esp32cammb.menu.FlashMode.dio.build.boot=dio
esp32cammb.menu.FlashMode.qout=QOUT
esp32cammb.menu.FlashMode.qout.build.flash_mode=dout
esp32cammb.menu.FlashMode.qout.build.boot=qout
esp32cammb.menu.FlashMode.dout=DOUT
esp32cammb.menu.FlashMode.dout.build.flash_mode=dout
esp32cammb.menu.FlashMode.dout.build.boot=dout

esp32cammb.menu.FlashFreq.80=80MHz
esp32cammb.menu.FlashFreq.80.build.flash_freq=80m
esp32cammb.menu.FlashFreq.40=40MHz
esp32cammb.menu.FlashFreq.40.build.flash_freq=40m

##############################################################

</code>
