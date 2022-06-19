local tm = rtctime.epoch2cal(rtctime.get())
print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

local pin = 1
pwm.setup(pin, 500, 512)
pwm.start(pin)
local duty = pwm.getduty(pin)
local inc = duty < 1023
local total = 6000
local timer = tmr.create()

timer:alarm(10, tmr.ALARM_AUTO, function()
   if total < 1 then
       timer:stop()
       timer:unregister()
       print("timer end")
       pwm.stop(pin)
       pwm.close(pin)
       print("pwm close")
       tm = rtctime.epoch2cal(rtctime.get())
       print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
       return
   end
   if inc then
       duty = duty + 1
       if duty >= 1022 then
           inc = false
       end
   else
       duty = duty - 1
       if duty <= 500 then
           inc = true
       end
   end
   pwm.setduty(pin, duty)
   total = total - 1
end)

-- timer:stop()
-- timer:unregister()
-- pwm.stop(pin)
-- pwm.close(pin)
