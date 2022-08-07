-- 带h桥的websocket版本
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
            local sta_ip = wifi.sta.getip()
            header = header .. 'sta-ip' .. sta_ip .. '\r\n\r\n'

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

        if sendFile(c, "hcar.html") then
            req = nil
            sendFile = nil
            applog.print(c, "ws handleHttp response:hcar.html")
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
local start = function(t_start)
    if nil ~= wsvr then
        t_start:unregister()
        return
    end

    applog.print("local ap ip:", wifi.ap.getip())
    applog.print("local sta ip:", wifi.sta.getip())

    -- b1,6
    local top_right_pin = 6
    local top_right_duty = 0
    pwm.setup(top_right_pin, 1000, top_right_duty)
    -- a1,8
    local bottom_right_pin = 8
    local bottom_right_duty = 0
    pwm.setup(bottom_right_pin, 1000, bottom_right_duty)

    -- b2,7
    local top_left_pin = 7
    local top_left_duty = 0
    pwm.setup(top_left_pin, 1000, top_left_duty)
    -- a2,5
    local bottom_left_pin = 5
    local bottom_left_duty = 0
    pwm.setup(bottom_left_pin, 1000, bottom_left_duty)

    local function startPwm()
        pwm.start(top_right_pin)
        pwm.setduty(top_right_pin, top_right_duty)
        applog.print("start pwm top_right:", top_right_pin, ", duty is ", top_right_duty)

        pwm.start(bottom_right_pin)
        pwm.setduty(bottom_right_pin, bottom_right_duty)
        applog.print("start pwm bottom_right:", bottom_right_pin, ", duty is ", bottom_right_duty)

        pwm.start(top_left_pin)
        pwm.setduty(top_left_pin, top_left_duty)
        applog.print("start pwm top_left:", top_left_pin, ", duty is ", top_left_duty)

        pwm.start(bottom_left_pin)
        pwm.setduty(bottom_left_pin, bottom_left_duty)
        applog.print("start pwm bottom_left:", bottom_left_pin, ", duty is ", bottom_left_duty)
    end

    local function stopPwm()
        top_right_duty = 0
        pwm.setduty(top_right_pin, top_right_duty)
        pwm.stop(top_right_pin)

        bottom_right_duty = 0
        pwm.setduty(bottom_right_pin, bottom_right_duty)
        pwm.stop(bottom_right_pin)

        top_left_duty = 0
        pwm.setduty(top_left_pin, top_left_duty)
        pwm.stop(top_left_pin)

        bottom_left_duty = 0
        pwm.setduty(bottom_left_pin, bottom_left_duty)
        pwm.stop(bottom_left_pin)

        applog.print("stop pwm top_right:", top_right_pin, " and bottom_right:", bottom_right_pin, " and top_left:", top_left_pin, " and bottom_left:", bottom_left_pin)
    end

    local autoTmr = tmr.create()
    autoTmr:register(400, tmr.ALARM_SEMI, function(t_auto)
        t_auto:stop();
        applog.print("autoTmr stopPwm")
        stopPwm();
    end)
    local function autoPwm()
        if top_right_duty == 0 and bottom_right_duty == 0 and top_left_duty == 0 and bottom_left_duty == 0 then
            autoTmr:stop()
            applog.print("autoPwm stopPwm")
            stopPwm()
            return
        end
        autoTmr:start(true);
        startPwm();
    end

    local port = 9998
    wsvr = net.createServer(net.TCP, 120)
    applog.print("websocket: listening to port ", port)
    wsvr:listen(port, function(cli)
        cli:on("connection", function(c, s)
            applog.print(c, "on ws connection~", s)
        end)
        cli:on("receive", function(c, req)
            local _start = tmr.now()
            -- ws handshake
            local handshake = ws_codec.handshakeRequest(req)
            if handshake then
                -- applog.print(c, "on ws receive~", req)
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
            local httpres = handleHttp(c, req)
            if httpres then
                return
            end

            applog.print("ws pre handler", tmr.now() - _start)
            local dec = ws_codec.decode(req)
            applog.print("ws decode handler", tmr.now() - _start)
            local ctl = ''
            if type(dec) == "table" then
                applog.print(c, "on ws receive~", dec.payload, ",", dec.opcode)
                ctl = dec.payload
            else
                applog.print(c, "on ws receive~", type(dec), "=", dec)
                ctl = tostring(dec)
            end
            if string.sub(ctl, 1, 5) == "ping_" then
                c:send(ws_codec.encode(ctl .. "_" .. (tmr.now() - _start)))
                applog.print("ws ping handler", tmr.now() - _start)
                collectgarbage()
                return
            elseif string.sub(ctl, 1, 3) == "go_" then
                applog.print("ws go handler", tmr.now() - _start)
                local t = appstring.tsplit(ctl, "_") -- go_{top_right_duty}_{bottom_right_duty}_{top_left_duty}_{bottom_left_duty}
                if not t then
                    return
                end
                top_right_duty = tonumber(t[2])
                bottom_right_duty = tonumber(t[3])
                top_left_duty = tonumber(t[4])
                bottom_left_duty = tonumber(t[5])
            end
            if top_right_duty > 1023 then
                top_right_duty = 1023
            end
            if top_right_duty < 0 then
                top_right_duty = 0
            end
            if bottom_right_duty > 1023 then
                bottom_right_duty = 1023
            end
            if bottom_right_duty < 0 then
                bottom_right_duty = 0
            end

            if top_left_duty > 1023 then
                top_left_duty = 1023
            end
            if top_left_duty < 0 then
                top_left_duty = 0
            end
            if bottom_left_duty > 1023 then
                bottom_left_duty = 1023
            end
            if bottom_left_duty < 0 then
                bottom_left_duty = 0
            end
            autoPwm()
            applog.print("ws receive handler", tmr.now() - _start)
            collectgarbage()
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
    t_start:unregister()
end

local mytimer = tmr.create()
mytimer:register(3000, tmr.ALARM_AUTO, start)
mytimer:start()
