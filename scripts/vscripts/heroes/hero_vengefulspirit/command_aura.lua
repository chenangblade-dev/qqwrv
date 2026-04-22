command_aura=class({})
LinkLuaModifier( "modifier_command_aura", "heroes/hero_vengefulspirit/command_aura.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_command_aura_temp", "heroes/hero_vengefulspirit/command_aura.lua", LUA_MODIFIER_MOTION_NONE )

function command_aura:GetIntrinsicModifierName()
    return "modifier_command_aura"
end

modifier_command_aura=class({})

function modifier_command_aura:IsHidden()
    return false
end

--允许幻想复制
function modifier_command_aura:AllowIllusionDuplicate()
    return false
end

function modifier_command_aura:OnCreated()
    self.caster=self:GetCaster()
    self.bonus_base_damage = self:GetAbility():GetSpecialValueFor( "bonus_base_damage" )
    self:SetStackCount(0)

    --self:SetStackCount(kills)
end

function modifier_command_aura:OnRefresh()
    self.bonus_base_damage = self:GetAbility():GetSpecialValueFor( "bonus_base_damage" )
end



function modifier_command_aura:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        --MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
end

function modifier_command_aura:GetModifierBaseAttack_BonusDamage()
    return self:GetStackCount()*self.bonus_base_damage
end

function modifier_command_aura:GetModifierAttackRangeBonus()
    if self:GetParent():IsRangedAttacker() then
        return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("range_bonus")
    end
end
--[[
★判断目标是否是友军（厉害了我的中国）。
--]]
function Is_Chinese_TG(tar1, tar2)
    if tar1:GetTeamNumber()==tar2:GetTeamNumber() then
        return true
    end
       return false
end

function modifier_command_aura:OnDeath(tg)
    if self:GetStackCount()==0 then
        local deathcount=PlayerResource:GetDeaths(self:GetCaster():GetPlayerOwnerID())
        self:SetStackCount(deathcount*2)
    end
    if IsServer() then
        if Is_Chinese_TG(tg.unit,self.caster) and not tg.unit:IsIllusion() then
            self:SetStackCount(self:GetStackCount()+1)
        end
    end
end