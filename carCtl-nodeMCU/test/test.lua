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

local left_pin = 5
pwm.setup(left_pin, 1000, 0)
pwm.stop(left_pin)
local left_duty = 1000
pwm.setup(left_pin, 1000, left_duty)
pwm.start(left_pin)

local right_pin = 6
pwm.setup(right_pin, 1000, 0)
pwm.stop(right_pin)
local right_duty = 0
pwm.setup(right_pin, 1000, right_duty)
pwm.start(right_pin)
