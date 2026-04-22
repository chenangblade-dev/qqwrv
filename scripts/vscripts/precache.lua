local particles = {
    "particles/treasure_courier_death.vpcf",
    "particles/leader/leader_overhead.vpcf",
    "particles/generic_gameplay/screen_damage_indicator.vpcf",
    "particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_debuff_ti7.vpcf",
    "particles/status_fx/status_effect_poison_viper.vpcf",
    "particles/generic_gameplay/screen_poison_indicator.vpcf",
    "particles/neutral_fx/roshan_timer_b.vpcf",
    "particles/core/border.vpcf",
    "particles/econ/events/golden_lotus_effect.vpcf",
    "particles/imagine_assets/courier_fx/rainbow_tail.vpcf",
    "particles/imagine_assets/courier_fx/water_curtain.vpcf",
    "particles/wings/wing_sf_goldsky_gold.vpcf",
    "particles/econ/summer_1.vpcf",
    "particles/econ/summer_2.vpcf",
    "particles/econ/summer_3.vpcf",
    "particles/msg_fx/msg_bingshuangzhixin_damage.vpcf",
    "particles/econ/events/summer_2021/summer_2021_emblem_effect.vpcf",
    "particles/emable_effect/music_bounce/music_bounce.vpcf",
    "particles/emable_effect/force_staff_spring_2021.vpcf",  
    "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf",
    "models/items/lycan/ultimate/ambry_true_form/ambry_true_form.vmdl", 
    "models/items/courier/mole_messenger/mole_messenger_lvl2.vmdl",
    "models/heroes/undying/undying_flesh_golem.vmdl", 
}

local sounds = {
    "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts",
    "soundevents/x_custom_sounds.vsndevts",
    "soundevents/game_sounds_taunts.vsndevts",
}

local function PrecacheEverythingFromTable( context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            PrecacheEverythingFromTable( context, value )
        else
            if string.find(value, "vpcf") then
                PrecacheResource( "particle", value, context)
            end
            if string.find(value, "vmdl") then
                PrecacheResource( "model", value, context)
            end
            if string.find(value, "vsndevts") then
                PrecacheResource( "soundfile", value, context)
            end
        end
    end
end

function PrecacheEverythingFromKV( context )
    local kv_files = {
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_abilities_custom.txt",
        "scripts/npc/npc_heroes_custom.txt",
        "scripts/npc/npc_abilities_override.txt",
        "scripts/npc/npc_items_custom.txt",
        "scripts/npc/npc_heroes.txt",
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            -- print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
            PrecacheEverythingFromTable( context, kvs)
        end
    end
end

return function(context)
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
    PrecacheEverythingFromKV(context)
    
    for _, p in pairs(particles) do
        PrecacheResource("particle", p, context)
    end
    for _, p in pairs(sounds) do
        PrecacheResource("soundfile", p, context)
    end

	--for unit in pairs(LoadKeyValues("scripts/npc/npc_units_custom.txt")) do
        --PrecacheUnitByNameSync(unit,context,0)
    --end

    PrecacheItemByNameSync( "item_treasure_chest", context )
    PrecacheModel( "item_treasure_chest", context )

    -- precache
    if (GameRules.GameMode and GameRules.GameMode.cachedHeroes) then
        for hero in pairs(GameRules.GameMode.cachedHeroes) do
            PrecacheUnitByNameSync(hero, context, -1)
        end
    end
end