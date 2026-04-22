item_kaya_and_sangebig=class({})

LinkLuaModifier("modifier_item_kaya_and_sangebig", "items/item_kaya_and_sangebig.lua", LUA_MODIFIER_MOTION_NONE)

function item_kaya_and_sangebig:GetIntrinsicModifierName()
    return "modifier_item_kaya_and_sangebig"
end

modifier_item_kaya_and_sangebig=class({})

function modifier_item_kaya_and_sangebig:IsPassive()
    return true
end

function modifier_item_kaya_and_sangebig:IsHidden()
    return true
end

function modifier_item_kaya_and_sangebig:IsPurgable()
    return false
end

function modifier_item_kaya_and_sangebig:IsPurgeException()
    return false
end

function modifier_item_kaya_and_sangebig:AllowIllusionDuplicate()
    return false
end


function modifier_item_kaya_and_sangebig:OnCreated()
    self.caster=self:GetParent()
    if self:GetAbility() == nil then
		return
    end
    self.ability=self:GetAbility()
    self.str= self.ability:GetSpecialValueFor("bonus_strength")
    self.int= self.ability:GetSpecialValueFor("bonus_intellect")
    self.all_rs= self.ability:GetSpecialValueFor("status_resistance")
    self.all_heal= self.ability:GetSpecialValueFor("hp_regen_amp")
    self.all_sp= self.ability:GetSpecialValueFor("all_sp")
    self.spl= self.ability:GetSpecialValueFor("spell_lifesteal")
    self.all_spell= self.ability:GetSpecialValueFor("spell_amp")
    if self.caster:HasItemInInventory("item_ethereal_blade") or self.caster:HasItemInInventory("item_yasha_and_kaya")  or self.caster:HasItemInInventory("item_kaya_and_sange") or self.caster:HasItemInInventory("item_yasha_and_kayabig") then
        self.all_spell=0
    end
    self.sla= self.ability:GetSpecialValueFor("spell_lifesteal_amp")
end

function modifier_item_kaya_and_sangebig:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_item_kaya_and_sangebig:GetModifierBonusStats_Strength()
    return self.str
end

function modifier_item_kaya_and_sangebig:GetModifierBonusStats_Intellect()
    return self.int
end

function modifier_item_kaya_and_sangebig:GetModifierStatusResistanceStacking()
    return  self.all_rs
end

function modifier_item_kaya_and_sangebig:GetModifierHealAmplify_PercentageTarget()
    return self.all_heal
end

function modifier_item_kaya_and_sangebig:GetModifierHPRegenAmplify_Percentage()
    return self.all_heal
end

function modifier_item_kaya_and_sangebig:GetModifierSpellAmplify_Percentage()
    return self.all_spell
end

function modifier_item_kaya_and_sangebig:GetModifierSpellLifestealRegenAmplify_Percentage()
    return self.sla
end

function modifier_item_kaya_and_sangebig:OnTakeDamage(keys)
    if not IsServer() then
        return
    end
    if keys.attacker == self:GetParent() and keys.inflictor and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
        local dmg = keys.damage * (self.spl / 100)
        if keys.unit:IsCreep() then
            dmg = dmg / 5
        end
        self:GetParent():Heal(dmg, self.ability)        
    end
end