require("apprtctime")
require("appstring")
require("applog")

applog.print("init")

-- web page for start socket
local e = pcall(dofile, "start.lua")
applog.print("init started:", e)