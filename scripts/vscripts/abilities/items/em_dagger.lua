function OnDaggerTakenDamage(keys)
    local attacker = keys.attacker
    local caster = keys.caster
    local ability = keys.ability
    if attacker:IsRealHero() and attacker:GetTeamNumber() ~= caster:GetTeamNumber() then
        local cd = ability:GetCooldownTimeRemaining()
        if cd < 3 then
            ability:StartCooldown(3)
        end
    end

end

function OnDagger(keys)
    local caster = keys.caster
    local ability = keys.ability

    -- 传送到随机位置
    local co = caster:GetAbsOrigin()
    local target_point = GameRules.GameMode:GetRandomValidPosition()
    -- 至少传送到1500范围之外
    while (co - target_point):Length2D() < 1500 do
        target_point = GameRules.GameMode:GetRandomValidPosition()
    end

    ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.

    ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, keys.caster)
    caster:EmitSound("DOTA_Item.BlinkDagger.Activate")

    -- caster:SetAbsOrigin(target_point)
    FindClearSpaceForUnit(keys.caster, target_point, false)

    ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, keys.caster)

    local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        ability:RemoveSelf()
    else
        ability:SetCurrentCharges(charges)
    end
end
