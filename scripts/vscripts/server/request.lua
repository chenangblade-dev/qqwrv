
local serviceID = 'bom_33'

Game = ""
AvalonChargeServerAddress = "http://shushan.avalonstudio.cn"
AvalonChargeServerAddress_Test = "http://shushan.ds.icu"
if IsInToolsMode() then
    AvalonChargeServerAddress = "http://shushan.ds.icu" -- 测试模式也用线上的充值试试看
end

CheckDedicatedServer = true

local tinsert = table.insert

-- 生成随机字符串
function makeRandomString ()
	local text = ''
	for i=1,16 do
		text = text .. string.char(RandomInt(48, 122))
	end
	return text
end

-- 生成签名
function makeSign(params)
	local str = serviceID
	local serviceKey = GetDedicatedServerKeyV2(serviceID)
	local keys = {}

	for k in pairs(params) do
		table.insert(keys,k)
	end

	table.sort(keys)

	for _,k in pairs(keys) do
		local v = params[k]
		str = str .. k .. tostring(v)
	end
	str = str .. serviceKey
	return sha1.hmac(serviceKey, str)
end

-- 获取通用头
function getCommonHeader( hData )
	return {["x-service-id"]=serviceID,["x-service-sign"]=makeSign(hData or {})}
end

-- 发送请求
function get( szRoute, hData, fTimeout )
	return HttpGet( AvalonChargeServerAddress.."/api/v1"..szRoute, hData, {["x-service-id"]=serviceID}, fTimeout )
end
function send( szRoute, hData, fTimeout )
	return HttpPost( AvalonChargeServerAddress.."/api/v1"..szRoute, hData, getCommonHeader(hData), fTimeout )
end

function retry( iCount, hFunc )
	for i=1,iCount do
		if hFunc() == true then return end
	end
end


local readyFuncs = {}
function OnReady( hFunc )
	tinsert(readyFuncs, hFunc)
end

-- 服务器地址测试成功后触发OnReady
local start = function ()
	Log("[HttpRequest] Using Address: "..AvalonChargeServerAddress)

	for i,v in ipairs(readyFuncs) do
		v()
	end
	readyFuncs = nil
end

-- 测试服务器地址
GameMode:SetContextThink( DoUniqueString("Start"), function ()
	if CheckDedicatedServer then
		if not IsDedicatedServer() then
			return
		end
	end
	Co(function ()
		local canStart = false
		local iStatusCode = HttpGet( AvalonChargeServerAddress, nil, nil, 3000 )
		if iStatusCode == 200 then
			canStart = true
		else
			local iStatusCode = HttpGet( AvalonChargeServerAddress_Test, nil, nil, 3000 )
			if iStatusCode == 200 then
				AvalonChargeServerAddress = AvalonChargeServerAddress_Test
				canStart = true
			else
				error("can not connect server")
			end
		end
	end)
end, 0.03 )

local eventsTable = {}

-- 注册事件
function Event( event, func )
	eventsTable[event] = func
end

-- 触发服务器事件
function ServerEvent( event, PlayerID, data )
	local t = {}
	t.event = event
	t.PlayerID = PlayerID
	t._IsServer = true
	t.data = jsonEncode(data)
	EventHandleFunc(t)
end
_G["ServerEvent"] = ServerEvent

EventHandleFunc = function ( hData )
	local player = PlayerResource:GetPlayer(hData.PlayerID)
	if player == nil then return end

	local func = eventsTable[hData.event]
	if func == nil then return end

	local data = jsonDecode(hData.data)
	if data == nil then return end

	Co(function ()
		data.PlayerID = hData.PlayerID
		local result = func(data)
		if hData._IsServer ~= true and type(result) == "table" then
			CustomGameEventManager:Send_ServerToPlayer( player, "_avalon_service_events_res", {
				result=jsonEncode(result), queueIndex=hData.queueIndex} )
		end
	end)
end

-- 事件
CustomGameEventManager:RegisterListener( "_avalon_service_events_req", function ( e, hData )
	EventHandleFunc(hData)
end)

-- 此事件用于判断事件是否初始化完成
-- 在js如果没有立即响应那么可以视为没有初始化完成
Event( "avalon_service_events_ready", function ()
	return {}
end)


------------- 功能相关的请求 -------------

-- 创建天数记录
function CreateDayLog( day )
	local iStatusCode, szBody = send("/fn/daylog/create", {day=day})
	if iStatusCode == 200 then
		local body = jsonDecode(szBody)
		if body and body["result"] ~= nil then
			return body["result"]
		end
	end
	return -1
end

-- 获取应当操作的天数
-- 返回 int, boolean 即 天数，是否失效
function GetDayLog( id )
	local iStatusCode, szBody = get("/fn/daylog/get/"..id)
	if iStatusCode == 200 then
		local body = jsonDecode(szBody)
		if body and body["result"] ~= nil then
			return body["result"], body["invalid"]
		end
	end
	return -1, true
end


-- 获取当前时间，格式 2006-01-02 15:04:05
function GetTimeNow()
	local iStatusCode, szBody = get("/fn/time/now")
	if iStatusCode == 200 then
		return szBody
	end
	return ""
end

-- 获取当前时间戳
function GetTimeNowUnix()
	local iStatusCode, szBody = get("/fn/time/now/unix")
	if iStatusCode == 200 then
		return tonumber(szBody)
	end
	return 0
end

-----------------------------------------------------------

CPlayerRequest = {}
local playerRequestHandles = {}

-- 创建请求对象
function NewRequest( iPlayerID )
	local steamid = SteamID(iPlayerID)
	if steamid == "" or steamid == "0" then return end
	if playerRequestHandles[steamid] ~= nil then return end

	local id = ""
	retry(5, function ()
		local iStatusCode, szBody = get(string.format("/RequestID/%s/%s", Game, steamid))
		if iStatusCode == 200 then
			id = szBody
			return true
		end
	end)

	local handle = {
		iPlayerID=iPlayerID,
		szSteamID=steamid,
		ID=id,
		iQuestIndex = 0,
		hQuestList = {},
		hActionList = {},
		SendQuestIsRunning = false,
		HasQuestError = false,
		iSendQuestStartTime = 0,
	}
	setmetatable(handle, {__index=CPlayerRequest})
	playerRequestHandles[steamid] = handle
end

-- 获取请求对象
function RequestHandle( arg1 )
	local steamid = ""
	if type(arg1) == "number" then
		steamid = SteamID(arg1)
	elseif type(arg1) == "string" then
		steamid = arg1
	end
	return playerRequestHandles[steamid]
end

-- 发送GET请求
function CPlayerRequest:Get( szRoute, hData, fTimeout )
	local header = {["x-service-id"]=serviceID}
	header['x-request-id'] = self.ID
	header['x-game'] = Game
	header['x-steamid'] = self.szSteamID
	return HttpGet( AvalonChargeServerAddress.."/api/v1"..szRoute, hData, header, fTimeout )
end

-- 发送POST请求
function CPlayerRequest:Post( szRoute, hData, fTimeout )
	local header = getCommonHeader(hData)
	header['x-request-id'] = self.ID
	header['x-game'] = Game
	header['x-steamid'] = self.szSteamID
	return HttpPost( AvalonChargeServerAddress.."/api/v1"..szRoute, hData, header, fTimeout )
end