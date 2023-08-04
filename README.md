# ae86

## 1、介绍
自研小车，包括控制芯片程序、摄像头程序、硬件组装方法等

## 2、软件架构
软件架构说明


## 3、Arduino使用说明

### （1）Arduino IDE配置
IDE版本要求1.8及以上

安装方法见： <link>https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html</link>

* 使用IDE自带工具安装esp32开发板库

<pre>
* 配置Boards Manager URLs : https://espressif.github.io/arduino-esp32/package_esp32_index.json
* 工具 -> 管理库： esp32
* 选择对应版本并安装
</pre>

支持win7的版本：<pre>git checkout 1.0.6</pre>

或者最新版本：<pre>git checkout 2.0.*</pre>

查看源码

git仓库：<link>https://gitee.com/mirrors/arduino-esp32</link>

或者git仓库<link>https://github.com/espressif/arduino-esp32</link>

* 自助安装esp32开发库

esp32开发库安装目录：
`[ARDUINO_SKETCHBOOK_DIR]/hardware/espressif/esp32`，
其中`[ARDUINO_SKETCHBOOK_DIR]`一般是指`C:/Users/[YOUR_USER_NAME]/Documents/Arduino`，可以在IDE的“首选项”里查看；

git仓库clone到安装目录
![git-clone](git-clone.png)

在安装目录开启cmd，执行`git submodule update --init --recursive`

最后执行`tools/get.exe`

### （2）摄像头开发板
工具 -> 开发板 -> ESP32 Arduino -> AI Thinker ESP32-CAM

### （3）MH-ET ESP32开发板（电压检测、红外）
1. 开发板类型： ESP32 Dev Module
2. 管脚：ESP32 DEVKIT PINOUT
3. 模组：[ESP32-WROOM-32E](https://www.espressif.com.cn/sites/default/files/documentation/esp32-wroom-32e_esp32-wroom-32ue_datasheet_cn.pdf")


## 4、开发目录说明

### （1）carCtl-nodeMCU
自制简单小车控制代码
* wifi配置文件：carCtl-nodeMCU\car\start.lua
* 修改WIFI的ssid和pwd 参数

### （2）esp32Camera
WEB-SOCKET和HTTP摄像头:OV2640
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

### （4）IRReceive
红外接收器端

### （5）IRSend
红外发射端

### （6）IRSendAndReceive
红外发射和接收聚合

### （7）sensorModuleTimesTest
电压检测模块的测试代码

### （8）voltage
电压检测模块的正式代码