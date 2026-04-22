local m = class({})

function m:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
end

function m:GetModifierPercentageCooldown()
	if IsServer() then
		local hero = self:GetParent()
		if hero:GetLevel() > 17 then
    		return 100
    	end 
    end
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

modifier_hero_cooldown_percentage = m
