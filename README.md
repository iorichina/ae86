# ae86

#### 介绍
自研小车，包括控制芯片程序、摄像头程序、硬件组装方法等

#### 软件架构
软件架构说明


#### 安装教程

1.  esp32Camera
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

* 
1.  xxxx
2.  xxxx

#### 使用说明

1.  xxxx
2.  xxxx
3.  xxxx

#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request


#### 特技

1.  使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2.  Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3.  你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4.  [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5.  Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6.  Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
