local m = class({})

function m:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START}
end

function m:IsHidden()
	return true
end

function m:IsPurgable()
	return false
end

function m:OnAttackStart(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		local attacker = self:GetParent()
		attacker:RemoveModifierByName('modifier_baoji_critical_strike')

		local chance = self:GetAbility():GetSpecialValueFor('chance')
		if RollPercentage(chance) then
			attacker:AddNewModifier(attacker, self:GetAbility(), 'modifier_baoji_critical_strike', {})
		end
	end
end

modifier_baoji_passive = m