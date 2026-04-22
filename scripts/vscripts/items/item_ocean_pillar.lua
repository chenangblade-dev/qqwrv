item_ocean_pillar = class({})

LinkLuaModifier("modifier_item_ocean_pillar_pa", "items/item_ocean_pillar.lua", LUA_MODIFIER_MOTION_NONE)
function item_ocean_pillar:GetIntrinsicModifierName()
    return "modifier_item_ocean_pillar_pa"
end


modifier_item_ocean_pillar_pa = class({})

function modifier_item_ocean_pillar_pa:GetTexture()
    return "item_ocean_pillar"
end

function modifier_item_ocean_pillar_pa:IsHidden()
    return true
end

function modifier_item_ocean_pillar_pa:IsPurgable()
    return false
end

function modifier_item_ocean_pillar_pa:IsPurgeException()
    return false
end

function modifier_item_ocean_pillar_pa:AllowIllusionDuplicate()
    return false
end

function modifier_item_ocean_pillar_pa:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_ocean_pillar_pa:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
   }
end
function modifier_item_ocean_pillar_pa:CheckState()
    return {[MODIFIER_STATE_CANNOT_MISS] = true}
end

function modifier_item_ocean_pillar_pa:OnCreated()
    self.crit = {}
    self.parent=self:GetParent()
    if self:GetAbility() == nil then
		return
    end
    self.ability=self:GetAbility()
    self.dam=self.ability:GetSpecialValueFor("bonus_damage")
    self.att_s=self.ability:GetSpecialValueFor("bonus_attack_speed")

end

function modifier_item_ocean_pillar_pa:GetModifierAttackSpeedBonus_Constant()
    return self.att_s
end
function modifier_item_ocean_pillar_pa:GetModifierPreAttack_BonusDamage()
        return self.dam
end

function modifier_item_ocean_pillar_pa:GetModifierProcAttack_BonusDamage_Magical(keys)
    if not self.parent:IsIllusion() and not keys.target:IsBuilding() then
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, 160, nil)
        return 160     
    end
end