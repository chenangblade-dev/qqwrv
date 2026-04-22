local m = class({})
local magical_re = 0

function m:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DIRECT_MODIFICATION,
    }
end

function m:GetModifierMagicalResistanceDirectModification()
    local parent1=self:GetParent():GetIntellect(true)
    local inntt=parent1*-0.1
     return inntt
end

function m:GetModifierStatusResistance()
    return 30
end

function m:IsPurgable()
    return false
end

function m:IsHidden()
    return true
end

function m:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function m:RemoveOnDeath()
    return false
end

modifier_hero_status_resistance = m
