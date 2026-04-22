item_random_neutralitem_01 = class({})
function item_random_neutralitem_01:OnSpellStart()
	local caster = self:GetCaster()
    local PRICED_item_REWARD_LIST_1 ={ 
        "item_princes_knife",
        "item_penta_edged_sword",
        "item_stormcrafter",
        "item_spell_prism",
        "item_panic_button",
    }
    local PRICED_item_REWARD_LIST_2 ={ 
            "item_force_boots",
            "item_desolator_2",
            "item_seer_stone",
            "item_mirror_shield",
            "item_ballista",
            "item_demonicon",
            "item_fallen_sky",
            "item_pirate_hat",
            "item_ex_machina",
            "item_giants_ring",
            "item_dredged_trident",
            "item_recipe_trident",
            "item_woodland_striders",
            "item_force_field",
            "item_vengeances_shadow",
            "item_fusion_rune",
            "item_phoenix_ash",
    }
    local i = RandomInt(1, 5)
    local nRandomSeed = RandomInt(1, 87)
    if nRandomSeed ==83 and RollPercentage(15) then
        caster:AddItemByName('item_apex')
    else
        if nRandomSeed<83 then
            caster:AddItemByName(  PRICED_item_REWARD_LIST_1[i] )
        elseif nRandomSeed<86 and nRandomSeed>83 then
            caster:AddItemByName("item_helm_of_the_undying")
        else
            i = RandomInt(1, 17)
            caster:AddItemByName(  PRICED_item_REWARD_LIST_2[i] )
        end
    end
    self:SpendCharge(0.1)
end


