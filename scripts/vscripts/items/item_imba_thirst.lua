item_imba_thirst = class({})

LinkLuaModifier("item_imba_thirst_passive", "items/item_imba_thirst", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_imba_thirst_buff", "items/item_imba_thirst", LUA_MODIFIER_MOTION_NONE)
function item_imba_thirst:GetIntrinsicModifierName() return "item_imba_thirst_passive" end
function item_imba_thirst:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local health = caster:GetHealth()
    EmitSoundOn("DOTA_Item.Satanic.Activate", self:GetCaster())
    caster:Purge(false, true, false, false, false)


    local modifier = caster:AddNewModifier(caster,self,"item_imba_thirst_buff",{duration = self:GetSpecialValueFor("duration_on")})
end

item_imba_thirst_buff = class({})
function item_imba_thirst_buff:IsDebuff()           return false end
function item_imba_thirst_buff:IsHidden()           return false end
function item_imba_thirst_buff:IsPurgable()         return false end
function item_imba_thirst_buff:IsPurgeException()   return false end
function item_imba_thirst_buff:GetEffectName()          return "particles/items2_fx/satanic_buff.vpcf" end
function item_imba_thirst_buff:GetTexture()         return "item_thirst" end
function item_imba_thirst_buff:DeclareFunctions() return
{
    MODIFIER_EVENT_ON_ATTACK_LANDED,
}
end
function item_imba_thirst_buff:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if keys.attacker == self:GetParent() and (keys.target:IsHero() or keys.target:IsCreep() ) then
        local life = self.lifesteal
        local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(pfx)
        keys.attacker:Heal(keys.damage * 0.75, keys.attacker)
    end
end
item_imba_thirst_passive = class({})
function item_imba_thirst_passive:IsDebuff()            return false end
function item_imba_thirst_passive:IsHidden()            return true end
function item_imba_thirst_passive:IsPurgable()      return false end
function item_imba_thirst_passive:IsPurgeException()    return false end
function item_imba_thirst_passive:DeclareFunctions() return
{
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
}
end

function item_imba_thirst_passive:RemoveOnDeath()       return self:GetParent():IsIllusion() end
function item_imba_thirst_passive:OnCreated()
    if self:GetAbility() == nil then
        return
    end
    self.ab = self:GetAbility()
    self.lifesteal = self.ab:GetSpecialValueFor("lifesteal")
    self.str = self.ab:GetSpecialValueFor("str")
    self.damage = self.ab:GetSpecialValueFor("damage")
end
function item_imba_thirst_passive:GetModifierBonusStats_Strength()
    return self.str
end

function item_imba_thirst_passive:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function item_imba_thirst_passive:OnTakeDamage( keys )
    if keys.attacker == self:GetParent() and not keys.unit:IsOther() then
        if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
            local life = self.lifesteal
            local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:ReleaseParticleIndex(pfx)
            keys.attacker:Heal(keys.damage * life * 0.01, keys.attacker)
        end
    end
end