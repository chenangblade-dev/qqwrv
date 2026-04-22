function OnShixueshaluHeroKill(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:IsRealHero() then
		if not caster:HasModifier('modifier_shixueshalu') then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_shixueshalu", {})
		end
		local modifier = caster:FindModifierByName("modifier_shixueshalu")
		modifier:ForceRefresh()

		local stacks = caster:GetModifierStackCount('modifier_shixueshalu', caster)
		if stacks == nil then stacks = 0 end
		stacks = stacks + 1
		local max_stacks = ability:GetSpecialValueFor("max_stacks")
		if stacks > max_stacks then
			stacks = max_stacks
		end
		caster:SetModifierStackCount("modifier_shixueshalu", caster, stacks)

		local pcf = ParticleManager:CreateParticle("particles/item_fx/shixueshalu_roshan.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(pcf, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetOrigin(), false)
		ParticleManager:SetParticleControlEnt(pcf, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetOrigin(), false)
		ParticleManager:SetParticleControlOrientation(pcf, 7, caster:GetForwardVector(), caster:GetRightVector(), caster:GetUpVector())
		ParticleManager:ReleaseParticleIndex(pcf)
		caster:ForcePlayActivityOnce(ACT_DOTA_VICTORY)

		EmitSoundOn("shixueshalu.shout", caster)
	end
end

function OnShixueshaluDead(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier('modifier_shixueshalu') then
		return
	end
	local modifier = caster:FindModifierByName("modifier_shixueshalu")
	local stacks = caster:GetModifierStackCount('modifier_shixueshalu', caster)
	if stacks == nil then stacks = 0 end
	stacks = stacks - 1
	if stacks <= 0 then
		caster:RemoveModifierByName('modifier_shixueshalu')
	else
		caster:SetModifierStackCount("modifier_shixueshalu", caster, stacks)
	end
end