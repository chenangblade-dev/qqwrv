function UnlockEmpty6(keys)
	local caster = keys.caster
	--if caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
		--caster:AddAbility("shuxingfujia")
		--caster:FindAbilityByName("shuxingfujia"):SetLevel(1)
		--caster:SwapAbilities("shuxingfujia", "empty_6_locked", true, false)
		--caster:RemoveAbility("empty_6_locked")
	--else
		caster:AddAbility("empty_6")
		caster:FindAbilityByName("empty_6"):SetLevel(1)
		caster:SwapAbilities("empty_6", "empty_6_locked", true, false)
		caster:RemoveAbility("empty_6_locked")
    --end
end