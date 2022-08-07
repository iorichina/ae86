# ae86

## 介绍
自研小车，包括控制芯片程序、摄像头程序、硬件组装方法等

## 软件架构
软件架构说明


## 安装教程

### 1.  摄像头
* 开发板
ESP32-CAM

* Arduino IDE配置

下载<link>链接：https://pan.baidu.com/s/11VeqqeqsaVGWoVlMKvHGPg?pwd=ij54</link>

解压到arduino安装目录的hardware下，具体板块信息可以在
`hardware/espressif/esp32/README.md` ；

或者git仓库下载<link>https://github.com/espressif/arduino-esp32</link>（v1.0.6支持win7）

在hardware目录下新建`/hardware/espressif/esp32`，git仓库内容全部移动改目录下，然后在改目录中开启cmd，执行`git submodule update --init --recursive`，然后执行`/hardware/espressif/esp32/tools/get.exe`（需要python 3.8.x）

详细可以查看官方文档<link>https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html</link>

* 在目录下新建 wifi_config.h
<pre>
const char *sta_ssid = "******";
const char *sta_password = "******";
</pre>
* Board Type

ESP32 Arduino -> HK ESP32-CAM-MB
* 
1.  xxxx
2.  xxxx



### 2.  摄像头

#### 连接WIFI
* 文件：carCtl-nodeMCU\car\init.lua
* 修改WIFI的ssid和pwd 参数；