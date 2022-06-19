--[[
    其中分包粘包使用了creationix的代码：
    https://gitee.com/mirrors_creationix/lua-websocket/blob/master/websocket-codec.lua
]]
local appstring = require("appstring")

local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local rshift = bit.rshift
local lshift = bit.lshift
local char = string.char
local byte = string.byte
local sub = string.sub
local gmatch = string.gmatch
local lower = string.lower
local gsub = string.gsub
local concat = table.concat
local floor = math.floor
local random = math.random

local function rand4()
  -- Generate 32 bits of pseudo random data
  local num = floor(random() * 0x100000000)
  -- Return as a 4-byte string
  return char(
    rshift(num, 24),
    band(rshift(num, 16), 0xff),
    band(rshift(num, 8), 0xff),
    band(num, 0xff)
  )
end

local function applyMask(data, mask)
  local bytes = {
    [0] = byte(mask, 1),
    [1] = byte(mask, 2),
    [2] = byte(mask, 3),
    [3] = byte(mask, 4)
  }
  local out = {}
  for i = 1, #data do
    out[i] = char(
      bxor(byte(data, i), bytes[(i - 1) % 4])
    )
  end
  return concat(out)
end

local function decode(chunk)
  if #chunk < 2 then return end
  local second = byte(chunk, 2)
  local len = band(second, 0x7f)
  local offset
  if len == 126 then
    if #chunk < 4 then return end
    len = bor(
      lshift(byte(chunk, 3), 8),
      byte(chunk, 4))
    offset = 4
  elseif len == 127 then
    if #chunk < 10 then return end
    len = bor(
      lshift(byte(chunk, 3), 24),
      lshift(byte(chunk, 4), 16),
      lshift(byte(chunk, 5), 8),
      byte(chunk, 6)
    ) * 0x100000000 + bor(
      lshift(byte(chunk, 7), 24),
      lshift(byte(chunk, 8), 16),
      lshift(byte(chunk, 9), 8),
      byte(chunk, 10)
    )
    offset = 10
  else
    offset = 2
  end
  local mask = band(second, 0x80) > 0
  if mask then
    offset = offset + 4
  end
  if #chunk < offset + len then return end

  local first = byte(chunk, 1)
  local payload = sub(chunk, offset + 1, offset + len)
  assert(#payload == len, "Length mismatch")
  if mask then
    payload = applyMask(payload, sub(chunk, offset - 3, offset))
  end
  local extra = sub(chunk, offset + len + 1)
  return {
    fin = band(first, 0x80) > 0,
    rsv1 = band(first, 0x40) > 0,
    rsv2 = band(first, 0x20) > 0,
    rsv3 = band(first, 0x10) > 0,
    opcode = band(first, 0xf),
    mask = mask,
    len = len,
    payload = payload
  }, extra
end

local function encode(item)
  if type(item) == "string" then
    item = {
      opcode = 2,
      payload = item
    }
  end
  local payload = item.payload
  assert(type(payload) == "string", "payload must be string")
  local len = #payload
  local fin = item.fin
  if fin == nil then fin = true end
  local rsv1 = item.rsv1
  local rsv2 = item.rsv2
  local rsv3 = item.rsv3
  local opcode = item.opcode or 2
  local mask = item.mask
  local chars = {
    char(bor(
      fin and 0x80 or 0,
      rsv1 and 0x40 or 0,
      rsv2 and 0x20 or 0,
      rsv3 and 0x10 or 0,
      opcode
    )),
    char(bor(
      mask and 0x80 or 0,
      len < 126 and len or (len < 0x10000) and 126 or 127
    ))
  }
  if len >= 0x10000 then
    local high = len / 0x100000000
    chars[3] = char(band(rshift(high, 24), 0xff))
    chars[4] = char(band(rshift(high, 16), 0xff))
    chars[5] = char(band(rshift(high, 8), 0xff))
    chars[6] = char(band(high, 0xff))
    chars[7] = char(band(rshift(len, 24), 0xff))
    chars[8] = char(band(rshift(len, 16), 0xff))
    chars[9] = char(band(rshift(len, 8), 0xff))
    chars[10] = char(band(len, 0xff))
  elseif len >= 126 then
    chars[3] = char(band(rshift(len, 8), 0xff))
    chars[4] = char(band(len, 0xff))
  end
  if mask then
    local key = rand4()
    return concat(chars) .. key .. applyMask(payload, key)
  end
  return concat(chars) .. payload
end

local websocketGuid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

local function acceptKey(key)
    return gsub(encoder.toBase64(crypto.hash("sha1", key .. websocketGuid)), "\n", "")
end

local req_sample = {
    method = "GET",
    path = "/",
    protocol = "ws",
    host = "192.168.155.254",
    port = 9999,
    {"Connection", "Upgrade"},
    {"Upgrade", "websocket"},
    {"Sec-WebSocket-Version", "13"},
    {"Sec-WebSocket-Key", "OMc6Q7JAFEkiVhGPr40XmQ=="}
}

local res_sample = [==[
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: /gsA7NI7lNULVWN5OtqsF4di2Kk=

]==]

local res_prefix = "HTTP/1.1 101 Switching Protocols\r\nConnection: Upgrade\r\nUpgrade: websocket\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Accept: "

local function handshakeRes(req)
    local accept = acceptKey(req.headers["Sec-WebSocket-Key"])
    local ress = res_prefix .. accept .. "\r\n"
    -- if req.headers["Sec-WebSocket-Extensions"] then
    --     ress = ress .. "Sec-WebSocket-Extensions: " .. req.headers["Sec-WebSocket-Extensions"] .. "\r\n"
    -- end
    return  ress .. "\r\n"
end

--[==[
GET / HTTP/1.1
Host: 192.168.155.254:9999
Connection: Upgrade
Pragma: no-cache
Cache-Control: no-cache
User-Agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Mobile Safari/537.36
Upgrade: websocket
Origin: file://
Sec-WebSocket-Version: 13
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.9
Sec-WebSocket-Key: OMc6Q7JAFEkiVhGPr40XmQ==
Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits

]==]
local function parseRequest(reqStr)
    local t = appstring.tsplit(reqStr, "\r\n")
    if not t then
        return nil
    end
    local req = {}
    local x = appstring.tsplit(t[1], " ")
    req.method = x[1]
    req.path = x[2]
    req.protocol = x[3]
    req.headers = {}
    for i = 2, #t do
        x = appstring.tsplit(t[i], ": ")
        if #x > 1 then
            local tmp = string.sub(t[i], string.len(x[1]) + 3)
            req.headers[x[1]] = tmp
            if x[1] == "Host" then
                local h = appstring.tsplit(tmp, ":")
                req.host = h[1]
                if #h > 1 then
                    req.port = tonumber(h[2])
                end
            end
        end
    end
    return req
end
local function handshakeRequest(reqStr)
    if string.sub(reqStr, 1, string.len("GET /")) ~= "GET /" then
        return nil
    end
    local f = string.find(reqStr, "Upgrade: websocket")
    if not f then
        return nil
    end
    return parseRequest(reqStr)
end
return {
    decode = decode,
    encode = encode,
    acceptKey = acceptKey,
    handshakeRequest = handshakeRequest,
    handshakeRes = handshakeRes
}
