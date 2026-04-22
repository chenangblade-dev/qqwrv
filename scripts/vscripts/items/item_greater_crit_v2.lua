item_greater_crit_v2 = class({})

LinkLuaModifier("modifier_item_greater_crit_v2_pa", "items/item_greater_crit_v2.lua", LUA_MODIFIER_MOTION_NONE)
function item_greater_crit_v2:GetIntrinsicModifierName()
    return "modifier_item_greater_crit_v2_pa"
end


modifier_item_greater_crit_v2_pa = class({})

function modifier_item_greater_crit_v2_pa:GetTexture()
    return "item_greater_crit_v2"
end

function modifier_item_greater_crit_v2_pa:IsHidden()
    return true
end

function modifier_item_greater_crit_v2_pa:IsPurgable()
    return false
end

function modifier_item_greater_crit_v2_pa:IsPurgeException()
    return false
end

function modifier_item_greater_crit_v2_pa:AllowIllusionDuplicate()
    return false
end

function modifier_item_greater_crit_v2_pa:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_greater_crit_v2_pa:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,


   }
end
function modifier_item_greater_crit_v2_pa:CheckState()
    return {[MODIFIER_STATE_CANNOT_MISS] = true}
end

function modifier_item_greater_crit_v2_pa:OnCreated()
    self.crit = {}
    self.parent=self:GetParent()
    if self:GetAbility() == nil then
		return
    end
    self.ability=self:GetAbility()
    self.dam=self.ability:GetSpecialValueFor("dam")
    self.crit_ch=self.ability:GetSpecialValueFor("crit_ch")
    self.crit_m=self.ability:GetSpecialValueFor("crit_m")
    self.att_s=self.ability:GetSpecialValueFor("att_s")

end


function modifier_item_greater_crit_v2_pa:GetModifierPreAttack_CriticalStrike(tg)
        if tg.attacker == self.parent and not self.parent:IsIllusion()  then
            if RollPercentage(self.crit_ch) then
                self.crit[tg.record] = true
                self.parent:EmitSound("DOTA_Item.Daedelus.Crit")
                return self.crit_m
            end
        end
end


function modifier_item_greater_crit_v2_pa:GetModifierAttackSpeedBonus_Constant()
    return self.att_s
end
function modifier_item_greater_crit_v2_pa:GetModifierPreAttack_BonusDamage()
        return self.dam
end

function modifier_item_greater_crit_v2_pa:OnAttackLanded(tg)
        self.crit[tg.record] = nil
end
