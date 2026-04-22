AvalonServer = {}
setmetatable(AvalonServer, {__index = _G})

local list = {
	"server.core",
	"server.request",
	"server.avalon_store",
	"server.start",
}

for i,v in ipairs(list) do
    local fn, err = loadfile(v)
    assert(fn, err)
    setfenv(fn, AvalonServer)
    fn()
end