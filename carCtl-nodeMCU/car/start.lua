function start_socket_server()
    local open_socket = function(t)
        print("dofile socket_server.lua")
        local b, r = pcall(dofile, "socket_server.lua")

        if not b then
            print("dofile socket_server.lua err:" .. tostring(r))
            return
        end
        if not r then
            print("dofile socket_server.lua not succ and again")
            return
        end

        local ok, json = pcall(sjson.encode, r)
        if ok then
            print("dofile socket_server.lua rst:" .. tostring(json))
        else
            print("dofile socket_server.lua rst:" .. tostring(r))
        end

        t:unregister()

    end
    local mytimer = tmr.create()
    mytimer:register(2000, tmr.ALARM_AUTO, open_socket)
    mytimer:start()
end

function start_socket_client()
    local cb, cr = false, nil
    local open_client = function(t)
        if not cr then
            print("dofile socket_client.lua")
            cb, cr = pcall(dofile, "socket_client.lua")
        end
        local ok, json = pcall(sjson.encode, cr)
        if ok then
            print("dofile socket_client.lua rst:" .. tostring(cb) .. ":" .. tostring(json))
        else
            print("dofile socket_client.lua rst:" .. tostring(cb) .. ":" .. tostring(cr))
        end

        if not cb then
            print("dofile socket_client.lua err:" .. tostring(cr))
            return
        end
        if not cr then
            return
        end
        t:unregister()
        print("dofile socket_client.lua done")
    end
    local mytimerc = tmr.create()
    mytimerc:register(2000, tmr.ALARM_AUTO, open_client)
    mytimerc:start()
end

do
    enduser_setup.start()
    start_socket_server()
end