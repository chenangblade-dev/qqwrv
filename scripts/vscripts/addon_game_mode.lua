-- Battle of Mirkwood - Battle Royale Game Mode
-- Created By Xavier @2017.4
--
GameRules.ECON_SERVER_URL = IsInToolsMode() and 'http://xavier_bom_test.ds.icu' or 'http://xavier_bom.ds.icu'
print("Loading Dota Arena, Date @ 2020.12.19")

-------------------------------------------------------------------------------------------------------------
-- 初始化游戏模式
-------------------------------------------------------------------------------------------------------------


if _G.GameMode == nil then
	_G.GameMode = class({})
end
-------------------------------------------------------------------------------------------------------------
-- 类似于python中的文件载入机制
-- 使用一个文件夹中的_loader载入文件夹中的所有需要载入的文件
-- 这个函数当然会同时运行_loader中的所有语句
-- path表示文件夹
-------------------------------------------------------------------------------------------------------------
function xrequire(path)
	local files = require(path .. '._loader')
	if not files then
		error('xrequire Failed to load' .. path)
	end

	if files and type(files) == 'table' then
		for _, file in pairs(files) do
			require(path .. '.' .. file)
		end
	elseif files and not type(files) == 'table' then
		print(path, 'doesnt return a table contains files to require, ignoring!!!!')
	end
end

xrequire 'utils'
xrequire 'modifiers'
xrequire 'modules'
require( "utils/timers" )


Precache = require "Precache" -- 预载入在这里！！！

require "Debug"
require "UI"
require "GameMode"
require 'libraries/notifications'


function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
end


local _print = print
function print(...)
	if IsInToolsMode() then
		_print(...)
	end
end

