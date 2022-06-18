local string_utils = require("string_utils")
local gmatch = string.gmatch
local lower = string.lower
local gsub = string.gsub
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
    local ok, json = pcall(sjson.encode, req)
    print(json)
    print(req["host"])
    print(req.headers["Sec-WebSocket-Key"])
    local accept = acceptKey(req.headers["Sec-WebSocket-Key"])
    print("accept:" .. accept)
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
    local t = string_utils.tsplit(reqStr, "\r\n")
    if not t then
        return nil
    end
    print("tsplit:" .. table.concat(t, "&&&\n"))
    print()
    print()
    local req = {}
    local x = string_utils.tsplit(t[1], " ")
    req.method = x[1]
    req.path = x[2]
    req.protocol = x[3]
    print("req1:" .. table.concat(x, "==="))
    req.headers = {}
    for i = 2, #t do
        x = string_utils.tsplit(t[i], ": ")
        print("req" .. tostring(i) .. ":" .. table.concat(x, "==="))
        if #x > 1 then
            local tmp = string.sub(t[i], string.len(x[1]) + 3)
            req.headers[x[1]] = tmp
            if x[1] == "Host" then
                local h = string_utils.tsplit(tmp, ":")
                req.host = h[1]
                if #h > 1 then
                    req.port = tonumber(h[2])
                end
            end
        end
    end
    local ok, json = pcall(sjson.encode, req)
    print(json)
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
    acceptKey = acceptKey,
    handshakeRequest = handshakeRequest,
    handshakeRes = handshakeRes
}
