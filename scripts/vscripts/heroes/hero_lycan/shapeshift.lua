shapeshift=class({})

LinkLuaModifier("modifier_shapeshift_buff", "heroes/hero_lycan/shapeshift.lua", LUA_MODIFIER_MOTION_NONE)
function shapeshift:IsHiddenWhenStolen()
    return false
end

function shapeshift:IsStealable()
    return true
end

function shapeshift:IsRefreshable()
    return true
end

function shapeshift:GetCooldown(iLevel)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_lycan_8")
    if talent and talent:GetLevel() > 0 then
        return self.BaseClass.GetCooldown(self,iLevel)-25
    else
        return self.BaseClass.GetCooldown(self,iLevel)
    end
end
function shapeshift:GetDuration(iLevel)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_lycan_1")
    if talent and talent:GetLevel() > 0 then
        return self.BaseClass.GetDuration(self,iLevel) + 6
    else
        return self.BaseClass.GetDuration(self,iLevel)
    end
end

function shapeshift:OnSpellStart()
    local caster = self:GetCaster()
    local pos = caster:GetAbsOrigin()
    local duration=self:GetSpecialValueFor("duration")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_lycan_1")
    if talent and talent:GetLevel() > 0 then
        duration=duration + 6
    end
    EmitSoundOn("Hero_Lycan.Shapeshift.Cast", caster)
    local particle= ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW,caster)
    ParticleManager:SetParticleControl(particle, 0,pos)
    ParticleManager:ReleaseParticleIndex(particle)
    caster:AddNewModifier(caster, self, "modifier_shapeshift_buff", {duration=duration})
end


modifier_shapeshift_buff=class({})

function modifier_shapeshift_buff:IsHidden()
    return false
end

function modifier_shapeshift_buff:IsPurgable()
    return false
end

function modifier_shapeshift_buff:IsPurgeException()
    return false
end

function modifier_shapeshift_buff:GetEffectName()
    return "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf"
end

function modifier_shapeshift_buff:RemoveOnDeath()
    return true
end


function modifier_shapeshift_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_shapeshift_buff:DeclareFunctions()
    return
    {

        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION

    }
end

function modifier_shapeshift_buff:GetModifierModelChange()
    return "models/items/lycan/ultimate/ambry_true_form/ambry_true_form.vmdl"
end

function modifier_shapeshift_buff:AllowIllusionDuplicate()
    return true
end

function modifier_shapeshift_buff:OnCreated()
	if self:GetAbility() == nil then return end
    self.crit = {}
    self.parent=self:GetParent()
    self.ability=self:GetAbility()
    self.caster=self:GetCaster()
    self.crit_multiplier=self.ability:GetSpecialValueFor("crit_multiplier")
    self.crit_chance=self.ability:GetSpecialValueFor("crit_chance")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_lycan_6")
    if talent and talent:GetLevel() > 0 then
        self.crit_chance= self.crit_chance + 30
    end
    self.speed=self.ability:GetSpecialValueFor("speed")
    self.attack_range= self.ability:GetSpecialValueFor("attack_range")
    if self.parent:IsRangedAttacker() then
        self.attack_range=-2 * self.attack_range
    end
end

function modifier_shapeshift_buff:OnRefresh()
    self:OnCreated()
end

function modifier_shapeshift_buff:OnDestroy()
    self.crit = nil
    if not IsServer() then
        return
    end
    local particle= ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.parent)
    ParticleManager:SetParticleControl(particle, 0,self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3,self.parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
end


function modifier_shapeshift_buff:GetModifierPreAttack_CriticalStrike(tg)
    if not IsServer() then
		return
	end
    if tg.attacker == self.parent and not tg.target:IsBuilding() and not self.parent:IsIllusion() then
        if RollPseudoRandomPercentage(self.crit_chance,0,self.parent) then
            self.crit[tg.record] = true
            return  self.crit_multiplier
		else
			return 0
		end
	end
end


function modifier_shapeshift_buff:OnAttackFail(tg)
    if not IsServer() then
        return
    end
        if tg.attacker == self.parent  and not self.parent:IsIllusion() then
            self.crit[tg.record] = nil
        end
end



function modifier_shapeshift_buff:GetModifierIgnoreMovespeedLimit()
    return 0
end

function modifier_shapeshift_buff:GetModifierMoveSpeedBonus_Constant()
	return  self.speed
end


function modifier_shapeshift_buff:GetModifierAttackRangeBonus()
    return self.attack_range
end

function modifier_shapeshift_buff:GetBonusNightVision()
    return 800
end

function modifier_shapeshift_buff:CheckState()
    return
    {
        [MODIFIER_STATE_UNSLOWABLE] = true,
    }
end



