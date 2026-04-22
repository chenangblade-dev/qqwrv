function OnRandomStar(keys)
	local caster = keys.caster
	if not caster:IsRealHero() then return end
	caster:RandomStar()

	local ability = keys.ability
	local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        UTIL_RemoveImmediate(ability)
    else
        ability:SetCurrentCharges(charges)
    end

    local cost = GetItemCost('item_random_star')
    caster.__nStarCost__ = caster.__nStarCost__ or 0
    caster.__nStarCost__ = caster.__nStarCost__ + cost
    CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), 'player_update_star_cost', {cost=caster.__nStarCost__})
end