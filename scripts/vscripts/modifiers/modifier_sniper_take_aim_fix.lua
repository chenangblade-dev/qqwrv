local m = class({})

function m:OnCreated(kv)
	if not IsServer() then return end

end


function m:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function m:GetModifierAttackRangeBonus()
	return 400
end

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end



function m:RemoveOnDeath()
	return false
end

modifier_sniper_take_aim_fix = m