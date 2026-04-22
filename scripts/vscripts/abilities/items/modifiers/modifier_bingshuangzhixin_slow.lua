modifier_bingshuangzhixin_slow = class({})

function modifier_bingshuangzhixin_slow:IsDebuff()
	return true
end

function modifier_bingshuangzhixin_slow:GetTexture()
	return "bom/jiansuguanghuan"
end


function modifier_bingshuangzhixin_slow:IsPurgable()
    return false
end
function modifier_bingshuangzhixin_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		-- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
end




function modifier_bingshuangzhixin_slow:OnCreated(kv)
	if IsServer() then
		local duration = self:GetAbility():GetSpecialValueFor("slow_duration")
		self:SetDuration(duration,true)
		--self.flzhiliao= self:GetCaster():GetIntellect() * 0.15

		-- self.flAttackSpeedSlow = self:GetAbility():GetSpecialValueFor('attack_speed_slow')
		self.flMoveSpeedSlow = self:GetAbility():GetSpecialValueFor("slow_value")
	end
end

function modifier_bingshuangzhixin_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_bingshuangzhixin_slow:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return -self.flAttackSpeedSlow
	end
end

function modifier_bingshuangzhixin_slow:GetModifierMoveSpeedBonus_Constant()
	if IsServer() then
		return -self.flMoveSpeedSlow
	end
end

function modifier_bingshuangzhixin_slow:GetModifierHealAmplify_PercentageTarget() --治疗减少

	return -30
end

function modifier_bingshuangzhixin_slow:GetModifierHPRegenAmplify_Percentage()  --恢复减少
	return -30
end