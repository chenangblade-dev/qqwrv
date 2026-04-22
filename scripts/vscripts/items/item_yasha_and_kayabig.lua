item_yasha_and_kayabig=class({})

LinkLuaModifier("modifier_item_yasha_and_kayabig_buff", "items/item_yasha_and_kayabig.lua", LUA_MODIFIER_MOTION_NONE)

function item_yasha_and_kayabig:GetIntrinsicModifierName()
    return "modifier_item_yasha_and_kayabig_buff"
end

modifier_item_yasha_and_kayabig_buff=class({})

function modifier_item_yasha_and_kayabig_buff:IsPassive()
    return true
end

function modifier_item_yasha_and_kayabig_buff:IsHidden()
    return true
end

function modifier_item_yasha_and_kayabig_buff:IsPurgable()
    return false
end

function modifier_item_yasha_and_kayabig_buff:IsPurgeException()
    return false
end

function modifier_item_yasha_and_kayabig_buff:AllowIllusionDuplicate()
    return false
end


function modifier_item_yasha_and_kayabig_buff:OnCreated()
    self.caster=self:GetParent()
    if self:GetAbility() == nil then
		return
    end
    self.ability=self:GetAbility()
    self.agi= self.ability:GetSpecialValueFor("bonus_agility")
    self.int= self.ability:GetSpecialValueFor("bonus_intellect")
    self.all_att= self.ability:GetSpecialValueFor("bonus_attack_speed")
    self.all_move= self.ability:GetSpecialValueFor("movement_speed_percent_bonus")
    self.spl= self.ability:GetSpecialValueFor("spell_lifesteal")
    self.all_spell= self.ability:GetSpecialValueFor("spell_amp")
    if self.caster:HasItemInInventory("item_ethereal_blade") or self.caster:HasItemInInventory("item_yasha_and_kaya")  or self.caster:HasItemInInventory("item_kaya_and_sange") or self.caster:HasItemInInventory("item_kaya_and_sangebig") then
        self.all_spell=0
    end
    self.sla= self.ability:GetSpecialValueFor("spell_lifesteal_amp")
end

function modifier_item_yasha_and_kayabig_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end


function modifier_item_yasha_and_kayabig_buff:GetModifierBonusStats_Agility()
    return self.agi
end

function modifier_item_yasha_and_kayabig_buff:GetModifierBonusStats_Intellect()
    return self.int
end


function modifier_item_yasha_and_kayabig_buff:GetModifierAttackSpeedBonus_Constant()
    return self.all_att
end


function modifier_item_yasha_and_kayabig_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.all_move
end


function modifier_item_yasha_and_kayabig_buff:GetModifierSpellAmplify_Percentage()
    return self.all_spell
end

function modifier_item_yasha_and_kayabig_buff:GetModifierSpellLifestealRegenAmplify_Percentage()
    return self.sla
end


function modifier_item_yasha_and_kayabig_buff:OnTakeDamage(keys)
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