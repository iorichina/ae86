local ws_codec = require("ws_codec")

do
    if nil ~= wsvr then
        wsvr:close()
        wsvr = nil
    end
    applog.print("check wsvr:" .. tostring(wsvr) .. ", ip:" .. tostring(wifi.sta.getip()))
    if not wsvr and wifi.sta.status() == wifi.STA_GOTIP then
        applog.print("opening web socket server")

        local left_pin = 5
        pwm.stop(left_pin)
        pwm.close(left_pin)
        applog.print("ws config left_pin:", left_pin)

        local right_pin = 6
        pwm.stop(right_pin)
        pwm.close(right_pin)
        applog.print("ws config right_pin:", left_pin)

        local ip = wifi.sta.getip()
        applog.print("ws local ip:", ip)

        wsvr = net.createServer(net.TCP, 120)
        local port = 9999
        applog.print("ws listen to port ", port)
        wsvr:listen(port, function(ws)
            ws:on("connection", function(c, s)
                applog.print(c, "on connection~", s)

                do
                    pwm.setup(left_pin, 500, 0)
                    pwm.start(left_pin)
                    local duty = pwm.getduty(left_pin)
                    applog.print(c, "start pwm left_pin:", left_pin, ", duty is ", duty)
                end
                do
                    pwm.setup(right_pin, 500, 0)
                    pwm.start(right_pin)
                    local duty = pwm.getduty(right_pin)
                    applog.print(c, "start pwm right_pin:", right_pin, ", duty is ", duty)
                end
            end)
            local left_duty = 0
            local right_duty = 0
            ws:on("receive", function(c, ctl)
                applog.print(c, "on receive~", ctl)

                -- handshake
                local handshake = ws_codec.handshakeRequest(ctl)
                if handshake then
                    local _, json = pcall(sjson.encode, handshake)
                    applog.print(c, "handshake request:", json)

                    local res = ws_codec.handshakeRes(handshake)
                    local _, json = pcall(sjson.encode, handshake)
                    applog.print(c, "handshake response:", res)

                    c:send(res)
                    return
                end

                if ctl == "ping" then
                    c:send("pong")
                    return
                elseif ctl == "go" then
                    if left_duty < 900 then
                        left_duty = 900
                        right_duty = 900
                    else
                        left_duty = left_duty + 10
                        right_duty = right_duty + 10
                    end
                elseif ctl == "left" then
                    left_duty = 512
                    right_duty = 1023
                elseif ctl == "right" then
                    left_duty = 1023
                    right_duty = 512
                elseif ctl == "stop" then
                    left_duty = 0
                    right_duty = 0
                end
                if left_duty > 1023 then
                    left_duty = 1023
                end
                if right_duty > 1023 then
                    right_duty = 1023
                end

                applog.print(c, "set left_duty=", left_duty, ", right_duty=", right_duty)
                pwm.setduty(left_pin, left_duty)
                pwm.setduty(right_pin, right_duty)
            end)
            ws:on("disconnection", function(c, s)
                applog.print("on disconnect~", s)

                pwm.stop(left_pin)
                pwm.close(left_pin)
                pwm.stop(right_pin)
                pwm.close(right_pin)
                applog.print("on disconnect close pwm left_pin:", left_pin, " and pwm right_pin:", right_pin)
            end)
        end)

        local ppp, ipp = wsvr:getaddr()
        applog.print("ws server on ws://", ipp, ":", ppp, "/")

    end
end
return wsvr