-------------------------------------------------------------------------------------------------------------
-- 以下内容没有写在函数里面，是为了在测试的时候每次reload都可以重新载入技能、单位的数据
-- 现在已经不需要写在外面了，但是懒得挪了
-- 就这样吧，目前不会有什么错误
-- 
-------------------------------------------------------------------------------------------------------------
-- 载入KV数据
-------------------------------------------------------------------------------------------------------------
GameRules.Heroes_KV = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
GameRules.Items_KV = LoadKeyValues('scripts/npc/npc_items_custom.txt')
GameRules.Units_KV = LoadKeyValues('scripts/npc/npc_units_custom.txt')
GameRules.Abilities_KV = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
GameRules.DotaItems_KV = LoadKeyValues("scripts/npc/items.txt")
GameRules.OverrideAbility_KV = LoadKeyValues("scripts/npc/npc_abilities_override.txt")
GameRules.OriginalAbilities = LoadKeyValues("scripts/npc/npc_abilities.txt")
-- 载入英雄技能列表
local hero_abilities_list = {
    "npc_dota_hero_abaddon.txt",
    "npc_dota_hero_abyssal_underlord.txt",
    "npc_dota_hero_alchemist.txt",
    "npc_dota_hero_ancient_apparition.txt",
    "npc_dota_hero_antimage.txt",
    "npc_dota_hero_arc_warden.txt",
    "npc_dota_hero_axe.txt",
    "npc_dota_hero_bane.txt",
    "npc_dota_hero_batrider.txt",
    "npc_dota_hero_beastmaster.txt",
    "npc_dota_hero_bloodseeker.txt",
    "npc_dota_hero_bounty_hunter.txt",
    "npc_dota_hero_brewmaster.txt",
    "npc_dota_hero_bristleback.txt",
    "npc_dota_hero_broodmother.txt",
    "npc_dota_hero_centaur.txt",
    "npc_dota_hero_chaos_knight.txt",
    "npc_dota_hero_chen.txt",
    "npc_dota_hero_clinkz.txt",
    "npc_dota_hero_crystal_maiden.txt",
    "npc_dota_hero_dark_seer.txt",
    "npc_dota_hero_dark_willow.txt",
    "npc_dota_hero_dawnbreaker.txt",
    "npc_dota_hero_dazzle.txt",
    "npc_dota_hero_death_prophet.txt",
    "npc_dota_hero_disruptor.txt",
    "npc_dota_hero_doom_bringer.txt",
    "npc_dota_hero_dragon_knight.txt",
    "npc_dota_hero_drow_ranger.txt",
    "npc_dota_hero_earthshaker.txt",
    "npc_dota_hero_earth_spirit.txt",
    "npc_dota_hero_elder_titan.txt",
    "npc_dota_hero_ember_spirit.txt",
    "npc_dota_hero_enchantress.txt",
    "npc_dota_hero_enigma.txt",
    "npc_dota_hero_faceless_void.txt",
    "npc_dota_hero_furion.txt",
    "npc_dota_hero_grimstroke.txt",
    "npc_dota_hero_gyrocopter.txt",
    "npc_dota_hero_hoodwink.txt",
    "npc_dota_hero_huskar.txt",
    "npc_dota_hero_invoker.txt",
    "npc_dota_hero_jakiro.txt",
    "npc_dota_hero_juggernaut.txt",
    "npc_dota_hero_keeper_of_the_light.txt",
    "npc_dota_hero_kunkka.txt",
    "npc_dota_hero_legion_commander.txt",
    "npc_dota_hero_leshrac.txt",
    "npc_dota_hero_lich.txt",
    "npc_dota_hero_life_stealer.txt",
    "npc_dota_hero_lina.txt",
    "npc_dota_hero_lion.txt",
    "npc_dota_hero_lone_druid.txt",
    "npc_dota_hero_luna.txt",
    "npc_dota_hero_lycan.txt",
    "npc_dota_hero_magnataur.txt",
    "npc_dota_hero_marci.txt",
    "npc_dota_hero_mars.txt",
    "npc_dota_hero_medusa.txt",
    "npc_dota_hero_meepo.txt",
    "npc_dota_hero_mirana.txt",
    "npc_dota_hero_monkey_king.txt",
    "npc_dota_hero_morphling.txt",
    "npc_dota_hero_muerta.txt",
    "npc_dota_hero_naga_siren.txt",
    "npc_dota_hero_necrolyte.txt",
    "npc_dota_hero_nevermore.txt",
    "npc_dota_hero_night_stalker.txt",
    "npc_dota_hero_nyx_assassin.txt",
    "npc_dota_hero_obsidian_destroyer.txt",
    "npc_dota_hero_ogre_magi.txt",
    "npc_dota_hero_omniknight.txt",
    "npc_dota_hero_oracle.txt",
    "npc_dota_hero_pangolier.txt",
    "npc_dota_hero_phantom_assassin.txt",
    "npc_dota_hero_phantom_lancer.txt",
    "npc_dota_hero_phoenix.txt",
    "npc_dota_hero_primal_beast.txt",
    "npc_dota_hero_puck.txt",
    "npc_dota_hero_pudge.txt",
    "npc_dota_hero_pugna.txt",
    "npc_dota_hero_queenofpain.txt",
    "npc_dota_hero_rattletrap.txt",
    "npc_dota_hero_razor.txt",
    "npc_dota_hero_riki.txt",
    "npc_dota_hero_rubick.txt",
    "npc_dota_hero_sand_king.txt",
    "npc_dota_hero_shadow_demon.txt",
    "npc_dota_hero_shadow_shaman.txt",
    "npc_dota_hero_shredder.txt",
    "npc_dota_hero_silencer.txt",
    "npc_dota_hero_skeleton_king.txt",
    "npc_dota_hero_skywrath_mage.txt",
    "npc_dota_hero_slardar.txt",
    "npc_dota_hero_slark.txt",
    "npc_dota_hero_snapfire.txt",
    "npc_dota_hero_sniper.txt",
    "npc_dota_hero_spectre.txt",
    "npc_dota_hero_spirit_breaker.txt",
    "npc_dota_hero_storm_spirit.txt",
    "npc_dota_hero_sven.txt",
    "npc_dota_hero_target_dummy.txt",
    "npc_dota_hero_techies.txt",
    "npc_dota_hero_templar_assassin.txt",
    "npc_dota_hero_terrorblade.txt",
    "npc_dota_hero_tidehunter.txt",
    "npc_dota_hero_tinker.txt",
    "npc_dota_hero_tiny.txt",
    "npc_dota_hero_treant.txt",
    "npc_dota_hero_troll_warlord.txt",
    "npc_dota_hero_tusk.txt",
    "npc_dota_hero_undying.txt",
    "npc_dota_hero_ursa.txt",
    "npc_dota_hero_vengefulspirit.txt",
    "npc_dota_hero_venomancer.txt",
    "npc_dota_hero_viper.txt",
    "npc_dota_hero_visage.txt",
    "npc_dota_hero_void_spirit.txt",
    "npc_dota_hero_warlock.txt",
    "npc_dota_hero_weaver.txt",
    "npc_dota_hero_windrunner.txt",
    "npc_dota_hero_winter_wyvern.txt",
    "npc_dota_hero_wisp.txt",
    "npc_dota_hero_witch_doctor.txt",
    "npc_dota_hero_zuus.txt",
    "npc_dota_hero_kez.txt",
}

