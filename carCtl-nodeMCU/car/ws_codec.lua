local gmatch = string.gmatch
local lower = string.lower
local gsub = string.gsub
local websocketGuid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

local function acceptKey(key)
    return gsub(base64(sha1.binary(key .. websocketGuid)), "\n", "")
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
local req_sample = {
    method = "GET",
    path = "/",
    protocol = "ws",
    host = "192.168.155.254",
    port = 9999,
    {"Connection", "Upgrade"},
    {"Upgrade", "websocket"},
    {"Sec-WebSocket-Version", "13"},
    {"Sec-WebSocket-Key", "kMgvb6KivsYVl2EHinJHZg=="}
}
local res_sample = [==[
HTTP/1.1 101 Switching Protocols
Connection: upgrade
Upgrade: websocket
Sec-WebSocket-Accept: xBe0pH4Tv71faNfPxaMMlkSruJU=

]==]

local res_prefix = [==[
HTTP/1.1 101 Switching Protocols
Connection: upgrade
Upgrade: websocket
Sec-WebSocket-Accept: ]==]

local function handleHandshake(head, protocol)

    -- WebSocket connections must be GET requests
    if not head.method == "GET" then
        return
    end

    -- Parse the headers for quick reading
    local headers = {}
    for i = 1, #head do
        local name, value = unpack(head[i])
        headers[lower(name)] = value
    end

    -- Must have 'Upgrade: websocket' and 'Connection: Upgrade' headers
    if not (headers.connection and headers.upgrade and headers.connection:lower():find("upgrade", 1, true) and headers.upgrade:lower():find("websocket", 1, true)) then
        return
    end

    -- Make sure it's a new client speaking v13 of the protocol
    -- if tonumber(headers["sec-websocket-version"]) < 13 then
    --     return nil, "only websocket protocol v13 supported"
    -- end

    local key = headers["sec-websocket-key"]
    if not key then
        return nil, "websocket security key missing"
    end

    -- If the server wants a specified protocol, check for it.
    if protocol then
        local foundProtocol = false
        local list = headers["sec-websocket-protocol"]
        if list then
            for item in gmatch(list, "[^, ]+") do
                if item == protocol then
                    foundProtocol = true
                    break
                end
            end
        end
        if not foundProtocol then
            return nil, "specified protocol missing in request"
        end
    end

    local accept = acceptKey(key)

    local res = {
        code = 101,
        {"Upgrade", "websocket"},
        {"Connection", "Upgrade"},
        {"Sec-WebSocket-Accept", accept}
    }
    if protocol then
        res[#res + 1] = {"Sec-WebSocket-Protocol", protocol}
    end

    return res, res_prefix + accept +"\n\r\n\r"
end

local function handshakeRequest(reqStr)
    
end

return {
    -- decode = decode,
    -- encode = encode,
    acceptKey = acceptKey,
    handleHandshake = handleHandshake
}
