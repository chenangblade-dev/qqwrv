local imbaAbilityFirstAppearTime = 23 * 60
local mapName = GetMapName()

local courierSpecialRate = 30

local abilityWeightMap = {
    naga_siren_song_of_the_siren = {99, 98, 98, 96},
    dazzle_bad_juju = {99, 98, 98, 96},
    muerta_pierce_the_veil= {99, 98, 98, 96},
    silencer_glaives_of_wisdom = {99, 98, 98, 96},
    obsidian_destroyer_arcane_orb = {99, 98, 98, 96},
    slark_essence_shift = {99, 98, 98, 96},
    faceless_void_time_lock = {98, 95, 95, 95},
    slardar_bash = {98, 95, 95, 95},
    alchemist_goblins_greed = {93, 90, 87, 84},
    elder_titan_natural_order = {93, 90, 87, 84},
    doom_bringer_infernal_blade = {99, 98, 98, 96},
    undying_flesh_golem = {93, 90, 87, 84},
    bloodseeker_thirst = {70, 65, 60, 50},
    dragon_knight_elder_dragon_form = {90, 85, 80, 75},
    -- obsidian_destroyer_arcane_orb = {85, 80, 75, 70},
    dazzle_good_juju = {60, 55, 50, 45},
    drow_ranger_marksmanship = {93, 90, 87, 84},
    phantom_assassin_coup_de_grace = {30, 15, 10, 5},
    phantom_assassin_blur = {90, 85, 80, 75},
    medusa_split_shot= {90, 85, 80, 75},
    viper_poison_attack = {60, 55, 50, 45},
    oracle_false_promise = {70, 65, 60, 50},
    abaddon_frostmourne = {70, 65, 60, 50},
    tiny_grow= {60, 55, 50, 45},
    ursa_enrage = {70, 65, 60, 50},
    life_stealer_rage= {80, 65, 60, 50}, -- 狂暴 小狗魔免
    ogre_magi_multicast_lua= {70, 65, 60, 50},
    spectre_dispersion = {60, 55, 50, 45},
    juggernaut_blade_fury = {70, 65, 60, 50},
    slark_shadow_dance = {80, 65, 60, 50},
    void_spirit_astral_step = {30, 20, 10, 5},
    rubick_arcane_supremacy = {20, 10, 10, 5},
    antimage_blink = {25, 15, 10, 5},
    queenofpain_blink = {25, 15, 10, 5},
    zuus_arc_lightning= {65, 55, 50, 45},
    lion_voodoo = {30, 15, 10, 5},
    --centaur_return = {10, 2, 2, 2},
    --pangolier_swashbuckle = {10, 2, 2, 2},
    lina_fiery_soul = {15, 10, 5, 2},
    shadow_shaman_voodoo = {30, 15, 10, 5},
    dazzle_shallow_grave= {60, 55, 50, 45},
    troll_warlord_battle_trance= {65, 45, 30, 25},
    faceless_void_time_walk= {30, 15, 10, 5},
    batrider_firefly= {15, 10, 5, 2},
    muerta_gunslinger= {60, 55, 50, 45},
    invoker_chaos_meteor={30, 20, 10, 5},
    broodmother_insatiable_hunger={25, 15, 10, 5},
    spirit_breaker_planar_pocket={25, 15, 10, 5},
    --necrolyte_reapers_scythe= {50, 40, 30, 15},



}

local function getImbaAbilityReplaceChance(abilityName)
    local specialWeight = abilityWeightMap[abilityName] or {}
    local imbaAbilityReplacePercentage = specialWeight[1] or 75
    if GameRules.nCountDownTimer < 13 * 60 then
        imbaAbilityReplacePercentage = specialWeight[2] or 70
    end
    if GameRules.nCountDownTimer < 9 * 60 then
        imbaAbilityReplacePercentage = specialWeight[3] or 55
    end
    if GameRules.nCountDownTimer < 5 * 60 then
        imbaAbilityReplacePercentage = specialWeight[4] or 50
    end
    return imbaAbilityReplacePercentage
end