for _, hero_script in pairs(hero_abilities_list) do
    pcall(function()
        local single_hero_data = LoadKeyValues("scripts/npc/heroes/" .. hero_script)
        for ability_name, hero_ability_data in pairs(single_hero_data) do
        	
            GameRules.OriginalAbilities[ability_name] = hero_ability_data
			print('loading scripts from hero script->', ability_name)
			--print(11111111111)
		
        end
    end)
end

GameRules.OriginalHeroes = LoadKeyValues("scripts/npc/npc_heroes.txt")
GameRules.AbilityHeroMap = {};

-- 为各种覆盖的技能增加定义
if GameRules.Abilities_KV then
    for k, v in pairs(GameRules.Abilities_KV) do
        GameRules.OriginalAbilities[k] = v
    end
else
    print("！！！！致命错误：npc_abilities_custom.txt 读取失败，检查括号和双引号！！！！")
end

-- 去除几个无效的字段
GameRules.OriginalHeroes['Version'] = nil
GameRules.OriginalHeroes['npc_dota_hero_target_dummy'] = nil

GameRules.ValidHeroes = LoadKeyValues("scripts/npc/herolist.txt")
--GameRules.vInnateAbilities= LoadKeyValues("scripts/npc/hero_innate.txt")
-------------------------------------------------------------------------------------------------------------
-- 处理一下英雄的KV，以英雄本身的名字作为index
-------------------------------------------------------------------------------------------------------------
if GameRules.Heroes_KV then
    for _, data in pairs(GameRules.Heroes_KV) do
        if data and type(data) == "table" then
            GameRules.Heroes_KV[data.override_hero] = data
        end
    end
else
    print("！！！！致命错误：npc_heroes_custom.txt 读取失败，检查括号和双引号！！！！")
end

for heroName, data in pairs(GameRules.OriginalHeroes) do
	if (data) and type(data) == "table" then
		for i = 1, 25 do
			local abilityName = data['Ability' .. i];
			if (abilityName ~= nil) then
				GameRules.AbilityHeroMap[abilityName] = heroName
			end
		end
	end
end

------------------------技能替换表
_G.AbilityNameReplaceMap = {
	drow_ranger_multishot = "drow_ranger_trueshot_lua",
	clinkz_death_pact = "clinkz_searing_arrows",
    dazzle_poison_touch = "dazzle_good_juju",
}
for name, replaceName in pairs(AbilityNameReplaceMap) do
	GameRules.AbilityHeroMap[replaceName] = GameRules.AbilityHeroMap[name]
end

-------------------------------------------------------------------------------------------------------------
-- 处理一下英雄的名字
-------------------------------------------------------------------------------------------------------------
for index, valid in pairs(GameRules.ValidHeroes) do
	if tonumber(valid) ~= 1 then
		GameRules.ValidHeroes[index] = nil
	end
end
GameRules.ValidHeroes = table.make_key_table(GameRules.ValidHeroes) -- 做一个key的表

