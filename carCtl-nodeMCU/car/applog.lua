require("apprtctime")
local M, module = {}, ...
_G[module] = M
package.loaded[module] = M

M.print = function(...)
    for i = 1, #arg, 1 do
        arg[i] = tostring(arg[i])
    end
    print(apprtctime.hmsm() .. " " .. table.concat(arg, " "))
end

M.channel_print = function(channel, encoder, ...)
    for i = 1, #arg, 1 do
        arg[i] = tostring(arg[i])
    end
    local str = apprtctime.hmsm()
    if type(encoder) == "string" then
        str = str .. " " .. encoder
        encoder = nil
    end
    if #arg > 1 then
        str = str .. " " .. table.concat(arg, " ")
    end
    pcall(function(channel, encoder, str)
        if encoder then
            channel:send(encoder(str))
        else
            channel:send(str)
        end
    end, channel, encoder, str)
    print(apprtctime.hmsm() .. " " .. tostring(channel) .. " " .. table.concat(arg, " "))
end

return M
