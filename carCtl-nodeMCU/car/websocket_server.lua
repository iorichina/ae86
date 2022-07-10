require("net")
require("pwm")
require("wifi")
require("tmr")
local start = function(t)
    if nil ~= wsvr then
        t:unregister()
        return wsvr
    end
    applog.print("check wsvr:" .. tostring(wsvr) .. ", ip:" .. tostring(wifi.sta.getip()))
    if not wsvr and wifi.sta.status() == wifi.STA_GOTIP then
        local ws_codec = require("ws_codec")
        local function handleHttp(req)
            if not string.find(req, " HTTP/") then
                return nil
            end
            return "HTTP/1.1 403 Forbidden\r\n\r\n" .. "<strong>http request not allow</strong><pre>" .. req .. "</pre>"
        end

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
            right_duty = 0
            pwm.stop(left_pin)
            pwm.stop(right_pin)
            applog.print("stop pwm left_pin:", left_pin, " and pwm right_pin:", right_pin)
        end

        local autoTmr = tmr.create()
        autoTmr:register(2000, tmr.ALARM_SEMI, function(t)
            stopPwm()
            t:stop()
        end)
        local function autoPwm()
            autoTmr:start(true)
            startPwm()
        end

        local ip = wifi.sta.getip()
        applog.print("local ip:", ip)

        wsvr = net.createServer(net.TCP, 120)
        local port = 9999
        applog.print("websocket: listening to port ", port)
        wsvr:listen(port, function(ws)
            ws:on("connection", function(c, s)
                applog.print(c, "on ws connection~", s)
            end)
            ws:on("receive", function(c, ctl)
                -- handshake
                local handshake = ws_codec.handshakeRequest(ctl)
                if handshake then
                    applog.print(c, "on ws receive~", ctl)
                    local _, json = pcall(sjson.encode, handshake)
                    applog.print(c, "ws handshake request:", json)

                    local res = ws_codec.handshakeRes(handshake)
                    local _, json = pcall(sjson.encode, handshake)
                    applog.print(c, "ws handshake response:", res)

                    c:send(res)
                    return
                end
                -- http request
                local httpres = handleHttp(ctl)
                if httpres then
                    applog.print(c, "ws handleHttp response:", httpres)
                    c:send(httpres)
                    c:close()
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

                if ctl == "ping" then
                    c:send(ws_codec.encode("pong"))
                    return
                elseif ctl == "left" then
                    left_duty = 512
                    right_duty = 1023
                elseif ctl == "right" then
                    left_duty = 1023
                    right_duty = 512
                elseif ctl == "stop" then
                    left_duty = 0
                    right_duty = 0
                elseif ctl == "go" then
                    if left_duty < 900 then
                        left_duty = 900
                        right_duty = 900
                    else
                        left_duty = left_duty + 10
                        right_duty = right_duty + 10
                    end
                elseif string.sub(ctl, 1, 3) == "go_" then
                    local t = appstring.tsplit(ctl, "_") -- go_{shift}_{turn}
                    if not t then
                        return
                    end
                    local shift = tonumber(t[2])
                    local turn = tonumber(t[3])
                    if turn > 0 then
                        left_duty = turn
                    elseif turn < 0 then
                        right_duty = -turn
                    elseif shift > 0 then
                        left_duty = shift
                        right_duty = shift
                    elseif shift < 0 then
                        left_duty = -shift
                        right_duty = -shift
                    else
                        left_duty = 0
                        right_duty = 0
                    end
                end
                if left_duty > 1023 then
                    left_duty = 1023
                end
                if right_duty > 1023 then
                    right_duty = 1023
                end

                autoPwm()
            end)
            ws:on("disconnection", function(c, s)
                applog.print(c, "on ws disconnect~", s)
                c:on("connection", nil)
                c:on("receive", nil)
                c:on("disconnection", nil)
                c = nil
                collectgarbage("collect")
            end)
        end)

        local ppp, ipp = wsvr:getaddr()
        applog.print("ws server on ws://" .. ipp .. ":" .. ppp .. "/")

    end
    return wsvr
end

local mytimer = tmr.create()
mytimer:register(2000, tmr.ALARM_AUTO, start)
mytimer:start()
