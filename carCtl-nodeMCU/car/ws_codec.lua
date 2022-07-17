-- 其中分包粘包使用了creationix的代码：
-- https://gitee.com/mirrors_creationix/lua-websocket/blob/master/websocket-codec.lua
require("appstring")
local M, module = {}, ...
_G[module] = M
package.loaded[module] = M

-- local function rand4()
--     -- Generate 32 bits of pseudo random data
--     local num = math.floor(math.random() * 0x100000000)
--     -- Return as a 4-byte string
--     return string.char(bit.rshift(num, 24), bit.band(bit.rshift(num, 16), 0xff), bit.band(bit.rshift(num, 8), 0xff), bit.band(num, 0xff))
-- end

M.decode = function(chunk)
    if #chunk < 2 then
        return
    end
    local second = string.byte(chunk, 2)
    local len = bit.band(second, 0x7f)
    local offset
    if len == 126 then
        if #chunk < 4 then
            return
        end
        len = bit.bor(bit.lshift(string.byte(chunk, 3), 8), string.byte(chunk, 4))
        offset = 4
    elseif len == 127 then
        if #chunk < 10 then
            return
        end
        len = bit.bor(bit.lshift(string.byte(chunk, 3), 24), bit.lshift(string.byte(chunk, 4), 16), bit.lshift(string.byte(chunk, 5), 8), string.byte(chunk, 6)) * 0x100000000 +
                  bit.bor(bit.lshift(string.byte(chunk, 7), 24), bit.lshift(string.byte(chunk, 8), 16), bit.lshift(string.byte(chunk, 9), 8), string.byte(chunk, 10))
        offset = 10
    else
        offset = 2
    end
    local mask = bit.band(second, 0x80) > 0
    if mask then
        offset = offset + 4
    end
    if #chunk < offset + len then
        return
    end

    local first = string.byte(chunk, 1)
    local payload = string.sub(chunk, offset + 1, offset + len)
    assert(#payload == len, "Length mismatch")
    if mask then

        local applyMask = function(data, mask)
            local bytes = {
                [0] = string.byte(mask, 1),
                [1] = string.byte(mask, 2),
                [2] = string.byte(mask, 3),
                [3] = string.byte(mask, 4)
            }
            local out = {}
            for i = 1, #data do
                out[i] = string.char(bit.bxor(string.byte(data, i), bytes[(i - 1) % 4]))
            end
            return table.concat(out)
        end

        payload = applyMask(payload, string.sub(chunk, offset - 3, offset))
        applyMask = nil
        collectgarbage()
    end
    local extra = string.sub(chunk, offset + len + 1)
    return {
        fin = bit.band(first, 0x80) > 0,
        rsv1 = bit.band(first, 0x40) > 0,
        rsv2 = bit.band(first, 0x20) > 0,
        rsv3 = bit.band(first, 0x10) > 0,
        opcode = bit.band(first, 0xf),
        mask = mask,
        len = len,
        payload = payload
    }, extra
end

-- local function encode(item)
--     if type(item) == "string" then
--         item = {
--             opcode = 2,
--             payload = item
--         }
--     end
--     local payload = item.payload
--     assert(type(payload) == "string", "payload must be string")
--     local len = #payload
--     local fin = item.fin
--     if fin == nil then
--         fin = true
--     end
--     local rsv1 = item.rsv1
--     local rsv2 = item.rsv2
--     local rsv3 = item.rsv3
--     local opcode = item.opcode or 2
--     local mask = item.mask
--     local chars = {string.char(bit.bor(fin and 0x80 or 0, rsv1 and 0x40 or 0, rsv2 and 0x20 or 0, rsv3 and 0x10 or 0, opcode)), string.char(bit.bor(mask and 0x80 or 0, len < 126 and len or (len < 0x10000) and 126 or 127))}
--     if len >= 0x10000 then
--         local high = len / 0x100000000
--         chars[3] = string.char(bit.band(bit.rshift(high, 24), 0xff))
--         chars[4] = string.char(bit.band(bit.rshift(high, 16), 0xff))
--         chars[5] = string.char(bit.band(bit.rshift(high, 8), 0xff))
--         chars[6] = string.char(bit.band(high, 0xff))
--         chars[7] = string.char(bit.band(bit.rshift(len, 24), 0xff))
--         chars[8] = string.char(bit.band(bit.rshift(len, 16), 0xff))
--         chars[9] = string.char(bit.band(bit.rshift(len, 8), 0xff))
--         chars[10] = string.char(bit.band(len, 0xff))
--     elseif len >= 126 then
--         chars[3] = string.char(bit.band(bit.rshift(len, 8), 0xff))
--         chars[4] = string.char(bit.band(len, 0xff))
--     end
--     if mask then
--         local key = rand4()

-- local applyMask = function(data, mask)
--   local bytes = {
--       [0] = string.byte(mask, 1),
--       [1] = string.byte(mask, 2),
--       [2] = string.byte(mask, 3),
--       [3] = string.byte(mask, 4)
--   }
--   local out = {}
--   for i = 1, #data do
--       out[i] = string.char(bit.bxor(string.byte(data, i), bytes[(i - 1) % 4]))
--   end
--   return table.concat(out)
-- end

-- local res = table.concat(chars) .. key .. applyMask(payload, key)
-- applyMask = nil
-- collectgarbage()
-- return res
--     end
--     return table.concat(chars) .. payload
-- end

M.handshakeRes = function(req)
    local acceptKey = function(key)
        local websocketGuid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
        return string.gsub(encoder.toBase64(crypto.hash("sha1", key .. websocketGuid)), "\n", "")
    end

    local accept = acceptKey(req.headers["Sec-WebSocket-Key"])
    local ress = "HTTP/1.1 101 Switching Protocols\r\nConnection: Upgrade\r\nUpgrade: websocket\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Accept: " .. accept .. "\r\n\r\n"
    acceptKey = nil
    accept = nil
    collectgarbage()
    return ress
end

M.handshakeRequest = function(reqStr)
    if string.sub(reqStr, 1, string.len("GET /")) ~= "GET /" then
        return nil
    end
    local f = string.find(reqStr, "Upgrade: websocket")
    if not f then
        return nil
    end

    local parseRequest = function(reqStr)
        local t = appstring.tsplit(reqStr, "\r\n")
        if not t then
            return nil
        end
        local req = {}
        local x = appstring.tsplit(t[1], " ")
        -- req.method = x[1]
        -- req.path = x[2]
        -- req.protocol = x[3]
        req.headers = {}
        for i = 2, #t do
            x = appstring.tsplit(t[i], ": ")
            if #x > 1 and x[1] == "Sec-WebSocket-Key" then
                local tmp = string.sub(t[i], string.len(x[1]) + 3)
                req.headers[x[1]] = tmp
                -- if x[1] == "Host" then
                --     local h = appstring.tsplit(tmp, ":")
                --     req.host = h[1]
                --     if #h > 1 then
                --         req.port = tonumber(h[2])
                --     end
                -- end
                break
            end
        end
        t = nil
        x = nil
        collectgarbage()
        return req
    end

    local req = parseRequest(reqStr)
    reqStr = nil
    parseRequest = nil
    collectgarbage()
    return req
end

return M
