local socket_print = function(channel, str)
    pcall(function(channel, str)
        channel:send(str)
    end, channel, str)
    print(str)
end

local websocketGuid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

local function acceptKey(key)
  return string.gsub(base64(sha1.binary(key .. websocketGuid)), "\n", "")
end

do
    if nil ~= wsvr then
        wsvr:close()
        wsvr = nil
    end
    print("check wsvr:" .. tostring(wsvr) .. ", ip:" .. tostring(wifi.sta.getip()))
    if not wsvr and wifi.sta.status() == wifi.STA_GOTIP then
        print("opening web socket server")

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

        wsvr = net.createServer(net.TCP, 120)
        local global_c = nil
        local port = 9999
        print("listen to port " .. tostring(port))
        wsvr:listen(port, function(c)
            if global_c ~= nil then
                global_c:close()
            end
            global_c = c
            c:on("connection", function(_, s)
                tm = rtctime.epoch2cal(rtctime.get())
                socket_print(c, string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

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
                socket_print(c, "on connection get " .. tostring(s) .. " and setup left_pin=" .. left_pin .. ", right_pin=" .. right_pin)
            end)
            c:on("reconnection", function(_, s)
                tm = rtctime.epoch2cal(rtctime.get())
                socket_print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

                do
                    pwm.setup(left_pin, 500, 0)
                    pwm.start(left_pin)
                    local duty = pwm.getduty(left_pin)
                    socket_print(c, "restart pwm " .. left_pin .. ", duty is " .. duty)
                end
                do
                    pwm.setup(right_pin, 500, 0)
                    pwm.start(right_pin)
                    local duty = pwm.getduty(right_pin)
                    socket_print(c, "restart pwm " .. right_pin .. ", duty is " .. duty)
                end
                socket_print(c, "on reconnection get " .. tostring(s) .. " and setup left_pin=" .. left_pin .. ", right_pin=" .. right_pin)
            end)
            local left_duty = 0
            local right_duty = 0
            c:on("receive", function(_, ctl)
                -- handshake
                if ctl contains then
                    
                end

                tm = rtctime.epoch2cal(rtctime.get())
                socket_print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

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
                socket_print(c, "get " .. ctl .. " and set left_duty=" .. left_duty .. ", right_duty=" .. right_duty)
                pwm.setduty(left_pin, left_duty)
                pwm.setduty(right_pin, right_duty)
            end)
            c:on("disconnection", function(_, s)
                tm = rtctime.epoch2cal(rtctime.get())
                print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

                pwm.stop(left_pin)
                pwm.close(left_pin)
                pwm.stop(right_pin)
                pwm.close(right_pin)
                print("on disconnect get" .. tostring(s) .. " and close pwm " .. left_pin .. " and pwm " .. right_pin)
            end)
        end)

        if wsvr then
            local ppp, ipp = wsvr:getaddr()
            print("tcp server on " .. tostring(ipp) .. ":" .. tostring(ppp))
        end

    end
end
return wsvr
