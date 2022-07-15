require("apprtctime")
require("appstring")
require("applog")

applog.print("init")

require("enduser_setup")
applog.print("start enduser_setup")
enduser_setup.start()

-- socket_client.lua
-- socket_server.lua
-- websocket_client.lua
-- websocket_server.lua
local fileName = "websocket_server.lua"
applog.print("start", fileName)
dofile(fileName)

collectgarbage()