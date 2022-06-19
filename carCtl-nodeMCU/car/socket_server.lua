do
    if nil ~= svr then
        svr:close()
        svr = nil
    end
    applog.print("check svr:" .. tostring(svr) .. ", ip:" .. tostring(wifi.sta.getip()))
    if not svr and wifi.sta.status() == wifi.STA_GOTIP then
        applog.print("opening tcp socket server")

        local left_pin = 5
        pwm.stop(left_pin)
        pwm.close(left_pin)

        local right_pin = 6
        pwm.stop(right_pin)
        pwm.close(right_pin)

        local ip = wifi.sta.getip()
        applog.print("local ip:" .. ip)

        svr = net.createServer(net.TCP, 120)
        local port = 8080
        applog.print("listen to port " .. tostring(port))
        svr:listen(port, function(ts)
            ts:on("connection", function(c, s)
                applog.print(c, "on connection~")

                do
                    pwm.setup(left_pin, 500, 0)
                    pwm.start(left_pin)
                    local duty = pwm.getduty(left_pin)
                    applog.print(c, "start pwm " .. left_pin .. ", duty is " .. duty)
                end
                do
                    pwm.setup(right_pin, 500, 0)
                    pwm.start(right_pin)
                    local duty = pwm.getduty(right_pin)
                    applog.print(c, "start pwm " .. right_pin .. ", duty is " .. duty)
                end
            end)
            local left_duty = 0
            local right_duty = 0
            ts:on("receive", function(c, ctl)
                applog.print(c, "on receive~", ctl)

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
                applog.channel_print(c, "get " .. ctl .. " and set left_duty=" .. left_duty .. ", right_duty=" .. right_duty)
                pwm.setduty(left_pin, left_duty)
                pwm.setduty(right_pin, right_duty)
            end)
            ts:on("disconnection", function(c, s)
                applog.print(c, "on disconnect~", s)

                pwm.stop(left_pin)
                pwm.close(left_pin)
                pwm.stop(right_pin)
                pwm.close(right_pin)
                applog.print(c, "close pwm " .. left_pin .. " and pwm " .. right_pin)
            end)
        end)

        if svr then
            local ppp, ipp = svr:getaddr()
            applog.print("tcp server on " .. tostring(ipp) .. ":" .. tostring(ppp))
        end

    end
end
return svr
