function OnChaofuheAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local modifier = target:FindModifierByNameAndCaster('modifier_chaofuhe_debuff_stacker', caster)
	if not modifier then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_chaofuhe_debuff_stacker", {})
		modifier = target:FindModifierByNameAndCaster('modifier_chaofuhe_debuff_stacker', caster)
	end

	-- 超负荷的BUG
	if not modifier then return end

	modifier:ForceRefresh()

	local stacks = target:GetModifierStackCount("modifier_chaofuhe_debuff_stacker", caster)
	local max_stacks = ability:GetSpecialValueFor( 'max_stacks' )
	if stacks == nil then stacks = 0 end
	stacks = stacks + 1
	if stacks > max_stacks then stacks = max_stacks end
	
	target:SetModifierStackCount('modifier_chaofuhe_debuff_stacker', caster, stacks)

	local stack_damage_per_attack = ability:GetSpecialValueFor('stack_damage_per_attack')
	local damage = stack_damage_per_attack * stacks
	ApplyDamage({
		attacker = caster,
		victim = target,
		ability = ability,
		damage = damage,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		damage_type = ability:GetAbilityDamageType()
	})

	local pid = ParticleManager:CreateParticle('particles/units/heroes/hero_razor/razor_unstable_current.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pid, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), false)
	ParticleManager:SetParticleControlEnt(pid, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), false)
	ParticleManager:ReleaseParticleIndex(pid)
end

function OnChaofuheOwnerDie(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability

	local pid = ParticleManager:CreateParticle("particles/items/chaofuhe.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(pid, 0, target:GetOrigin())
	local radius = ability:GetSpecialValueFor('explode_radius')
	ParticleManager:SetParticleControl(pid, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(pid)

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local damage = ability:GetSpecialValueFor('explode_damage')
	for _, target in pairs(targets) do
		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = ability,
			damage = damage,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			damage_type = ability:GetAbilityDamageType()
		})
	end

	EmitSoundOn('Hero_StormSpirit.Overload', target)
end