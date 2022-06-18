local M, module = {}, ...
_G[module] = M

require("apprtctime")

M.print = function(...)
    for i = 1, #arg, 1 do
        arg[i] = tostring(arg[i])
    end
    print(apprtctime.ymdhmsm() .. " " .. table.concat(arg, " "))
end

M.channel_print = function(channel, ...)
    for i = 1, #arg, 1 do
        arg[i] = tostring(arg[i])
    end
    local str = apprtctime.ymdhmsm() .. " " .. table.concat(arg, " ")
    pcall(function(channel, str)
        channel:send(str)
    end, channel, str)
    print(str)
end

return M
