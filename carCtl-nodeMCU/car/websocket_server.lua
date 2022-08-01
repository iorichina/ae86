require("net")
require("pwm")
require("wifi")
require("tmr")
require("ws_codec")

local function handleHttp(c, req)
    if not string.find(req, " HTTP/") then
        return nil
    end

    if string.find(req, "GET / HTTP/") then

        local sendFile = function(c, filename)
            if file.exists(filename .. '.gz') then
                filename = filename .. '.gz'
            elseif not file.exists(filename) then
                return nil
            end

            local guessType = function(filename)
                local types = {
                    ['.css'] = 'text/css',
                    ['.js'] = 'application/javascript',
                    ['.html'] = 'text/html',
                    ['.png'] = 'image/png',
                    ['.jpg'] = 'image/jpeg'
                }
                for ext, type in pairs(types) do
                    if string.sub(filename, -string.len(ext)) == ext or string.sub(filename, -string.len(ext .. '.gz')) == ext .. '.gz' then
                        return type
                    end
                end
                return 'text/plain'
            end

            local header = 'HTTP/1.1 200\r\n'
            header = header .. 'Content-Type: ' .. guessType(filename) .. '\r\n'

            if string.sub(filename, -3) == '.gz' then
                header = header .. 'Content-Encoding: gzip\r\n'
            end
            header = header .. '\r\n'

            applog.print('* Sending ', filename)
            local pos = 0
            local function doSend()
                file.open(filename, 'r')
                if file.seek('set', pos) == nil then
                    c:on("sent", nil)
                    c:close()
                    print('* Finished ', filename)
                    collectgarbage()
                else
                    local buf = file.read(512)
                    pos = pos + 512
                    c:send(buf)
                    buf = nil
                    collectgarbage()
                end
                file.close()
            end
            c:on('sent', doSend)
            c:send(header)
            return true
        end

        if sendFile(c, "car.html") then
            req = nil
            sendFile = nil
            applog.print(c, "ws handleHttp response:car.html")
            return true
        end
        req = nil
        sendFile = nil
        collectgarbage()
    end

    local httpres = "HTTP/1.1 200 OK\r\nCache-Control: max-age=7776000\r\nAccess-Control-Allow-Origin: *\r\n\r\n"
    c:send(httpres)
    c:close()
    req = nil
    c = nil
    httpres = nil
    collectgarbage()
    return true
end

wsvr = nil
local start = function(t)
    if nil ~= wsvr then
        t:unregister()
        return
    end

    if wifi.sta.status() ~= wifi.STA_GOTIP then
        applog.print("waiting for wifi connection")
        return
    end
    local ip = wifi.sta.getip()
    applog.print("local sta ip:", ip)
    -- local ip = wifi.ap.getip()
    -- applog.print("local ap ip:", ip)

    local left_pin = 5
    local left_duty = 0
    pwm.setup(left_pin, 1000, left_duty)

    local right_pin = 6
    local right_duty = 0
    pwm.setup(right_pin, 1000, right_duty)

    local function startPwm()
        pwm.start(left_pin)
        pwm.setduty(left_pin, left_duty)
        applog.print("start pwm left_pin:", left_pin, ", duty is ", left_duty)

        pwm.start(right_pin)
        pwm.setduty(right_pin, right_duty)
        applog.print("start pwm right_pin:", right_pin, ", duty is ", right_duty)
    end

    local function stopPwm()
        left_duty = 0
        pwm.setduty(left_pin, left_duty)
        pwm.stop(left_pin)

        right_duty = 0
        pwm.setduty(right_pin, right_duty)
        pwm.stop(right_pin)
        applog.print("stop pwm left_pin:", left_pin, " and pwm right_pin:", right_pin)
    end

    local autoTmr = tmr.create()
    autoTmr:register(400, tmr.ALARM_SEMI, function(t)
        stopPwm();
        t:stop();
    end)
    local function autoPwm()
        autoTmr:start(true);
        startPwm();
    end

    local port = 9999
    wsvr = net.createServer(net.TCP, 120)
    applog.print("websocket: listening to port ", port)
    wsvr:listen(port, function(cli)
        cli:on("connection", function(c, s)
            applog.print(c, "on ws connection~", s)
        end)
        cli:on("receive", function(c, ctl)
            -- ws handshake
            local handshake = ws_codec.handshakeRequest(ctl)
            if handshake then
                -- applog.print(c, "on ws receive~", ctl)
                -- local _, json = pcall(sjson.encode, handshake)
                -- applog.print(c, "ws handshake request:", json)

                local res = ws_codec.handshakeRes(handshake)
                -- applog.print(c, "ws handshake response:", res)

                c:send(res)
                handshake = nil
                res = nil
                -- json = nil
                collectgarbage()
                return
            end
            -- http request
            local httpres = handleHttp(c, ctl)
            if httpres then
                return
            end

            ctl = ws_codec.decode(ctl)
            if type(ctl) == "table" then
                applog.print(c, "on ws receive~", ctl.payload)
                ctl = ctl.payload
            else
                applog.print(c, "on ws receive~", type(ctl), "=", ctl)
                ctl = tostring(ctl)
            end
            if string.sub(ctl, 1, 3) == "go_" then
                local t = appstring.tsplit(ctl, "_") -- go_{left_duty}_{right_duty}
                if not t then
                    return
                end
                left_duty = tonumber(t[2])
                right_duty = tonumber(t[3])
            end
            if left_duty > 1023 then
                left_duty = 1023
            end
            if right_duty > 1023 then
                right_duty = 1023
            end

            autoPwm()
        end)
        cli:on("disconnection", function(c, s)
            applog.print(c, "on ws disconnect~", s)
            c:on("connection", nil)
            c:on("receive", nil)
            c:on("disconnection", nil)
            c = nil
            s = nil
            collectgarbage()
        end)
    end)

    local ppp, ipp = wsvr:getaddr()
    applog.print("ws server on ws://" .. ipp .. ":" .. ppp .. "/")
    t:unregister()
end

local mytimer = tmr.create()
mytimer:register(3000, tmr.ALARM_AUTO, start)
mytimer:start()
