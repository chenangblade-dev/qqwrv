function AddAbilityPoint(keys)
	local caster = keys.caster
	local abilityPoints = caster:GetAbilityPoints()
	if abilityPoints < 0 then abilityPoints = 0 end
	caster:SetAbilityPoints(abilityPoints + 1)

	local ability = keys.ability
	local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        ability:RemoveSelf()
    else
        ability:SetCurrentCharges(charges)

    end

end