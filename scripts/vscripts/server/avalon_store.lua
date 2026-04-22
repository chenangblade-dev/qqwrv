
-------------------------------------------------------------------------------------
-- 循环获取捐款情况
function LookAtDonatePaymentIsComplete( player, key )
	GameMode:SetContextThink( DoUniqueString( "LookAtDonatePaymentIsComplete" ), function ()
		Co(function ()
			local times = 0
			local url = "/donate/isComplete/"..key
			while true do
				times = times + 1

				local iStatusCode, szBody = get(url)
				if iStatusCode == 200 then
					local body = jsonDecode(szBody)
					if body ~= nil and body["status"] == "success" then
						CustomGameEventManager:Send_ServerToPlayer( player, "avalon_payment_complete", {} )
						break
					end
				end

				if times >= 400 then break end
				Sleep(1)
			end
		end)
	end, 5 )
end

-- 获取捐款网址
Event( "create_donate_order", function ( hData )
	local price = tonumber(hData.price) or 1.00
	if price <= 0.01 then return end
	local pay_method = hData.method
	if pay_method ~= "alipay" and pay_method ~= "wechatpay" then return end
	local url = ""
	local steamid = SteamID(hData.PlayerID)
	CustomNetTables:SetTableValue( "bom_plus", "donate_order_"..steamid, nil )

	retry( 6, function ()
		local iStatusCode, szBody = send( "/donate/prepay", {
			steamid = steamid,
			pay_method = pay_method,
			game = Game,
			price = string.format("%.2f", price)
		})
		if iStatusCode == 200 then
			local body = jsonDecode(szBody)
			if body ~= nil and body["result"] ~= nil then
				url = body["result"]
				LookAtDonatePaymentIsComplete( PlayerResource:GetPlayer( hData.PlayerID ), body["key"])
			end
			return true
		end
		Sleep(0.5)
	end)

	if url ~= "" then
		CustomNetTables:SetTableValue( "bom_plus", "donate_order_"..steamid, {url=url} )
	end

	return {url=url}
end)