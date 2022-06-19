local M, module = {}, ...
_G[module] = M

M.fsplit = function(s, sep, plain)
    local start = 1
    local done = false
    local function pass(i, j, ...)
        if i then
            local seg = s:sub(start, i - 1)
            start = j + 1
            return seg, ...
        else
            done = true
            return s:sub(start)
        end
    end
    return function()
        if done then
            return
        end
        if sep == '' then
            done = true
            return s
        end
        return pass(s:find(sep, start, plain))
    end
end
M.tsplit = function(s, sep)
    local t = {}
    for c in M.fsplit(s, sep) do
        table.insert(t, c)
    end
    return t
end

return M
