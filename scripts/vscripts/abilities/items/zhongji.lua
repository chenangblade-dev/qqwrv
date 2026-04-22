function OnZhongji(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not ability then return end
	local level = ability:GetLevel()

	local damage_base = ability:GetSpecialValueFor("damage_base")
	local damage_level = ability:GetSpecialValueFor("damage_level")
	local duration_melee = ability:GetSpecialValueFor("duration_melee")
	local duration_ranged = ability:GetSpecialValueFor("duration_ranged")

	local duration = duration_melee
	if caster:IsRangedAttacker() then
		duration = duration_ranged
	end

	local damage = damage_base + damage_level * level

	target:AddNewModifier(caster,ability,"modifier_stunned",{Duration = duration})
	ApplyDamage({
		attacker = caster,
		victim = target,
		ability = ability,
		damage = damage,
		damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR,
		damage_type = ability:GetAbilityDamageType(),
	})
end