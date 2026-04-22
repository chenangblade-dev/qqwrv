local m = class({})
 
function m:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
	}
end

function m:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor('magical_resistance')
end

function m:GetModifierStatusResistanceStacking()
	return self:GetAbility():GetSpecialValueFor('status_resistance')
end

function m:IsPurgable()
	return false
end

function m:IsHidden()
	return true
end

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

modifier_mofapifu = m