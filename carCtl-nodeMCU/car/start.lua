require("tmr")
require("enduser_setup")

function start_file(fileName)
    local b, r = false, nil
    local open_socket = function(t)
        applog.print("dofile", fileName)
        b, r = pcall(dofile, fileName)

        if not b then
            applog.print("dofile", fileName, "err:", r)
            return
        end
        if not r then
            applog.print("dofile", fileName, "not succ and again")
            return
        end

        local ok, json = pcall(sjson.encode, r)
        if ok then
            applog.print("dofile", fileName, "rst:", json)
        else
            applog.print("dofile", fileName, "rst:", r)
        end

        t:unregister()

    end
    local mytimer = tmr.create()
    mytimer:register(2000, tmr.ALARM_AUTO, open_socket)
    mytimer:start()
end

do
    enduser_setup.start()

    -- socket_client.lua
    -- socket_server.lua
    -- websocket_client.lua
    -- websocket_server.lua
    local fileName = "websocket_server.lua"
    applog.print("start", fileName)
    start_file(fileName)
end
