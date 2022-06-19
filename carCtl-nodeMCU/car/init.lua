require("apprtctime")
require("appstring")
require("applog")

applog.print("init")

-- web page for start socket
pcall(dofile, "start.lua")