-------------------------------------------------------------------------------------------------------------
-- 处理技能数据，做出几个表给游戏模式用
-------------------------------------------------------------------------------------------------------------
if GameRules.AvailableHeroesThisGame == nil then -- 重载的时候不重载技能
	local heroNameThisGame = table.random_some(table.make_key_table(GameRules.OriginalHeroes), 55)
	--if not table.contains(heroNameThisGame, "npc_dota_hero_invoker") then
		--table.insert(heroNameThisGame, 'npc_dota_hero_invoker')
	--end
	GameRules.AvailableHeroesThisGame = {}
	for _, heroName in pairs(heroNameThisGame) do
		GameRules.AvailableHeroesThisGame[heroName] = GameRules.OriginalHeroes[heroName]
	end
	GameRules.vBlackList = require("data/black_list")

	GameRules.vNormalAbilitiesPool = {}
	GameRules.vUltimateAbilitiesPool = {}
	GameRules.vInnateAbilitiesPool = {
        "abaddon_withering_mist",
"abyssal_underlord_raid_boss",
"alchemist_goblins_greed",
"ancient_apparition_death_rime",
"antimage_persectur",
"arc_warden_runic_infusion",
"axe_coat_of_blood",
"bane_ichor_of_nyctasha",
"batrider_smoldering_resin",
"beastmaster_rugged",
"bloodseeker_sanguivore",
"bounty_hunter_big_game_hunter",
"brewmaster_belligerent",
"bristleback_prickly",
"broodmother_spiders_milk",
"centaur_rawhide",
"arc_warden_runic_infusion",
"arc_warden_runic_infusion",
"clinkz_bone_and_arrow",
"legion_commander_outfight_them",
"crystal_maiden_blueheart_floe",
"dark_seer_mental_fortitude",
"dark_willow_pixie_dust",
"dawnbreaker_break_of_dawn",
"dazzle_innate_weave",
"death_prophet_witchcraft",
"disruptor_electromagnetic_repulsion",
"doom_bringer_lvl_pain",
"dragon_knight_inherited_vigor",
"drow_ranger_trueshot",
"earthshaker_spirit_cairn",
"arc_warden_runic_infusion",
"ember_spirit_immolation",
"arc_warden_runic_infusion",
"enigma_gravity_well",
"faceless_void_distortion_field",
"furion_spirit_of_the_forest",
"grimstroke_ink_trail",
"gyrocopter_chop_shop",
"hoodwink_mistwoods_wayfarer",
"huskar_blood_magic",
"invoker_mastermind",
"jakiro_double_trouble",
"juggernaut_duelist",
"keeper_of_the_light_mana_magnifier",
"keeper_of_the_light_special_reserve",
"kunkka_admirals_rum",
"leshrac_defilement",
"lich_death_charge",
"life_stealer_feast",
"lina_combustion",
"lion_to_hell_and_back",
"lone_druid_gift_bearer",
"luna_lunar_blessing",
"arc_warden_runic_infusion",
"magnataur_solid_core",
"arc_warden_runic_infusion",
"mars_dauntless",
"medusa_mana_shield",
"arc_warden_runic_infusion",
"monkey_king_mischief",
"morphling_accumulation",
"arc_warden_runic_infusion",
"necrolyte_sadist",
"nevermore_necromastery",
"night_stalker_heart_of_darkness",
"nyx_assassin_nyxth_sense",
"obsidian_destroyer_ominous_discernment",
"arc_warden_runic_infusion",
"omniknight_degen_aura",
"arc_warden_runic_infusion",
"pangolier_fortune_favors_the_bold",
"phantom_assassin_immaterial",
"phantom_lancer_illusory_armaments",
"phoenix_blinding_sun",
"primal_beast_colossal",
"puck_puckish",
"pudge_innate_graft_flesh",
"pugna_oblivion_savant",
"queenofpain_bondage",
"queenofpain_succubus",
"rattletrap_armor_power",
"razor_unstable_current",
"riki_innate_backstab",
"rubick_might_and_magus",
"sandking_caustic_finale",
"shadow_demon_menace",
"shadow_shaman_fowl_play",
"shredder_exposure_therapy",
"silencer_brain_drain",
"skeleton_king_vampiric_spirit",
"skywrath_mage_ruin_and_restoration",
"slardar_seaborn_sentinel",
"slark_barracuda",
"snapfire_buckshot",
"sniper_keen_scope",
"spectre_spectral",
"spirit_breaker_herd_mentality",
"storm_spirit_galvanized",
"sven_vanquisher",
"tiny_insurmountable",
"arc_warden_runic_infusion",
"terrorblade_dark_unity",
"tidehunter_blubber",
"tinker_eureka",
"tiny_craggy_exterior",
"tiny_rocksteady",
"treant_natures_guise",
"troll_warlord_berserkers_rage",
"arc_warden_runic_infusion",
"undying_ceaseless_dirge",
"ursa_maul",
"vengefulspirit_retribution",
"venomancer_sepsis",
"viper_predator",
"visage_lurker",
"void_spirit_intrinsic_edge",
"warlock_eldritch_summoning",
"weaver_rewoven",
"windrunner_easy_breezy",
"arc_warden_runic_infusion",
"witch_doctor_gris_gris",
"winter_wyvern_eldwurm_scholar",
"zuus_static_field",
"muerta_supernatural",
"ringmaster_dark_carnival_souvenirs",
"marci_special_delivery",
"meepo_sticky_fingers",
"morphling_accumulation",
"gyrocopter_chop_shop",
"oracle_prognosticate",
"mirana_selemenes_faithful",
"chaos_knight_reins_of_chaos",
"naga_siren_eelskin",
"juggernaut_bladeform",
"techies_squees_scope",
"elder_titan_tip_the_scales",
"treant_innate_attack_damage",
"lycan_apex_predator",
"templar_assassin_third_eye",
"wisp_sight_seer",
"ogre_magi_dumb_luck",
"tusk_bitter_chill",
"kez_switch_weapons",
"abaddon_the_quickening",
"enchantress_rabblerouser",
"morphling_flow",
"skywrath_mage_staff_of_the_scion",
"lone_druid_bear_necessities",
"techies_squees_scope",
"dark_seer_quick_wit",
"dazzle_nothl_boon",
"centaur_horsepower",
"dark_seer_aggrandize",
"earthshaker_slugger",
"drow_ranger_vantage_point",

}


	GameRules.vHeroAbilityPoolForPlus = {}

	for heroName, data in pairs(GameRules.AvailableHeroesThisGame) do
		if type(data) == "table" then

			local hero_abilities = {}

			for i = 1, 23 do
				local abilityName = data["Ability" .. i]
				if abilityName then
					if (AbilityNameReplaceMap[abilityName]) then
						abilityName = AbilityNameReplaceMap[abilityName]
					end

					if GameRules.OriginalAbilities[abilityName] and
						GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ATTRIBUTES" and
						not table.contains(GameRules.vBlackList, abilityName) 
						and not  table.contains(GameRules.vInnateAbilitiesPool, abilityName)
						then
						local abilityType = GameRules.OriginalAbilities[abilityName].AbilityType

						table.insert(hero_abilities, abilityName)

						-- 根据技能类型的不同，分别放到各自的表中
						if abilityType ~= "DOTA_ABILITY_TYPE_ULTIMATE" then
							table.insert(GameRules.vNormalAbilitiesPool, abilityName)
						else
							table.insert(GameRules.vUltimateAbilitiesPool, abilityName)
						end
					end
				end
			end

			table.insert(GameRules.vHeroAbilityPoolForPlus, {hero = heroName, abilities = hero_abilities})
		end
	end
