local m = class({})

function m:IsPurgable()
	return false
end

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function m:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function m:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	}
end

function m:GetAbsoluteNoDamagePhysical()
	return 1
end

function m:GetAbsoluteNoDamageMagical()
	return 1
end

function m:GetAbsoluteNoDamagePure()
	return 1
end

function m:GetMinHealth()
	return 99999
end

modifier_candy_bucket = m