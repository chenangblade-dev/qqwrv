function HengsaoqianjunCleave(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	local ability = keys.ability

	local damage_strength = ability:GetSpecialValueFor("damage_strength")
	local strength_value = caster:GetStrength()

	local cleave_starting_width = ability:GetSpecialValueFor("cleave_starting_width")
	local cleave_ending_width = ability:GetSpecialValueFor("cleave_ending_width")
	local cleave_distance = ability:GetSpecialValueFor("cleave_distance")
	
	local cleave_damage = (damage_strength * strength_value) * damage / 100

	EmitSoundOn("hengsaoqianjun", caster)

	DoCleaveAttack(caster, target, ability, cleave_damage, cleave_starting_width, cleave_ending_width, cleave_distance, "particles/scrolls/hengsaoqianjun.vpcf")

	ApplyDamage({
		attacker = caster,
		victim = target,
		damage = cleave_damage * 0.45,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	})

	local pid = ParticleManager:CreateParticle('particles/msg_fx/msg_cleave.vpcf', PATTACH_POINT_FOLLOW, target)
	local len = string.len(tostring(math.floor(cleave_damage)))
	ParticleManager:SetParticleControlEnt(pid, 0, target, PATTACH_POINT_FOLLOW, 'attach_hitloc', target:GetOrigin()+Vector(0,0,128), false)
	ParticleManager:SetParticleControl(pid, 1, Vector(13, math.floor(cleave_damage), 0))
	ParticleManager:SetParticleControl(pid, 2, Vector(1, len + 1, 0))
	ParticleManager:SetParticleControl(pid, 3, Vector(255, 230, 125))
	ParticleManager:ReleaseParticleIndex(pid)
end