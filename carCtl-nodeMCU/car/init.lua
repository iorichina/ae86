require("apprtctime")
require("appstring")
require("applog")

applog.print("init")

-- require("enduser_setup")
-- enduser_setup.manual(true)
-- applog.print("start enduser_setup")
-- enduser_setup.start()

wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid="iorinode", auth=wifi.OPEN})
-- wifi.sta.config({ssid="inexistent"}) -- inexistent SSID
wifi.sta.setip({ip="192.168.5.5", netmask="255.255.255.0", gateway="192.168.5.1"})
wifi.sta.config({ssid="ioricam"})

--192.168.5.1
-- wifi.setmode(wifi.STATION)
-- wifi.sta.setip({ip="192.168.5.5", netmask="255.255.255.0", gateway="192.168.5.1"})
-- wifi.sta.config({ssid="ioricam"})

-- lua启动环境时内存占用较大，延迟加载有助于缓解内存不足问题
local mytimer = tmr.create()
mytimer:register(5000, tmr.ALARM_SINGLE, function()
    -- local fileName = "socket_client.lua"
    -- local fileName = "socket_server.lua"
    -- local fileName = "websocket_client.lua"
    -- local fileName = "websocket_server.lua"
    -- local fileName = "websocket_server.lua"
    local fileName = "hwss.lua"
    applog.print("start", fileName)
    dofile(fileName)
end)
mytimer:start()
collectgarbage()
