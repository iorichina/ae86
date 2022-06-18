local M, module = {}, ...
_G[module] = M

sntp.sync(nil, nil, nil, true)

M.ymdhmsm = function()
    local sec, usec, _ = rtctime.get()
    local tm = rtctime.epoch2cal(sec)
    local ymd = (string.format("%04d/%02d/%02d %02d:%02d:%02d.%03d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"], usec / 1000))
    return ymd
end

M.ymdhms = function()
    local sec, _, _ = rtctime.get()
    local tm = rtctime.epoch2cal(sec)
    local ymd = (string.format("%04d/%02d/%02d %02d:%02d:%02d.%03d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    return ymd
end

return M
