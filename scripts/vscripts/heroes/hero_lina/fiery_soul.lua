fiery_soul=class({})

LinkLuaModifier("modifier_fiery_soul", "heroes/hero_lina/fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fiery_soul_passive", "heroes/hero_lina/fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)

function fiery_soul:IsRefreshable()           return false end
function fiery_soul:IsStealable()             return false end
function fiery_soul:GetIntrinsicModifierName() return "modifier_fiery_soul" end


modifier_fiery_soul=class({})

function modifier_fiery_soul:IsHidden()         return true end

function modifier_fiery_soul:IsPurgable()
    return false
end
function modifier_fiery_soul:IsPurgeException()
    return false
end
function modifier_fiery_soul:AllowIllusionDuplicate()
    return false
end
function modifier_fiery_soul:OnCreated()
        if self:GetAbility() == nil  then
            return
        end
        self.caster=self:GetCaster()
        self.ability=self:GetAbility()
        self.parent=self:GetParent()
end

function modifier_fiery_soul:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_fiery_soul:OnAbilityFullyCast(tg)
    if not IsServer() then
        return
    end
    if tg.unit ~= self.parent then return end
    if tg.unit == self.parent and not self.parent:IsIllusion() then
            if not tg.ability or tg.ability:IsItem() or tg.ability:IsToggle() then
                  return
            end
    end
    self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_fiery_soul_passive", {duration = self:GetAbility():GetSpecialValueFor("dur_time")})

end


modifier_fiery_soul_passive=class({})

function modifier_fiery_soul_passive:IsDebuff()         return false end
function modifier_fiery_soul_passive:IsBuff()           return true end
function modifier_fiery_soul_passive:IsHidden()         return false end
function modifier_fiery_soul_passive:IsPurgable()       return false end
function modifier_fiery_soul_passive:IsPurgeException() return false end


function modifier_fiery_soul_passive:OnCreated()
    if not IsServer() then return end
       self:SetStackCount(1)

end

function modifier_fiery_soul_passive:OnRefresh()
    if not IsServer() then return end
    if self:GetStackCount()>2 then 
        self:SetStackCount(3)
    else            
        self:IncrementStackCount()
    end

end
function modifier_fiery_soul_passive:GetStack()
     local stack=self:GetStackCount()
     if stack~=nil and stack>0 then
            return true
        end
            return false
end


function modifier_fiery_soul_passive:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_fiery_soul_passive:GetModifierAttackSpeedBonus_Constant()
    if (self:GetStack()) then
            return  self:GetAbility():GetSpecialValueFor("fiery_soul_attack_speed_bonus")*self:GetStackCount()
    end
            return 0
end

function modifier_fiery_soul_passive:GetModifierMoveSpeedBonus_Percentage()
    if (self:GetStack()) then
            return  self:GetAbility():GetSpecialValueFor("fiery_soul_move_speed_bonus")*self:GetStackCount()
    end
            return 0
end


function modifier_fiery_soul_passive:RemoveOnDeath()
    return false
end