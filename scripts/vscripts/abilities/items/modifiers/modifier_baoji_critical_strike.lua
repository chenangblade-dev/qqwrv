local m = class({})

function m:IsHidden()
	return true
end

function m:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function m:OnAttackLanded(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		local attacker = self:GetParent()
		local target = keys.target

		local pcf = "particles/abilities/baoji.vpcf"
		if attacker.__bjuemingyiji then
			pcf = "particles/abilities/baoji_vip.vpcf"
		end

		local nFXIndex = ParticleManager:CreateParticle(pcf, PATTACH_CUSTOMORIGIN, target )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex, 1, target:GetOrigin() )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, -attacker:GetForwardVector() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		self:Destroy()
		EmitSoundOn('Hero_PhantomAssassin.CoupDeGrace', target)
	end
end

function m:GetModifierPreAttack_CriticalStrike()
	if IsServer() then
		local ability = self:GetAbility()
		local attacker = self:GetParent()
		local percentage = ability:GetSpecialValueFor('percentage')
		local agi = attacker:GetAgility()
		local percentage_per_agi = ability:GetSpecialValueFor('percentage_per_agi')
		local total = percentage + agi * percentage_per_agi
		return total
	end
end

modifier_baoji_critical_strike = m
