local socket_print = function(channel, str)
    pcall(function(channel, str)
        channel:send(str)
    end, channel, str)
end
do
    if nil ~= clt then
        clt:close()
        clt = nil
    end
    print("clt:" .. tostring(clt) .. ", ip:" .. tostring(wifi.sta.getip()))
    if not clt and wifi.sta.status() == wifi.STA_GOTIP then
        print("create socket client")

        local tm = rtctime.epoch2cal(rtctime.get())
        print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

        local left_pin = 5
        pwm.stop(left_pin)
        pwm.close(left_pin)

        local right_pin = 6
        pwm.stop(right_pin)
        pwm.close(right_pin)

        local ip = wifi.sta.getip()
        print("local ip:" .. ip)

        local connecttt = function(t)
            print("connecting to 192.168.3.31:9999")
            clt:connect(9999, "192.168.3.31")
        end

        local mytimer = tmr.create()
        mytimer:register(5000, tmr.ALARM_SEMI, function(t)
            connecttt()
        end)

        clt = net.createConnection(net.TCP, 0)
        -- Wait for connection before sending.
        clt:on("connection", function(sck, c)
            tm = rtctime.epoch2cal(rtctime.get())
            socket_print(c, string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

            local lp, li = clt:getaddr()
            print("local ip:" .. tostring(lp) .. ", local port:" .. tostring(li))
            local rp, ri = clt:getpeer()
            print("remote ip:" .. tostring(rp) .. ", remote port:" .. tostring(ri))

            do
                pwm.setup(left_pin, 500, 0)
                pwm.start(left_pin)
                local duty = pwm.getduty(left_pin)
                socket_print(c, "start pwm " .. left_pin .. ", duty is " .. duty)
            end
            do
                pwm.setup(right_pin, 500, 0)
                pwm.start(right_pin)
                local duty = pwm.getduty(right_pin)
                socket_print(c, "start pwm " .. right_pin .. ", duty is " .. duty)
            end
        end)

        clt:on("disconnection", function(sck, c)
            tm = rtctime.epoch2cal(rtctime.get())
            print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

            pwm.stop(left_pin)
            pwm.close(left_pin)
            pwm.stop(right_pin)
            pwm.close(right_pin)
            print("disconnect and close pwm " .. left_pin .. " and pwm " .. right_pin)
            print("disconnect by " .. tostring(c))

            mytimer:start()
        end)

        local left_duty = 0
        local right_duty = 0
        clt:on("receive", function(sck, c)
            tm = rtctime.epoch2cal(rtctime.get())
            socket_print(c, string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

            if ctl == "go" then
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
            socket_print(c, "get " .. ctl .. " and set left_duty=" .. left_duty .. ", right_duty=" .. right_duty)
            pwm.setduty(left_pin, left_duty)
            pwm.setduty(right_pin, right_duty)
        end)

        mytimer:start()
    end
end
return clt
