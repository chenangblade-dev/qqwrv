if modifier_hero_attradd == nil then
    modifier_hero_attradd = class({})
end


function modifier_hero_attradd:RemoveOnDeath()
    return false
end


--胸针加射程
function modifier_hero_attradd:OnCreated(keys)
    if not IsServer() then return end
end

function modifier_hero_attradd:OnDestroy()
    if not IsServer() then return end
end
--声明官方函数
function modifier_hero_attradd:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

--增加攻击距离
function modifier_hero_attradd:GetModifierAttackRangeBonus()
    return 150
end