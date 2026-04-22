local m = class({})

function m:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATUS_RESISTANCE
    }
end

function m:GetModifierStatusResistance()
    return 40
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

modifier_hero_status_resistance_jinmin = m
