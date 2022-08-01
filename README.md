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
