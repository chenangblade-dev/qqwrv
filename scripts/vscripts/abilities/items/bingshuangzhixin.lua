LinkLuaModifier("modifier_bingshuangzhixin_slow","abilities/items/modifiers/modifier_bingshuangzhixin_slow",LUA_MODIFIER_MOTION_NONE)

-- 当冰霜之心命中了一个敌人，为他和他周围的单位添加减速什么的
function OnBingshuangzhixinHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local radius = ability:GetSpecialValueFor("explode_radius")
	local ratio = ability:GetSpecialValueFor("damage_ratio")

	-- 减速效果和伤害

	local damage = caster:GetIntellect(false) * ratio / 100
	ApplyDamage({
		damage = damage,
		attacker = caster,
		victim = target,
		ability = ability,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR
	})

	local pid = ParticleManager:CreateParticle('particles/msg_fx/msg_bingshuangzhixin_damage.vpcf', PATTACH_POINT_FOLLOW, target)
	local len = string.len(tostring(math.floor(damage)))
	ParticleManager:SetParticleControlEnt(pid, 0, target, PATTACH_POINT_FOLLOW, 'attach_hitloc', target:GetOrigin()+Vector(0,0,128), false)
	ParticleManager:SetParticleControl(pid, 1, Vector(10, math.floor(damage), 0))
	ParticleManager:SetParticleControl(pid, 2, Vector(1, len, 0))
	ParticleManager:SetParticleControl(pid, 3, Vector(18, 124, 255))
	ParticleManager:ReleaseParticleIndex(pid)

	-- target:AddNewModifier(caster,ability,"modifier_bingshuangzhixin_slow",{})

end