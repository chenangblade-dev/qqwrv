Game = "dota_arena"
CheckDedicatedServer = false

if IsInToolsMode() then
	CheckDedicatedServer = false

	-- 本地测试
	-- Address = "http://localhost:22336"
	-- AddressBak = "http://localhost:22336"

	-- 开发服务器测试
	-- Address = "http://api.avalonstudio.cn"
	-- AddressBak = "http://api.avalonstudio.cn"
end

-- 系统初始化完成
OnReady(function ()
end)