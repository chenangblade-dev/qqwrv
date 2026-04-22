function OnXuetieruniAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local modifier = target:FindModifierByNameAndCaster('modifier_xuetieruni_debuff', caster)
	if not modifier then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_xuetieruni_debuff", {})
		modifier = target:FindModifierByNameAndCaster('modifier_xuetieruni_debuff', caster)
	end

	if not modifier then return end
	
	modifier:ForceRefresh()

	local stacks = target:GetModifierStackCount("modifier_xuetieruni_debuff", caster)
	if stacks == nil then stacks = 0 end

	local max_armor_reduce_percentage = ability:GetSpecialValueFor("max_armor_reduce_percentage")
	local max_stacks = target:GetPhysicalArmorBaseValue() * max_armor_reduce_percentage / 100
	local armor_reduce = ability:GetSpecialValueFor("armor_reduce")

	if stacks >= max_stacks then
		return
	end

	local reduce_value = math.min(armor_reduce, max_stacks - stacks)

	stacks = reduce_value + stacks

	target:SetModifierStackCount('modifier_xuetieruni_debuff', caster, stacks)
end