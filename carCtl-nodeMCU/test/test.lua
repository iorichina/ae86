-- local str = [==[
-- GET / HTTP/1.1
-- Host: 192.168.155.254:9999
-- Connection: Upgrade
-- Pragma: no-cache
-- Cache-Control: no-cache
-- User-Agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Mobile Safari/537.36
-- Upgrade: websocket
-- Origin: file://
-- Sec-WebSocket-Version: 13
-- Accept-Encoding: gzip, deflate
-- Accept-Language: zh-CN,zh;q=0.9
-- Sec-WebSocket-Key: OMc6Q7JAFEkiVhGPr40XmQ==
-- Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits
-- ]==]

-- b1,6
local top_right_pin = 6;local top_right_duty = 0;

-- a1,8
local bottom_right_pin = 8;local bottom_right_duty = 0;


-- b2,7
local top_left_pin = 7;local top_left_duty = 0;

-- a2,5
local bottom_left_pin = 5;local bottom_left_duty = 0;


pwm.setup(6, 1000, 0);pwm.start(6);pwm.setup(8, 1000, 0);pwm.start(8);
pwm.setduty(6, 0);pwm.setduty(8, 0);
pwm.setup(7, 1000, 0);pwm.start(7);pwm.setup(5, 1000, 0);pwm.start(5);
pwm.setduty(7, 0);pwm.setduty(5, 0);