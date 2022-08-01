require("apprtctime")
require("appstring")
require("applog")

applog.print("init")

-- require("enduser_setup")
-- wifi.setmode(wifi.STATIONAP)
-- wifi.ap.config({ssid="iorihuang", auth=wifi.OPEN})
-- wifi.sta.config({ssid="inexistent"}) -- inexistent SSID
-- enduser_setup.manual(true)
-- applog.print("start enduser_setup")
-- enduser_setup.start()

--192.168.5.1
wifi.setmode(wifi.STATION)
wifi.sta.setip({ip="192.168.5.5", netmask="255.255.255.0", gateway="192.168.5.1"})
wifi.sta.config({ssid="iorihuang"})

-- lua启动环境时内存占用较大，延迟加载有助于缓解内存不足问题
local mytimer = tmr.create()
mytimer:register(4000, tmr.ALARM_SINGLE, function()
    -- socket_client.lua
    -- socket_server.lua
    -- websocket_client.lua
    -- websocket_server.lua
    local fileName = "websocket_server.lua"
    applog.print("start", fileName)
    dofile(fileName)
end)
mytimer:start()
collectgarbage()
