-- wifi.mode(wifi.STATIONAP)
--
-- wifi.mode(wifi.STATION)
-- wifi.sta.setip({
--     ip = "192.168.5.5",
--     netmask = "255.255.255.0",
--     gateway = "192.168.5.1"
-- })
wifi_sta_getip = function()
    return nil
end
-- wifi.sta.on("got_ip", function(ev, info)
--     wifi_sta_getip = function()
--         return info.ip, info.netmask, info.gw
--     end
--     wifi.sta.on("got_ip", nil)
-- end)
-- wifi.sta.config({
--     ssid = "ioricam",
--     pwd = "ioricam"
-- })
--
wifi.mode(wifi.SOFTAP)
local ap_cfg = {
    ip = "192.168.4.1",
    netmask = "255.255.255.0",
    gateway = "192.168.4.1"
}
wifi.ap.setip(ap_cfg)
wifi_ap_getip = function()
    return ap_cfg.ip, ap_cfg.netmask, ap_cfg.gateway
end
wifi.ap.config({
    ssid = "iorinode",
    pwd = "iorinode",
    channel = 10
})
wifi.start()

-- init pin for car cmd
pwm.setup(6, 1000, 0);
pwm.start(6);
pwm.setup(8, 1000, 0);
pwm.start(8);
pwm.setup(7, 1000, 0);
pwm.start(7);
pwm.setup(5, 1000, 0);
pwm.start(5);

require("apprtctime")
require("appstring")
require("applog")

-- lua启动环境时内存占用较大，延迟加载有助于缓解内存不足问题
local mytimer = tmr.create()
mytimer:register(5000, tmr.ALARM_SINGLE, function()
    local fileName = "hwss.lua"
    applog.print("start", fileName)
    dofile(fileName)
end)
mytimer:start()
collectgarbage()
