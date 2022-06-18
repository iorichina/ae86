require("rtctime_utils")
require("string_utils")
require("applog")

applog.print("init")

-- web page for start socket
pcall(dofile, "start.lua")