end

-- 处理一下物品掉落
GameRules.NeutralItemsKV = LoadKeyValues('scripts/npc/neutral_items.txt')
GameRules.vNeutralItemDropTable = {}
for tier, def in pairs(GameRules.NeutralItemsKV) do
	tier = tonumber(tier)
	GameRules.vNeutralItemDropTable[tier] = {}

	GameRules.vNeutralItemDropTable[tier].items = {}
	for itemName, enabled in pairs(def.items) do
		if tonumber(enabled) == 1 then
			table.insert(GameRules.vNeutralItemDropTable[tier].items, itemName)
		end
	end
	local dropRate = def.drop_rates
	GameRules.vNeutralItemDropTable[tier].drop_rates = {}
	for k, v in pairs(dropRate) do
		local time = string.split(k, ' - ')
		local min = string.split(time[1], ':')
		local max = string.split(time[3], ':')
		local time_min = tonumber(min[1]) * 60 + tonumber(min[2])
		local time_max = tonumber(max[1]) * 60 + tonumber(max[2])
		table.insert(GameRules.vNeutralItemDropTable[tier].drop_rates, {
			time_min = time_min,
			time_max = time_max,
			drop_rate = v,
		})	
	end
end

GameRules.vPassiveModeActiveAbilities = table.join(
	{
		"magnataur_empower", -- 授予力量
	},
	GameRules.CourierOnlyAbilities
)


