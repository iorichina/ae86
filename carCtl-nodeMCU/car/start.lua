require("tmr")
require("enduser_setup")

do
    enduser_setup.start()

    -- socket_client.lua
    -- socket_server.lua
    -- websocket_client.lua
    -- websocket_server.lua
    local fileName = "websocket_server.lua"
    applog.print("start", fileName)
    dofile(fileName)
end