function OnAddUltimate(keys)
    local caster = keys.caster
    if not caster:IsRealHero() then
        return
    end
    local ability = keys.ability

    if not caster:HasAbility("empty_a6") and mapName == "arena_3x4" then
        msg.bottom("#hud_error_only_one_ultimate", caster:GetPlayerID())
        return
    end

    local bookCount = 3
    local stars = caster:GetCurrentStar()
    if RollPercentage(stars) then
        bookCount = 4
    end

    local randomAbilities = table.random_some(GameRules.vUltimateAbilitiesPool, bookCount)


        for k, ability in pairs(randomAbilities) do
            if table.contains(GameRules.vCourierAbilities_Ultimate, ability) then
                local imbaAbilityReplacePercentage = getImbaAbilityReplaceChance(ability)
                if
                    RollPercentage(imbaAbilityReplacePercentage) or
                        GameRules.nCountDownTimer > imbaAbilityFirstAppearTime
                 then
                    local randomAbility = table.random(GameRules.vUltimateAbilitiesPool)
                    while (table.contains(randomAbilities, randomAbility) or
                        table.contains(GameRules.vCourierAbilities_Ultimate, randomAbility)) do
                        randomAbility = table.random(GameRules.vUltimateAbilitiesPool)
                    end
                    randomAbilities[k] = randomAbility
                end
            end
        end

    -- 避免被没点的初始技能覆盖了
    caster.__playerHaveSelectedAbility__ = true

    GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
    local id = "spell_book_" .. DoUniqueString("")
    GameRules.vSpellbookRecorder[id] = randomAbilities

    CustomGameEventManager:Send_ServerToPlayer(
        PlayerResource:GetPlayer(caster:GetPlayerID()),
        "show_ability_selector",
        {
            ID = id,
            Abilities = randomAbilities,
            Type = "ultimate"
        }
    )

    local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        ability:RemoveSelf()
    else
        ability:SetCurrentCharges(charges)
    end

    caster.__nNumUltimateBook__ = caster.__nNumUltimateBook__ or 0
    caster.__nNumUltimateBook__ = caster.__nNumUltimateBook__ + 1

    CustomGameEventManager:Send_ServerToPlayer(
        caster:GetPlayerOwner(),
        "player_update_book_count",
        {
            NormalBookCount = caster.__nNumNormalBook__ or 0,
            UltimateBookCount = caster.__nNumUltimateBook__ or 0
        }
    )
end

function OnAddNormal(keys)
    local caster = keys.caster
    if not caster:IsRealHero() then
        return
    end
    local ability = keys.ability
    if mapName == "arena_3x4" then 
        if
        not (caster:HasAbility("empty_a1") or caster:HasAbility("empty_a2") or caster:HasAbility("empty_a3") or
            (caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT and caster:HasAbility("empty_a4")))
        then
        msg.bottom("#hud_error_ability_is_full", caster:GetPlayerID())
        return
        end
    end

    local bookCount = 3
    local stars = caster:GetCurrentStar()
    if RollPercentage(stars) then
        bookCount = 4
    end

    local randomAbilities = table.random_some(GameRules.vNormalAbilitiesPool, bookCount)

    if not GameRules.bFreeModeActivated == true then
        for k, ability in pairs(randomAbilities) do
            if table.contains(GameRules.vCourierAbilities_Normal, ability) then
                local imbaAbilityReplacePercentage = getImbaAbilityReplaceChance(ability)
                if
                    RollPercentage(imbaAbilityReplacePercentage) or
                        GameRules.nCountDownTimer > imbaAbilityFirstAppearTime
                 then
                    local randomAbility = table.random(GameRules.vNormalAbilitiesPool)
                    while (table.contains(randomAbilities, randomAbility) or
                        table.contains(GameRules.vCourierAbilities_Normal, randomAbility)) do
                        randomAbility = table.random(GameRules.vNormalAbilitiesPool)
                    end
                    randomAbilities[k] = randomAbility
                end
            end
        end
    end

    -- 避免被没点的初始技能覆盖了
    caster.__playerHaveSelectedAbility__ = true

    GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
    local id = "spell_book_" .. DoUniqueString("")
    GameRules.vSpellbookRecorder[id] = randomAbilities

    CustomGameEventManager:Send_ServerToPlayer(
        PlayerResource:GetPlayer(caster:GetPlayerID()),
        "show_ability_selector",
        {
            ID = id,
            Abilities = randomAbilities,
            Type = "normal"
        }
    )

    local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        ability:RemoveSelf()
    else
        ability:SetCurrentCharges(charges)
    end

    caster.__nNumNormalBook__ = caster.__nNumNormalBook__ or 0
    caster.__nNumNormalBook__ = caster.__nNumNormalBook__ + 1

    CustomGameEventManager:Send_ServerToPlayer(
        caster:GetPlayerOwner(),
        "player_update_book_count",
        {
            NormalBookCount = caster.__nNumNormalBook__ or 0,
            UltimateBookCount = caster.__nNumUltimateBook__ or 0
        }
    )
end