-------------------------------------------------------------------------------------------------------------
-- imba的函数
-------------------------------------------------------------------------------------------------------------
function CDOTA_BaseNPC:AddEndChannelListener(listener)
  	local endChannelListeners = self.EndChannelListeners or {}
  	self.EndChannelListeners = endChannelListeners
  	local index = #endChannelListeners + 1
  	endChannelListeners[index] = listener
end

function CDOTA_BaseNPC:IS_TrueHero_TG()
    return  self:IsRealHero() and (not self:IsTempestDouble() and not self:IsIllusion() and not self:IsClone() and (self:GetUnitName()~="npc_dota_courier" or self:GetUnitName()~="npc_dota_flying_courier"))-- or self:GetName()~="npc_dota_hero_target_dummy"
end

function CDOTA_BaseNPC:Has_Aghanims_Shard()
  return  self:HasModifier("modifier_item_aghanims_shard")
end

function CDOTA_Modifier_Lua:CheckMotionControllers()
	local parent = self:GetParent()
	local modifier_priority = self:GetMotionControllerPriority()
	local is_motion_controller = false
	local motion_controller_priority
	local found_modifier_handler

	if parent:HasModifier("modifier_batrider_flaming_lasso") or parent:HasModifier("modifier_eul_cyclone") then
		self:Destroy()
		return false
	end

	local non_imba_motion_controllers ={
	"modifier_morphling_waveform",
	"modifier_morphling_adaptive_strike",
	"modifier_ember_spirit_fire_remnant",
	"modifier_monkey_king_bounce_leap",
	"modifier_batrider_flaming_lasso",
	"modifier_earth_spirit_boulder_smash",
	"modifier_earth_spirit_geomagnetic_grip",
	"modifier_tiny_toss",
	"modifier_tusk_walrus_punch_air_time",
	"modifier_rattletrap_hookshot",
	"modifier_rattletrap_cog_push",
	"modifier_beastmaster_prima_roar_push",
	"modifier_brewmaster_storm_cyclone",
	"modifier_dark_seer_vacuum",
	"modifier_eul_cyclone",
	"modifier_earth_spirit_rolling_boulder_caster",
	"modifier_huskar_life_break_charge",
	"modifier_invoker_deafening_blast_knockback",
	"modifier_invoker_tornado",
	"modifier_item_forcestaff_active",
	"modifier_rattletrap_hookshot",
	"modifier_phoenix_icarus_dive",
	"modifier_shredder_timber_chain",
	"modifier_slark_pounce",
	"modifier_spirit_breaker_charge_of_darkness",
	"modifier_earthshaker_enchant_totem_leap",
	"modifier_tusk_walrus_kick_air_time",
	}

	-- Fetch all modifiers
	local modifiers = parent:FindAllModifiers()	

	for _,modifier in pairs(modifiers) do		
		-- Ignore the modifier that is using this function
		if self ~= modifier then			

			-- Check if this modifier is assigned as a motion controller
			if modifier.IsMotionController then
				if modifier:IsMotionController() then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- Get the motion controller priority
					motion_controller_priority = modifier:GetMotionControllerPriority()
					if modifier.IsStunDebuff and modifier:IsStunDebuff() then
						motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST + 1
					end
					-- Stop iteration					
					break
				end
			end

			-- If not, check on the list
			for _,non_imba_motion_controller in pairs(non_imba_motion_controllers) do				
				if modifier:GetName() == non_imba_motion_controller then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- We assume that vanilla controllers are the highest priority
					motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST

					-- Stop iteration					
					break
				end
			end
		end
	end

	-- If this is a motion controller, check its priority level
	if is_motion_controller and motion_controller_priority then

		-- If the priority of the modifier that was found is higher, override
		if motion_controller_priority > modifier_priority then			
			return false

		-- If they have the same priority levels, check which of them is older and remove it
		elseif motion_controller_priority == modifier_priority then			
			if found_modifier_handler:GetCreationTime() >= self:GetCreationTime() then				
				return false
			else				
				found_modifier_handler:Destroy()
				return true
			end

		-- If the modifier that was found is a lower priority, destroy it instead
		else			
			parent:InterruptMotionControllers(true)
			found_modifier_handler:Destroy()
			return true
		end
	else
		-- If no motion controllers were found, apply
		return true
	end
