require("apprtctime")
require("appstring")
require("applog")

applog.print("init")

require("enduser_setup")
applog.print("start enduser_setup")
enduser_setup.start()

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
