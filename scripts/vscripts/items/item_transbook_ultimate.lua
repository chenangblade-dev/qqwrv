function transbookultimate(keys)
	local caster = keys.caster
	local playerID = caster:GetPlayerID()

	if caster:HasItemInInventory("item_spellbook_normal") then
		local Item = caster:FindItemInInventory("item_spellbook_normal")
		if Item:GetCurrentCharges()>2 then 
			caster:AddItemByName("item_spellbook_ultimate")
			if Item:GetCurrentCharges() == 3 then 
				Item:RemoveSelf() 
			else 
				Item:SetCurrentCharges(Item:GetCurrentCharges()-3)
			end
		else
			msg.bottom("#book_cant_get", playerID)
			--Item:RemoveSelf() 
		end
	end
	local ability = keys.ability
	local charges = ability:GetCurrentCharges() - 1
	ability:RemoveSelf()
    --if charges <= 0 then
       -- ability:RemoveSelf()
    --else
        --ability:SetCurrentCharges(charges)
    --end	
end