end


--[[
★获取目标的状态抗性并计算技能debuff时间。
--]]



function CDOTA_BaseNPC:AddNewModifier_RS(caster,ab,modifier,table)
   if table.duration and table.duration>0 then
      table.duration=TG_StatusResistance_GET(self, table.duration)
   end
   local mod=self:AddNewModifier(caster, ab, modifier, table)
   return mod
end

function TG_StatusResistance_GET(target,duration)
  if not RS_Switch then
        return duration
  end
  local status_res = target:GetStatusResistance()
  local dur=math.ceil(duration*status_res*100)/100
    if status_res>0 then
        return duration-dur
    elseif status_res<0 then
        return duration+dur*-1
    end
        return duration
end


function TG_AddNewModifier_RS(target,caster,ab,modifier,table)
  table.duration=TG_StatusResistance_GET(target, table.duration)
  target:AddNewModifier(caster, ab, modifier, table)
end

--[[
★获取英雄天赋值。
--]]
function CDOTA_BaseNPC:TG_GetTalentValue(name, kv)
	if self:HasModifier("modifier_"..name) then
		local value_name = kv or "value"
		local specialVal = AbilityKV[name]["AbilitySpecial"]
		for k,v in pairs(specialVal) do
				if v[value_name] then
					return v[value_name]
				end
		end
	end    
			return 0
end

function CDOTA_BaseNPC:IsUnit()
	return self:IsHero() or self:IsCreep() or self:IsBoss()
end


--[[
★查找表中是否有该数据。
--]]
function Is_DATA_TG(table, data)
	  for i=1, #table do
        if table[i] == data then
          return true
        end
    end
	      return false
end


--[[
★刷新所有技能
--]]
function TG_Refresh_AB(c)
    for i = 0, 23 do
        local AB = c:GetAbilityByIndex(i)
        if AB then
            AB:RefreshCharges()
            AB:EndCooldown()
        end
    end
end

function CDOTA_BaseNPC:TG_Refresh_AB_Limit()
    for i = 0, 23 do
        local AB = self:GetAbilityByIndex(i)
        if AB then
            AB:RefreshCharges()
            AB:EndCooldown()
        end
    end
end

function IsEnemy(unit1, unit2)
	if unit1:GetTeamNumber() == unit2:GetTeamNumber() then
		return false
	else
		return true
	end
end

function CDOTA_BaseNPC:TriggerStandardTargetSpell(ability)
	if IsEnemy(self, ability:GetCaster()) then
		self:TriggerSpellReflect(ability)
		return self:TriggerSpellAbsorb(ability)
	end
	return false
end

--[[
★林肯与莲花。
--]]
function CDOTA_BaseNPC:TG_TriggerSpellAbsorb(ab)
  if not Is_Chinese_TG(self, ab:GetCaster()) then
    --      self:TriggerSpellReflect(ab)
      return self:TriggerSpellAbsorb(ab)
	end
	return false
end

--[[
★判断目标是否是友军（厉害了我的中国）。
--]]
function Is_Chinese_TG(tar1, tar2)
    if tar1:GetTeamNumber()==tar2:GetTeamNumber() then
        return true
    end
       return false
end

--[[
★判断是否拥有此天赋。
]]

function CDOTA_BaseNPC:TG_HasTalent(name)
	if self:HasModifier("modifier_"..name) then
		  	return true
	end
	  		return false
end 
-------------------------------------------------------------------------------------------------------------
-- 这里结束 注意注意！！！！！！！！！！！！！！！！！！！！！！！
-------------------------------------------------------------------------------------------------------------


if not IsInToolsMode() then return end