function OnAddNormal_Courier(keys)
    local caster = keys.caster
    if not caster:IsRealHero() then
        return
    end
    local ability = keys.ability
    if mapName == "arena_3x4" then 
        if not (caster:HasAbility("empty_a1") or caster:HasAbility("empty_a2") or caster:HasAbility("empty_a3") or
            (caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT and caster:HasAbility("empty_a4")))
            then
            msg.bottom("#hud_error_ability_is_full", caster:GetPlayerID())
            return
        end
    end

    local randomAbilities = table.random_some(GameRules.vNormalAbilitiesPool, 3)

    -- 如果没有包含有附加的特殊技能，那么有大概率给一个
    local didntHave = true
    for k, ability in pairs(randomAbilities) do
        if table.contains(GameRules.vCourierAbilities_Normal, ability) then
            didntHave = false
            break
        end
    end
    if didntHave then
        if RollPercentage(courierSpecialRate) then
            local ability = table.random(GameRules.vCourierAbilities_Normal)
            randomAbilities[RandomInt(1, 3)] = ability
        end
    end

    -- 避免被没点的初始技能覆盖了
    caster.__playerHaveSelectedAbility__ = true

    GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
    local id = "spell_book_" .. DoUniqueString("")
    GameRules.vSpellbookRecorder[id] = randomAbilities

    CustomGameEventManager:Send_ServerToPlayer(
        PlayerResource:GetPlayer(caster:GetPlayerID()),
        "show_ability_selector",
        {
            ID = id,
            Abilities = randomAbilities,
            Type = "normal"
        }
    )

    local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        ability:RemoveSelf()
    else
        ability:SetCurrentCharges(charges)
    end

    caster.__nNumNormalBook__ = caster.__nNumNormalBook__ or 0
    caster.__nNumNormalBook__ = caster.__nNumNormalBook__ + 1

    CustomGameEventManager:Send_ServerToPlayer(
        caster:GetPlayerOwner(),
        "player_update_book_count",
        {
            NormalBookCount = caster.__nNumNormalBook__ or 0,
            UltimateBookCount = caster.__nNumUltimateBook__ or 0
        }
    )
end

function OnAddUltimate_Courier(keys)
    local caster = keys.caster
    if not caster:IsRealHero() then
        return
    end
    local ability = keys.ability

    if not caster:HasAbility("empty_a6") and mapName == "arena_3x4" then
        msg.bottom("#hud_error_only_one_ultimate", caster:GetPlayerID())
        return
    end

    local randomAbilities = table.random_some(GameRules.vUltimateAbilitiesPool, 3)

    -- 如果没有包含有附加的特殊技能，那么有大概率给一个
    local didntHave = true
    for k, ability in pairs(randomAbilities) do
        if table.contains(GameRules.vCourierAbilities_Ultimate, ability) then
            didntHave = false
            break
        end
    end
    if didntHave then
        if RollPercentage(courierSpecialRate) then
            local ability = table.random(GameRules.vCourierAbilities_Ultimate)
            randomAbilities[RandomInt(1, 3)] = ability
        end
    end

    -- 避免被没点的初始技能覆盖了
    caster.__playerHaveSelectedAbility__ = true

    GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
    local id = "spell_book_" .. DoUniqueString("")
    GameRules.vSpellbookRecorder[id] = randomAbilities

    CustomGameEventManager:Send_ServerToPlayer(
        PlayerResource:GetPlayer(caster:GetPlayerID()),
        "show_ability_selector",
        {
            ID = id,
            Abilities = randomAbilities,
            Type = "ultimate"
        }
    )

    local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        ability:RemoveSelf()
    else
        ability:SetCurrentCharges(charges)
    end

    caster.__nNumUltimateBook__ = caster.__nNumUltimateBook__ or 0
    caster.__nNumUltimateBook__ = caster.__nNumUltimateBook__ + 1

    CustomGameEventManager:Send_ServerToPlayer(
        caster:GetPlayerOwner(),
        "player_update_book_count",
        {
            NormalBookCount = caster.__nNumNormalBook__ or 0,
            UltimateBookCount = caster.__nNumUltimateBook__ or 0
        }
    )
end

function OnAddUnlimited(keys)
    local caster = keys.caster
    if not caster:IsRealHero() then
        return
    end 
    local ability = keys.ability

    if mapName == "arena_3x4" then  
        if
            not (caster:HasAbility("empty_a1") or caster:HasAbility("empty_a2") or caster:HasAbility("empty_a3") or
                (caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT and caster:HasAbility("empty_a4")) or
                caster:HasAbility("empty_a6"))
            then
            msg.bottom("#hud_error_ability_is_full", caster:GetPlayerID())
            return
        end
    end

    local randomPool = table.join(GameRules.vUltimateAbilitiesPool, GameRules.vNormalAbilitiesPool)
    local randomAbilities = table.random_some(randomPool, RandomInt(2, 4))
    caster.__playerHaveSelectedAbility__ = true
    GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
    local id = "spell_book_" .. DoUniqueString("")
    GameRules.vSpellbookRecorder[id] = randomAbilities

    CustomGameEventManager:Send_ServerToPlayer(
        PlayerResource:GetPlayer(caster:GetPlayerID()),
        "show_ability_selector",
        {
            ID = id,
            Abilities = randomAbilities,
            Type = "ultimate"
        }
    )

    local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        ability:RemoveSelf()
    else
        ability:SetCurrentCharges(charges)
    end
end
