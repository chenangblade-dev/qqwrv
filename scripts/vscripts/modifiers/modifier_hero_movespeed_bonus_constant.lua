local m = class({})

function m:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

function m:GetModifierMoveSpeedBonus_Constant()
    return 80
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

modifier_hero_movespeed_bonus_constant = m
