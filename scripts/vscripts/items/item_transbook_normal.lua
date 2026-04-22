function transbooknormal(keys)
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	--[[[local player = PlayerResource:GetPlayer(playerID)
	local hero = player:GetAssignedHero()
    local heroName = hero:GetUnitName()
    local team_target=hero:GetTeamNumber()


    ---hero:AddNewModifier(hero, nil, 'modifier_npc_dota_hero_night_stalker_1', {})
    hero:Destroy()
    DebugCreateHeroWithVariant(player, heroName, 2, team_target, false, function(unit)
        unit:SetControllableByPlayer(playerID, true)
    end)]]---
	if caster:HasItemInInventory("item_spellbook_ultimate") then
		local Item = caster:FindItemInInventory("item_spellbook_ultimate")
		caster:AddItemByName("item_spellbook_normal")
			if Item:GetCurrentCharges() == 1 then 
				Item:RemoveSelf() 
			else 
				Item:SetCurrentCharges(Item:GetCurrentCharges()-1)
			end
	else
		msg.bottom("#book_cant_get", playerID)
	end
	local ability = keys.ability
	local charges = ability:GetCurrentCharges() - 1
    --if charges <= 0 then
        ability:RemoveSelf()
    --else
        --ability:SetCurrentCharges(charges)
    --end	
end