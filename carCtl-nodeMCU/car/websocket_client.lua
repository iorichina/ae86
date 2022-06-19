-- local ws = websocket.createClient()
-- ws:on("connection", function(ws, s)
--   print('got ws connection', s)
-- end)
-- ws:on("receive", function(_, msg, opcode)
--   print('got message:', msg, opcode) -- opcode is 1 for text message, 2 for binary
-- end)
-- ws:on("close", function(_, status)
--   print('connection closed', status)
--   ws = nil -- required to Lua gc the websocket client
-- end)
-- ws:connect('ws://121.40.165.18:8800')

local wsclient = net.createConnection(net.TCP, 0)
wsclient:on("receive", function(sck, c)
    print("onreceive")
    print(c)
end)
-- Wait for connection before sending.
wsclient:on("connection", function(sck, c)
    print("onconnection")
    -- 'Connection: close' rather than 'Connection: keep-alive' to have server
    -- initiate a close of the connection after final response (frees memory
    -- earlier here), https://tools.ietf.org/html/rfc7230#section-6.6
    sck:send("GET / HTTP/1.1\r\nHost: 192.168.155.254:9999\r\nConnection: Upgrade\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nUser-Agent: testLUA\r\nUpgrade: websocket\r\nOrigin: file://\r\nSec-WebSocket-Version: 13\r\nAccept-Encoding: gzip, deflate\r\nAccept-Language: zh-CN,zh;q=0.9\r\nSec-WebSocket-Key: OMc6Q7JAFEkiVhGPr40XmQ==\r\nSec-WebSocket-Extensions: permessage-deflate; client_max_window_bits\r\n\r\n")
end)
wsclient:on("disconnection", function(sck, s)
    print("ondisconnection")
    print(tostring(s))
end)
wsclient:connect(9999, "192.168.155.254")
