 ---------------------------------------------------------------------------------
-- 注册UI js发来的事件的监听
---------------------------------------------------------------------------------
function GameMode:RegisterUIEventListeners()
	CustomGameEventManager:RegisterListener("player_select_ability",function(_, keys)
		self:OnPlayerSelectAbility(keys)
	end)
	CustomGameEventManager:RegisterListener("player_confirm_ability_remove", function(_, keys)
		self:OnPlayerConfirmAbilityRemove(keys)
	end)

	CustomGameEventManager:RegisterListener("player_reselect_hero", function(_, keys)
		self:OnPlayerReselectHero(keys)
	end)
	CustomGameEventManager:RegisterListener("player_cancel_hero_reselect", function(_, keys)
			self:OnPlayerCancelReselectHero(keys)

	end)

	CustomGameEventManager:RegisterListener('player_vote', function(_, keys)
		self:OnPlayerVote(keys)
	end)
	CustomGameEventManager:RegisterListener('player_agree_to_shuffle', function(_, keys)
		self:OnPlayerAgreeToShuffle(keys)
	end)
	CustomGameEventManager:RegisterListener('player_vote_for_free_mode', function(_, keys)
		self:OnPlayerVoteForFreeMode(keys)
	end)

	CustomGameEventManager:RegisterListener('bom_ask_star', function(_, keys)
		self:OnClientAskForStar(keys)
	end)
	CustomGameEventManager:RegisterListener('player_rerandom_hero', function(_, keys)
		self:OnPlayerReRandomHero(keys)
	end)

	CustomGameEventManager:RegisterListener('player_taunt', function(_, keys)
		self:OnPlayerTaunt(keys)
	end)
end


-- 有附属技能的技能
local pairedAbility = {
	shredder_chakram="shredder_return_chakram", 
	shredder_chakram_2="shredder_return_chakram_2",
	elder_titan_ancestral_spirit="elder_titan_return_spirit" , 
	phoenix_icarus_dive="phoenix_icarus_dive_stop" , 
	phoenix_sun_ray="phoenix_sun_ray_stop",
	phoenix_fire_spirits="phoenix_launch_fire_spirit",
	alchemist_unstable_concoction="alchemist_unstable_concoction_throw",
	naga_siren_song_of_the_siren="naga_siren_song_of_the_siren_cancel",
	rubick_telekinesis="rubick_telekinesis_land",
	bane_nightmare="bane_nightmare_end",
	ancient_apparition_ice_blast="ancient_apparition_ice_blast_release",
	wisp_tether="wisp_tether_break",
	pangolier_gyroshell="pangolier_gyroshell_stop",
	nyx_assassin_burrow="nyx_assassin_unburrow",
	-- necrolyte_sadist = 	"necrolyte_sadist_stop",
	-- puck_illusory_orb= "puck_ethereal_jaunt",
	dawnbreaker_celestial_hammer = "dawnbreaker_converge",
	hoodwink_sharpshooter = "hoodwink_sharpshooter_release",
	primal_beast_onslaught = "primal_beast_onslaught_release",

}
-- 有些技能需要buff计数
local brokenModifierCounts = {
	modifier_shadow_demon_demonic_purge_charge_counter = 3,
	modifier_bloodseeker_rupture_charge_counter = 2,
	modifier_earth_spirit_stone_caller_charge_counter = 6,
	modifier_ember_spirit_fire_remnant_charge_counter = 3,
	modifier_obsidian_destroyer_astral_imprisonment_charge_counter = 1
}
-- 有些技能的modifier需要手动添加modifier
local brokenModifierAbilityMap = {
	shadow_demon_demonic_purge = "modifier_shadow_demon_demonic_purge_charge_counter",
	bloodseeker_rupture = "modifier_bloodseeker_rupture_charge_counter",
	earth_spirit_stone_caller="modifier_earth_spirit_stone_caller_charge_counter",
	ember_spirit_fire_remnant="modifier_ember_spirit_fire_remnant_charge_counter",
	obsidian_destroyer_astral_imprisonment="modifier_obsidian_destroyer_astral_imprisonment_charge_counter"
	
}
-- 有些技能的modifier需要重载
local brokenPassiveModifierAbilities = {
	drow_ranger_marksmanship = "modifier_drow_ranger_marksmanship",
	juggernaut_blade_dance = "modifier_juggernaut_blade_dance",
	legion_commander_moment_of_courage = "modifier_legion_commander_moment_of_courage",
	axe_counter_helix = "modifier_axe_counter_helix",
	abaddon_frostmourne = "modifier_abaddon_frostmourne",
	monkey_king_jingu_mastery = "modifier_monkey_king_quadruple_tap",
	necrolyte_heartstopper_aura = "modifier_necrolyte_heartstopper_aura",
	lina_fiery_soul = "modifier_lina_fiery_soul",
	visage_gravekeepers_cloak = "modifier_visage_gravekeepers_cloak",
	viper_poison_attack = "modifier_viper_poison_attack",
	zuus_arc_lightning= "modifier_zuus_lightning_hands",
	beastmaster_drums_of_slom="modifier_beastmaster_drums_of_slom",
	zuus_arc_lightning="modifier_hero_attradd",

}

-- 有的技能需要添加附属技能
local subAbilitiesMap = {
	ember_spirit_fire_remnant = "ember_spirit_activate_fire_remnant",
	earth_spirit_boulder_smash = 'earth_spirit_stone_caller',
	earth_spirit_rolling_boulder = 'earth_spirit_stone_caller',
	earth_spirit_geomagnetic_grip = 'earth_spirit_stone_caller',
	puck_illusory_orb= "puck_ethereal_jaunt",
	monkey_king_tree_dance="monkey_king_primal_spring",

	spectre_haunt="spectre_reality",
	zuus_arc_lightning="zuus_lightning_hands",
	obsidian_destroyer_arcane_orb="obsidian_destroyer_equilibrium",
}

---------------------------------------------------------------------------------
-- 玩家选择技能
---------------------------------------------------------------------------------
function GameMode:OnPlayerSelectAbility(keys)
	local abilityName = keys.AbilityName
		-- 强制转换为替换后的技能
	if AbilityNameReplaceMap[abilityName] ~= nil then
		abilityName = AbilityNameReplaceMap[abilityName]
	end

	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero  = player:GetAssignedHero()
	if not hero then return end

	hero.__playerHaveSelectedAbility__ = true

	local id = keys.AbilityPanelID
	player.__vPlayerAbilityPanel__ = player.__vPlayerAbilityPanel__ or {}
	if player.__vPlayerAbilityPanel__[id] then return end
	player.__vPlayerAbilityPanel__[id] = true

	GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
	local abilities = GameRules.vSpellbookRecorder[id]
	if not abilities or not table.contains(abilities, abilityName) then
		if not IsInToolsMode() then
			print("this is not abilities from server")
			return
		end
	end
	GameRules.vSpellbookRecorder[id] = nil

	if abilityName == "Cancel" then
		return
	end

	self.cachedHeroes = self.cachedHeroes or {};
	local heroName = GameRules.AbilityHeroMap[abilityName]
	if heroName and self.cachedHeroes[heroName] ~= true then
		-- print("begin to precache hero resource")
		local precacheName = "npc_precache_" .. heroName
		self.cachedHeroes[heroName] = true
		PrecacheUnitByNameAsync(precacheName, function() end)

	end

	-- 提示玩法无法出晕锤
	if abilityName == "slardar_bash"
		or abilityName == "spirit_breaker_greater_bash"
		or abilityName == "faceless_void_time_lock"
		then
		msg.bottom("#hud_tooltip_cannot_bash", playerID, nil, "General.PingWarning")
	end

	if subAbilitiesMap[abilityName] then
		if not hero:HasAbility(subAbilitiesMap[abilityName]) and not hero:HasAbility("empty_a5") then
			msg.bottom("#hud_tooltip_cannot_add_another_sub_ability", playerID, nil, "General.PingWarning")
			return
		end
	end

	-- 尝试修复marksmanship
	if brokenPassiveModifierAbilities[abilityName] then
		Timer(0.1, function()
			if hero:HasAbility(abilityName) then
				hero:RemoveModifierByName(brokenPassiveModifierAbilities[abilityName])
				hero:AddNewModifier(hero, hero:FindAbilityByName(abilityName), brokenPassiveModifierAbilities[abilityName], {})
			end
		end)
	end



	-- 如果是多重施法，替换为新的多重施法
	local CustomLuaAbilities = {
		"invoker_alacrity",
		"invoker_deafening_blast",
		"invoker_emp",
		"invoker_sun_strike",
		"invoker_tornado",
		"invoker_chaos_meteor",
	}
	local CustomLuaAbilities_Ultimate = {
		"ogre_magi_multicast",
	}
	
	if table.contains(CustomLuaAbilities_Ultimate, abilityName) or table.contains(CustomLuaAbilities, abilityName) then
		abilityName = abilityName .. '_lua'
	end

	-- 剑舞
	if abilityName == "juggernaut_blade_dance" and  hero:GetUnitName() == "npc_dota_hero_juggernaut" then
		abilityName = abilityName .. '_lua'
	end	
	-- 月刃
	if abilityName == "luna_moon_glaive" and  hero:GetUnitName() == "npc_dota_hero_luna" then
		abilityName = 'imba_'.. abilityName 
	end	
	-- pom跳
	if abilityName == "mirana_leap" and  hero:GetUnitName() == "npc_dota_hero_mirana" then
		abilityName = 'imba_'.. abilityName 
	end	
	-- 夜魔被动
	--if abilityName == "night_stalker_hunter_in_the_night" and  hero:GetUnitName() == "npc_dota_hero_night_stalker" then
		--abilityName = 'hunter_in_the_night'
	--end	
	-- 夜魔大
	if abilityName == "night_stalker_darkness" and  hero:GetUnitName() == "npc_dota_hero_night_stalker" then
		abilityName = 'darkness'
	end	
	-- 凋零 
	if abilityName == "enigma_midnight_pulse"  then
		abilityName = 'midnight_pulse'
	end
	-- 凋零 
	if abilityName == "muerta_gunslinger"  then
		abilityName = 'ability_hero_Gunslinger'
	end
	-- 推进 
	--if abilityName == "enchantress_impetus"  then
	--	abilityName = 'impetus'
	--end
	-- 赤魂 
	if abilityName == "lina_fiery_soul"  then
		abilityName = 'fiery_soul'
	end
	-- 凋零 
	if abilityName == "lycan_shapeshift"  then
		abilityName = 'shapeshift'
	end
	-- 天怒C
	--if abilityName == "skywrath_mage_arcane_bolt" and  hero:GetUnitName() == "npc_dota_hero_skywrath_mage" then
		--abilityName = 'oldsky_abolt'
	--end	
	-- 复仇光环
	if abilityName == "vengefulspirit_command_aura"  and  hero:GetUnitName() == "npc_dota_hero_vengefulspirit" then
		abilityName = 'command_aura'
	end	

	-- pa大
	if abilityName == "phantom_assassin_coup_de_grace" and  hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
		abilityName = 'coup_de_grace'
	end	
	if abilityName == "faceless_void_time_walk"  then
		abilityName = 'imba_faceless_void_time_walk'
	end	
	--if abilityName == "marci_companion_run"  then
		--abilityName = 'imba_marci_1'
	--end
	-- 如果是已经拥有的技能，那么就不添加技能，如果不满级，那么加一级
	if hero:HasAbility(abilityName) then
		local ability = hero:FindAbilityByName(abilityName)
		if ability:GetLevel() < ability:GetMaxLevel() then
			ability:SetLevel(ability:GetLevel() + 1)
		end

		-- 新的玩法： 现在会额外增加数值！

		return
	end

	-- 找到一个空白的技能来替换
	local abilityName_Replace
	if table.contains(GameRules.vUltimateAbilitiesPool, abilityName) 
		or table.contains(GameRules.vCourierAbilities_Ultimate, abilityName)
		or (IsInToolsMode() and GameRules.OriginalAbilities[abilityName].AbilityType == "DOTA_ABILITY_TYPE_ULTIMATE")
		or table.contains(CustomLuaAbilities_Ultimate, string.gsub(abilityName, '_lua', ''))
		or abilityName=='darkness'
		or abilityName=='coup_de_grace'
		or abilityName== 'shapeshift'

		then
		if hero:HasAbility("empty_a6") then
			abilityName_Replace = "empty_a6"
		end
	elseif abilityName == "gyrocopter_flak_cannon" and  hero:GetUnitName() == "npc_dota_hero_gyrocopter" then
		if hero:HasAbility("empty_a4") then
			abilityName_Replace = "empty_a4"
		end
	elseif abilityName == "clinkz_searing_arrows" and  hero:GetUnitName() == "npc_dota_hero_clinkz" then
		if hero:HasAbility("empty_a4") then
			abilityName_Replace = "empty_a4"
		end
	elseif abilityName == "antimage_mana_break" and  hero:GetUnitName() == "npc_dota_hero_antimage" then
		if hero:HasAbility("empty_a4") then
			abilityName_Replace = "empty_a4"
		end 
	elseif abilityName == "ogre_magi_fireblast" and  hero:GetUnitName() == "npc_dota_hero_ogre_magi" then
		if hero:HasAbility("empty_a4") then
			abilityName_Replace = "empty_a4"
		end
	elseif abilityName == "ursa_fury_swipes" and  hero:GetUnitName() == "npc_dota_hero_ursa" then
		if hero:HasAbility("empty_a4") then
			abilityName_Replace = "empty_a4"
		end
	elseif abilityName == "ember_spirit_sleight_of_fist" and  hero:GetUnitName() == "npc_dota_hero_ember_spirit" then
		if hero:HasAbility("empty_a4") then
			abilityName_Replace = "empty_a4"
		end
	elseif abilityName == "tiny_tree_grab" and  hero:GetUnitName() == "npc_dota_hero_tiny" then
		if hero:HasAbility("empty_a4") then
			abilityName_Replace = "empty_a4"
		end
	elseif table.contains(GameRules.vNormalAbilitiesPool, abilityName) 
		or table.contains(GameRules.vCourierAbilities_Normal, abilityName)
		or (IsInToolsMode() and GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ULTIMATE")
		or table.contains(CustomLuaAbilities, string.gsub(abilityName, '_lua', ''))
		or abilityName== "juggernaut_blade_dance_lua"
		or abilityName== "imba_luna_moon_glaive"
		or abilityName== "imba_mirana_leap"
		--or abilityName== 'hunter_in_the_night'
		or abilityName== 'midnight_pulse'
		or abilityName== 'ability_hero_Gunslinger'
		or abilityName== 'oldsky_abolt'
		or abilityName== 'command_aura'
		or abilityName== 'imba_faceless_void_time_walk'
		or abilityName== 'imba_marci_1'
		--or abilityName== 'impetus'
		or abilityName== 'fiery_soul'

		then

		local empty_abilities = {
			"empty_a1",
			"empty_a2",
			"empty_a3",
		}

		if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
			table.insert(empty_abilities, "empty_a4")
		end

		for _, name in pairs(empty_abilities) do
			if hero:HasAbility(name) then
				abilityName_Replace = name
				break
			end
		end
	end

	if abilityName_Replace == nil then 
		msg.bottom("#hud_error_ability_is_full", hero:GetPlayerID())
		return 
	end

	hero:AddAbility(abilityName)
	hero:SwapAbilities(abilityName,abilityName_Replace,true,false)
	local ability = hero:FindAbilityByName(abilityName)
	ability:UpgradeAbility(true)

	-- 记录这个技能替换的技能到底是哪个
	hero._vAbilityNameReplaceMap = hero._vAbilityNameReplaceMap or {}
	hero._vAbilityNameReplaceMap[abilityName] = abilityName_Replace

	-- 有modifier支持的
	if brokenModifierAbilityMap[abilityName] then
		local modifier = hero:FindModifierByName(brokenModifierAbilityMap[abilityName])
		if modifier then
			local stack = brokenModifierCounts[brokenModifierAbilityMap[abilityName]]
			modifier:SetStackCount(stack)
		end
	end

	-- 如果有附技能的，为其添加附技能
	if pairedAbility[abilityName] then
		hero:AddAbility(pairedAbility[abilityName])
		hero:FindAbilityByName(pairedAbility[abilityName]):SetLevel(1)

		-- 记录附属技能也是使用这个技能替换的，这样可以用附属技能来移除技能
		hero._vAbilityNameReplaceMap[pairedAbility[abilityName]] = abilityName_Replace
	end

	-- 如果有2技能的，为他添加2技能
	if subAbilitiesMap[abilityName] then
		local subAbilityName = subAbilitiesMap[abilityName]
		if not hero:HasAbility(subAbilityName) and hero:HasAbility("empty_a5") then
			local add = hero:AddAbility(subAbilityName)
			add:SetLevel(1)
			hero:SwapAbilities(subAbilityName, "empty_a5", true, false)
			hero:RemoveAbility("empty_a5")
		end
	end

		-- 瞄准的特殊修复 7.23
	if abilityName == "sniper_take_aim" 
		and not hero:HasModifier('modifier_sniper_take_aim_fix') then
		Timer(function()
			if not hero:IsAlive() then
				return 0.1
			end
			hero:AddNewModifier(hero, nil, 'modifier_sniper_take_aim_fix', {})
		end)
	end
	-- 滚滚
	--if abilityName == "pangolier_swashbuckle" 
		--and  hero:GetUnitName() == "npc_dota_hero_pangolier" 
		--then
		--hero:AddNewModifier(hero, nil, 'modifier_npc_dota_hero_pangolier_1', {})
	--end
	-- 谜团
	if abilityName == "enigma_black_hole" 
		and  hero:GetUnitName() == "npc_dota_hero_enigma" 
		then
		hero:AddNewModifier(hero, nil, 'modifier_npc_dota_hero_enigma_1', {})
	end
	-- 谜团
	if abilityName == "razor_plasma_field" 
		and  hero:GetUnitName() == "npc_dota_hero_razor" 
		then
		hero:AddNewModifier(hero, nil, 'modifier_npc_dota_hero_razor_1', {})
	end
	-- 夜魔
	--if abilityName == "night_stalker_darkness" 
		--and  hero:GetUnitName() == "npc_dota_hero_night_stalker" 
		--then
		--hero:AddNewModifier(hero, nil, 'modifier_npc_dota_hero_night_stalker_1', {})
	--end
	-- 邪能小黑
		if abilityName == "dazzle_bad_juju" 
		and  hero:GetUnitName() == "npc_dota_hero_drow_ranger" 
		then
		hero:AddNewModifier(hero, nil, 'modifier_hero_cooldown_percentage', {})

	end
	-- 时间漫游
	if abilityName == "imba_faceless_void_time_walk" 
		and  hero:GetUnitName() == "npc_dota_hero_faceless_void" then
		if not hero:HasAbility("faceless_void_time_lock") and hero:HasAbility("empty_a4") then
			local add = hero:AddAbility("faceless_void_time_lock")
			add:SetLevel(1)
			hero:SwapAbilities("faceless_void_time_lock", "empty_a4", true, false)
			hero:RemoveAbility("empty_a4")
		end
	end
	-- 时间漫游
	if abilityName == "legion_commander_duel" 
		and  hero:GetUnitName() == "npc_dota_hero_legion_commander" then
			hero:AddNewModifier(hero, nil, 'modifier_npc_dota_hero_pangolier_1', {})

		if not hero:HasAbility("legion_commander_moment_of_courage") and hero:HasAbility("empty_a4") then
			local add = hero:AddAbility("legion_commander_moment_of_courage")
			add:SetLevel(1)
			hero:SwapAbilities("legion_commander_moment_of_courage", "empty_a4", true, false)
			hero:RemoveAbility("empty_a4")
			Timer(0.5, function()
					hero:RemoveModifierByName("modifier_legion_commander_moment_of_courage")
					hero:AddNewModifier(hero, hero:FindAbilityByName("legion_commander_moment_of_courage"),"modifier_legion_commander_moment_of_courage", {})
			end)
		end
	end
	hero:RemoveAbility(abilityName_Replace)
end

-- 在拥有这些modifier的时候删除技能，可能会导致游戏崩溃，所以不给删
local gameBreakingModifiers = {
	"modifier_spirit_breaker_charge_of_darkness",
	"modifier_mirana_leap",
	"modifier_morphling_waveform",
	"modifier_slark_pounce",
}

---------------------------------------------------------------------------------
-- 确认技能删除
---------------------------------------------------------------------------------
function GameMode:OnPlayerConfirmAbilityRemove(keys)
	local abilityName = keys.AbilityName
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero  = player:GetAssignedHero()
	if not hero then return end

	hero.__remove_ability_state = nil

	if abilityName == "Canceled" then
		msg.bottom('#CANCELED', playerID, "#00aa0066", "General.PingWarning")
		return 
	end

	-- 如果是死亡状态，不给移除技能
	if not hero:IsAlive() then
		msg.bottom('#cannot_remove_ability_dead', playerID)
		return
	end

	if abilityName == "shuxingfujia" and hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL 
		
        then 
        	
				msg.bottom('#cannot_remove_this_ability_now', playerID)
		return
	end


	if hero:IsChanneling() then
		msg.bottom('#cannot_remove_ability_channeling', playerID)
		return
	end

	-- 解决一些可能导致游戏崩溃的问题
	for _, modifier in pairs(gameBreakingModifiers) do
		if hero:HasModifier(modifier) then
			msg.bottom("#cannot_remove_this_ability_now", playerID)
			return
		end
	end
	-- 不允许通过移除其他技能来获取一个额外的技能格子
	for _, sub in pairs(subAbilitiesMap) do
		if abilityName == sub then
			msg.bottom("#cannot_remove_this_ability_now", playerID)
			return 
		end
	end

	local ability = hero:FindAbilityByName(abilityName)
	if ability == nil then return end
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local cooldownRemaining = ability:GetCooldownTimeRemaining()
	if abilityName == "pudge_meat_hook" then
		if cooldown - cooldownRemaining < 3 then
			msg.bottom("#cannot_remove_this_ability_now", playerID)
			return
		end
	end

	if table.contains({
			"empty_a1",
			"empty_a2",
			"empty_a3",
			"empty_a4",
			"empty_a5",
			"empty_a6",
			"empty_1",
			"empty_2",
			"empty_3",
			"empty_4",
			"empty_5",
			"empty_6",
			"empty_6_locked",
		}, abilityName) then
		msg.bottom('cannot_remove_this_ability', playerID)
		return
	end 

	local ability = hero:FindAbilityByName(abilityName)
	
	if not ability then
		msg.bottom("#error_ability_not_exist", playerID)
		return
	end

	abilityName_Replace = nil

	-- 是不是右侧被动技能
	local function isRightHandAbility(pszAbilityName)
		for _, name in pairs(GameRules.RandomDropAbilityScrolls) do
			
			if string.sub(name, 6) == pszAbilityName then
				return true
			end
		end
		return false
	end

	if isRightHandAbility(abilityName) then
		local empty_abilities = {
			"empty_1",
			"empty_2",
			"empty_3",
			"empty_4",
			"empty_5",
			-- "empty_6",
		}
		if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH and not hero:HasAbility("empty_6_locked") then
			table.insert(empty_abilities, 'empty_6')
		end
		for _, name in pairs(empty_abilities) do
			if not hero:FindAbilityByName(name) then
				abilityName_Replace = name
				break
			end
		end
	else
		abilityName_Replace = hero._vAbilityNameReplaceMap[abilityName]
	end

	if abilityName_Replace == nil 
		or abilityName == "shredder_return_chakram"
		then
		msg.bottom("#error_invalid_ability", playerID)
		return
	end

	hero:AddAbility(abilityName_Replace)
	hero:SwapAbilities(abilityName_Replace,abilityName,true,false)
	local ability = hero:FindAbilityByName(abilityName_Replace)
	if ability then
		ability:SetLevel(1)
	end
	
	-- 在移除前，如果是开关技能的，那么改为关闭
	local abilityRemoved = hero:FindAbilityByName(abilityName)
	if abilityRemoved:IsToggle() then
		if abilityRemoved:GetToggleState() == true then
			abilityRemoved:ToggleAbility()
		end
	end

	-- 移除技能的modifier
	local modifiers = hero:FindAllModifiers()
	for _, modifier in pairs(modifiers) do
		if modifier:GetAbility() == abilityRemoved then
			modifier:Destroy()
		end
	end

	-- 移除搭配的技能
	if pairedAbility[abilityName] then
		hero:RemoveAbility(pairedAbility[abilityName])
	end

	-- 如果有2技能的，移除2技能
	if subAbilitiesMap[abilityName] and hero:HasAbility(subAbilitiesMap[abilityName]) then
		local subAbilityName = subAbilitiesMap[abilityName]
		local add = hero:AddAbility("empty_a5")
		add:SetLevel(1)
		hero:SwapAbilities("empty_a5", subAbilityName, true, false);
		hero:RemoveAbility(subAbilityName)
	end
	-- 时间漫游
	if abilityName == "imba_faceless_void_time_walk" 
		and  hero:GetUnitName() == "npc_dota_hero_faceless_void" then
		if hero:HasAbility("faceless_void_time_lock") and not hero:HasAbility("empty_a4") then
			local add = hero:AddAbility("empty_a4")
			add:SetLevel(1)
			hero:SwapAbilities("empty_a5","faceless_void_time_lock", true, false)
			hero:RemoveAbility("faceless_void_time_lock")
		end
	end
-- 时间漫游
	if abilityName == "legion_commander_duel" 
		and  hero:GetUnitName() == "npc_dota_hero_legion_commander" then
		if hero:HasAbility("legion_commander_moment_of_courage") and not hero:HasAbility("empty_a4") then
			local add = hero:AddAbility("empty_a4")
			add:SetLevel(1)
			hero:SwapAbilities("empty_a4","legion_commander_moment_of_courage", true, false)
			hero:RemoveAbility("legion_commander_moment_of_courage")
			hero:RemoveAbility('modifier_npc_dota_hero_pangolier_1')
		end
	end
		--[[ 高射火炮
	if abilityName == "gyrocopter_flak_cannon" 
		and  hero:GetUnitName() == "npc_dota_hero_gyrocopter" then
		if not hero:HasAbility("empty_a5") then
			local add = hero:AddAbility("empty_a5")
			add:SetLevel(1)
			hero:SwapAbilities("empty_a5","gyrocopter_flak_cannon",  true, false)
			hero:RemoveAbility("gyrocopter_flak_cannon")
		end
	end]]--
	-- 如果是点击附属技能来移除的，那么移除主技能
	if table.reverse(pairedAbility)[abilityName] then
		local modifiers = hero:FindAllModifiers()
		for _, modifier in pairs(modifiers) do
			if modifier:GetAbility() == hero:FindAbilityByName(table.reverse(pairedAbility)[abilityName]) then
				modifier:Destroy()
			end
		end
		hero:RemoveAbility(table.reverse(pairedAbility)[abilityName])
	end

	-- 移除被动的modifier
	for name, abilityData in pairs(GameRules.Abilities_KV) do
		if name == abilityName and abilityData.Modifiers then
			for modifierName in pairs(abilityData.Modifiers) do
				if hero:HasModifier(modifierName) then
					hero:RemoveModifierByName(modifierName)
				end
			end
		end
	end
-- 瞄准的特殊修复 7.23
	if abilityName == "sniper_take_aim" 
		and hero:HasModifier('modifier_sniper_take_aim_fix') then
		
			hero:RemoveModifierByName('modifier_sniper_take_aim_fix')
		
	end
	-- 清理蜘蛛网
	if abilityName == 'broodmother_spin_web' then
		local ents = Entities:FindAllInSphere(Vector(0,0,0), 99999)
		for _, ent in pairs(ents) do
			if ent.GetName and ent:GetName() == "npc_dota_broodmother_web" and ent:GetOwner() == hero
				then
				UTIL_Remove(ent)
			end
		end
	end
	-- 清理邪能小黑
	if abilityName == "dazzle_bad_juju" 
		and  hero:GetUnitName() == "npc_dota_hero_drow_ranger" then
			if hero:HasModifier('modifier_hero_cooldown_percentage') then
				hero:RemoveModifierByName('modifier_hero_cooldown_percentage')
			end
	end

	hero:RemoveAbility(abilityName)
end

---------------------------------------------------------------------------------
-- 更新倒计时
---------------------------------------------------------------------------------
function GameMode:UpdateTimer()
    local t = GameRules.nCountDownTimer
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local daytime = false
    if GameRules.IsDaytime and GameRules:IsDaytime() then
    	daytime = true
    end
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
            daytime = daytime
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    if t <= 120 then
        CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    end
end

---------------------------------------------------------------------------------
-- 显示初始技能面板
---------------------------------------------------------------------------------
function GameMode:ShowInitialAbilityPanel(hero)

	local totalAbilities = 8
	local heroName = hero:GetUnitName()
	local heroData = GameRules.OriginalHeroes[heroName]
	local orignalHeroAbilities = {}
	local hero_abilities = {}

	for i = 1, 30 do
		local abilityName = heroData['Ability' .. i]
		
		if AbilityNameReplaceMap[abilityName] then
			abilityName = AbilityNameReplaceMap[abilityName]
		end

		if abilityName then
			if GameRules.OriginalAbilities[abilityName] 
				and GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ATTRIBUTES" 
				and not table.contains(GameRules.vBlackList, abilityName) and not table.contains(GameRules.vInnateAbilitiesPool, abilityName)
				then
				if GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ULTIMATE" then
					if not table.contains(GameRules.vNormalAbilitiesPool, abilityName) then
						table.insert(GameRules.vNormalAbilitiesPool, abilityName)
                        table.insert(hero_abilities, abilityName)
					end
				else
					if not table.contains(GameRules.vUltimateAbilitiesPool, abilityName) then
						table.insert(GameRules.vUltimateAbilitiesPool, abilityName)
                        table.insert(hero_abilities, abilityName)
					end
				end
			end
		end
	end
    -- 更新英雄池，如果已经存在了，那么就不重复添加
    local hasThisHeroInGame = false
    for _, d in pairs(GameRules.vHeroAbilityPoolForPlus) do
        if (d.hero == heroName) then
            hasThisHeroInGame = true
        end
    end
    if hasThisHeroInGame == false then
        table.insert(GameRules.vHeroAbilityPoolForPlus, {
            hero = heroName, abilities = hero_abilities
                })
    end
	self:UpdateAbilityPoolToClient()

	-- 选择初始技能

    local randomAbilities = table.random_some(GameRules.vNormalAbilitiesPool, 8)
    -- 如果包含有附加的特殊技能，那么有大概率替换掉
	for k, ability in pairs(randomAbilities) do
		if table.contains(GameRules.vCourierAbilities_Normal, ability) then
			-- if RollPercentage(60) then
				local randomAbility = table.random(GameRules.vNormalAbilitiesPool)
				while (table.contains(randomAbilities, randomAbility) 
					or table.contains(GameRules.vCourierAbilities_Normal, randomAbility))
					do
					randomAbility = table.random(GameRules.vNormalAbilitiesPool)
				end
				randomAbilities[k] = randomAbility
			-- end
		end
	end
	if heroName=="npc_dota_hero_gyrocopter" and not table.contains(randomAbilities, "gyrocopter_flak_cannon") then
		randomAbilities[1] ="gyrocopter_flak_cannon"
	end
	if heroName=="npc_dota_hero_ember_spirit" and not table.contains(randomAbilities, "ember_spirit_sleight_of_fist") then
		randomAbilities[1] ="ember_spirit_sleight_of_fist"
	end

	if heroName=="npc_dota_hero_clinkz" and not table.contains(randomAbilities, "clinkz_searing_arrows") then
		randomAbilities[1] ="clinkz_searing_arrows"
	end
	if heroName=="npc_dota_hero_tiny" and not table.contains(randomAbilities, "tiny_tree_grab") then
		randomAbilities[1] ="tiny_tree_grab"
	end
	if heroName=="npc_dota_hero_wisp" and not table.contains(randomAbilities, "wisp_tether") then
		randomAbilities[1] ="wisp_tether"
	end
	if heroName=="npc_dota_hero_antimage" and not table.contains(randomAbilities, "antimage_mana_break") then
		randomAbilities[1] ="antimage_mana_break"
	end
	if heroName=="npc_dota_hero_ursa" and not table.contains(randomAbilities, "ursa_fury_swipes") then
		randomAbilities[1] ="ursa_fury_swipes"
	end
	--IO出门送链接
    hero.vInitialAbility = hero.vInitialAbility or randomAbilities

	Timer(0, function()
        if not hero.__playerHaveSelectedAbility__ then

        	hero.vInitialAbilityPanelID = hero.vInitialAbilityPanelID or "spell_book_" .. DoUniqueString('')

        	GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
			local id = hero.vInitialAbilityPanelID
			GameRules.vSpellbookRecorder[id] = hero.vInitialAbility

            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(hero:GetPlayerID()),"show_ability_selector",{
                ID = hero.vInitialAbilityPanelID,
                Abilities = hero.vInitialAbility,
                Type = "normal"
            })
            return 1
        end
	end)
	
	-- 这个地方赠送免费的小跟班和EM大师的匕首
	-- hero:AddItemByName("item_em_dagger")
	if not hero.__bomCourier then
		hero.__bomCourier = true
		hero:AddItemByName("item_bom_courier")
		--hero:AddItemByName("item_spellbook_normal_courier")
		--hero:AddItemByName("item_spellbook_ultimate")	
		
		--local staff = hero:AddItemByName("item_force_staff")
		if (staff) then
			staff:SetPurchaseTime(-50) -- 不能全价出售
		end
		if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY and not hero:IsRangedAttacker() then
			hero:AddItemByName("item_boots")		
		end       
	end
end

---------------------------------------------------------------------------------
-- 重选英雄
---------------------------------------------------------------------------------
function GameMode:OnPlayerReselectHero(keys)
	local abilityName = keys.AbilityName
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)

	local hero = player:GetAssignedHero()
	if not hero then return end

	if hero.__bReselectedHero__ == true then return end
	hero.__bReselectedHero__ = true
	if player.__bReselectedHero__ == true then return end
	player.__bReselectedHero__ = true
	GameRules.__vPlayerIDRecorder__ = GameRules.__vPlayerIDRecorder__ or {}
	if GameRules.__vPlayerIDRecorder__[playerID] == true then return end
	GameRules.__vPlayerIDRecorder__[playerID] = true
	if hero._randomHero == nil then return end

	if not table.contains(hero._randomHero, keys.HeroName) then
		if not IsInToolsMode() then
			print("not hero that selected by server")
			return
		end
	end

	-- hero:AddNewModifier(hero, nil, 'modifier_waiting_for_precache', {})
    -- Notifications:Bottom(player, { text = 'hud_tooltip_waiting_for_precache', duration = 5, style = { color = "red", ["font-size"] = "30px", border = "0px" } , continue = continue})
    msg.bottom("#hud_tooltip_waiting_for_precache", playerID, nil, "General.PingWarning")

    local oldHero = hero

	PrecacheUnitByNameAsync(keys.HeroName,function() 
		Timer(function()

			if not PlayerResource:IsValidTeamPlayer(playerID) then return 0.03 end
			if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_CONNECTED then return 0.03 end

			local hero = PlayerResource:ReplaceHeroWith(playerID,keys.HeroName,hero:GetGold(),0)	

			Timer(0.1, function()
				GameRules.EconManager:OnPlayerEquip({
					PlayerID = playerID	
				})
			end)
			Timer(0.5, function()
				if GameRules:IsGamePaused() then return 0.03 end
				self:ShowInitialAbilityPanel(hero)
			end)

			-- 如果是虚空、巨魔、大鱼人，告知玩家这个模型不能出晕锤
		    if table.contains({
		    		"npc_dota_hero_slardar",
		    		"npc_dota_hero_faceless_void",
		    		"npc_dota_hero_troll_warlord",
		    	}, keys.HeroName) then
		    	-- Notifications:Bottom(player, { text = 'hud_tooltip_model_cannot_bash', duration = 5, style = { color = "red", ["font-size"] = "30px", border = "0px" } , continue = continue})
		    	msg.bottom("#hud_tooltip_model_cannot_bash", playerID, nil, "General.PingWarning")
		    end

		  --   Timer(1, function()
		  --   	oldHero:SetOrigin(Vector(99999,99999,0))
				-- oldHero:AddNewModifier(oldHero, nil, "modifier_rooted", {})
				-- oldHero:AddNewModifier(oldHero, nil, "modifier_disarmed", {})
				-- oldHero:AddNewModifier(oldHero, nil, "modifier_invulnerable", {})
		  --   end)
		end)
	end, playerID)
end

---------------------------------------------------------------------------------
-- 取消重选英雄（都不想要）
---------------------------------------------------------------------------------
function GameMode:OnPlayerCancelReselectHero(keys)
	local playerID = keys.PlayerID
	if playerID == nil then return end

	local player = PlayerResource:GetPlayer(playerID)
	if player.__bReselectedHero__ then return end
	player.__bReselectedHero__ = true
	local hero = player:GetAssignedHero()
	if hero == nil then return end
	    self:InitPlayerHero(hero)


	Timer(1, function()
		self:ShowInitialAbilityPanel(hero)
	end)

	-- 如果是虚空、巨魔、大鱼人，告知玩家这个模型不能出晕锤
    if table.contains({
    		"npc_dota_hero_slardar",
    		"npc_dota_hero_faceless_void",
    		"npc_dota_hero_troll_warlord",
    	}, hero:GetUnitName()) then
    	Notifications:Bottom(player, { text = 'hud_tooltip_model_cannot_bash', duration = 5, style = { color = "red", ["font-size"] = "30px", border = "0px" } , continue = continue})
    end
end

---------------------------------------------------------------------------------
-- 计算人头数投票结果
---------------------------------------------------------------------------------
function GameMode:CalculateVoteResult(keys)
	-- local voteOption = keys.VoteOption
	-- local options = self.voteOptions
	-- local killsToWin = options['option' .. voteOption]
	-- self.TEAM_KILLS_TO_WIN = killsToWin
 	--    CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

 	local maxOption = 2 -- 默认选择第二个选项
	local maxVote = 0
	GameRules.VoteState = GameRules.VoteState or {{}, {}, {}}
	for k, votes in pairs(GameRules.VoteState) do
		local numVotes = table.count(votes)
		if numVotes > maxVote then
			maxVote = numVotes
			maxOption = k
		end
	end

	local killsToWin = self.voteOptions['option' .. maxOption]
	self.TEAM_KILLS_TO_WIN = killsToWin
    CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );
end

---------------------------------------------------------------------------------
-- 人头数投票
---------------------------------------------------------------------------------
function GameMode:OnPlayerVote(keys)
	local option = keys.option
	local playerId = keys.PlayerID
	GameRules.VoteState = GameRules.VoteState or {{},{},{}}
	
	for k, votes in pairs(GameRules.VoteState) do
		if k ~= option then
			-- 从其他表中移除vote (必须倒序遍历使用 table.remove，防止数组出现空洞打断前端UI)
			for i = #votes, 1, -1 do
				if votes[i] == playerId then
					table.remove(votes, i)
				end
			end
		else
			if not table.contains(votes, playerId) then
				table.insert(votes, playerId)
			end
		end
	end

	CustomNetTables:SetTableValue('game_state', 'vote_state', GameRules.VoteState)
	self:CalculateVoteResult()
end

---------------------------------------------------------------------------------
-- 同意洗牌
---------------------------------------------------------------------------------
function GameMode:OnPlayerAgreeToShuffle(keys)
	local playerId = keys.PlayerID
	GameRules.vAgreeToShufflePlayers = GameRules.vAgreeToShufflePlayers or {}
	if not table.contains(GameRules.vAgreeToShufflePlayers, playerId) then
		table.insert(GameRules.vAgreeToShufflePlayers, playerId)
	end

	CustomNetTables:SetTableValue("game_state", "agree_to_shuffle_players", GameRules.vAgreeToShufflePlayers)
end

---------------------------------------------------------------------------------
-- 同意开启狂野模式
---------------------------------------------------------------------------------
function GameMode:OnPlayerVoteForFreeMode(keys)
	local playerId = keys.PlayerID
	GameRules.vFreeModePlayers = GameRules.vFreeModePlayers or {}
	GameRules.vFreeModePlayers[playerId] = not GameRules.vFreeModePlayers[playerId]

	local t = {}
	for playerId, agree in pairs(GameRules.vFreeModePlayers) do
		if agree then
			table.insert(t, playerId)
		end
	end

	if table.count(t) >= 6 or 
		(IsInToolsMode() and table.count(t) >= 1)
		then
		GameRules.bFreeModeActivated = true
		print("free mode will be activated!")
	else
		print("free mode will NOT be activated!")
		GameRules.bFreeModeActivated = false
	end

	CustomNetTables:SetTableValue("game_state", "agree_to_free_mode_players", t)
end


---------------------------------------------------------------------------------
-- 请求星星数据
---------------------------------------------------------------------------------
function GameMode:OnClientAskForStar(keys)
	local playerId = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerId)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end
	if hero.UpdateStarToUI then
		hero:UpdateStarToUI()
	end

	if not hero.__bInited then
		self:InitPlayerHero(hero)
	end
end

---------------------------------------------------------------------------------
-- 重新随机英雄
---------------------------------------------------------------------------------
function GameMode:OnPlayerReRandomHero(keys)
	local playerId = keys.PlayerID
	GameRules.vReRandomState = GameRules.vReRandomState or {}
	if GameRules.vReRandomState[playerId] then return end
	GameRules.vReRandomState[playerId] = true
	local player = PlayerResource:GetPlayer(playerId)
	if not player then return end
	if player._bReRandomHero then return end
	player._bReRandomHero = true

	self:ShowRandomHeroSelection(playerId, 3, true)
end

---------------------------------------------------------------------------------
-- 显示随机的英雄选择
---------------------------------------------------------------------------------
function GameMode:ShowRandomHeroSelection(i, randomCount, reRandom)
	if randomCount == nil then
		randomCount = 3
	end
    local player = PlayerResource:GetPlayer(i)
    local hero = player:GetAssignedHero()

	local randomPool = table.shallowcopy(GameRules.ValidHeroes)


	local randomHero = table.random_some(randomPool, randomCount)

	while
		table.contains(randomHero, PlayerResource:GetSelectedHeroName(i)) 
        or ( table.contains(randomHero, "npc_dota_hero_drow_ranger")  and RollPercentage(60) )
        or ( table.contains(randomHero, "npc_dota_hero_gyrocopter") and RollPercentage(40) )
		or ( table.contains(randomHero, "npc_dota_hero_tidehunter") and RollPercentage(50) )
		or ( table.contains(randomHero, "npc_dota_hero_dark_seer") and RollPercentage(40) )
		or ( table.contains(randomHero, "npc_dota_hero_snapfire") and RollPercentage(30) )
		or ( table.contains(randomHero, "npc_dota_hero_sniper") and RollPercentage(50) ) 
		or ( table.contains(randomHero, "npc_dota_hero_night_stalker") and RollPercentage(80) )
		or ( table.contains(randomHero, "npc_dota_hero_juggernaut") and RollPercentage(70) )
		or ( table.contains(randomHero, "npc_dota_hero_techies") and RollPercentage(70) )
		or ( table.contains(randomHero, "npc_dota_hero_jakiro") and RollPercentage(90) )
		or ( table.contains(randomHero, "npc_dota_hero_muerta") and RollPercentage(50) ) 
		or ( table.contains(randomHero, "npc_dota_hero_razor") and RollPercentage(50) ) 
		or (
			reRandom and hero._randomHero and (
				table.contains(randomHero, hero._randomHero[1])
				or table.contains(randomHero, hero._randomHero[2])
				or table.contains(randomHero, hero._randomHero[3])
			)
		)
        do
        randomHero = table.random_some(randomPool, randomCount)
    end

    hero._randomHero = randomHero

    Timer(0, function()
        if hero.__bReselectedHero__ or player.__bReselectedHero__ then
            CustomNetTables:SetTableValue('player_data', 'player_random_hero_selection_' .. i, {selected=true})
        else
            CustomGameEventManager:Send_ServerToPlayer(player,"player_random_hero_selection",hero._randomHero)
            CustomNetTables:SetTableValue('player_data', 'player_random_hero_selection_' .. i, hero._randomHero)
            return 1
        end
	end)
	
	randomPool = nil -- 释放内存
end

function GameMode:OnPlayerTaunt(keys)
	local playerId = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerId)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end


	local now  = GameRules:GetGameTime()
	if hero.flLastTauntTime == nil then
		hero.flLastTauntTime = now - 10
	end

	if now - hero.flLastTauntTime > 1 then
		hero.flLastTauntTime = now
		if hero.funcTaunt ~= nil then
			hero.funcTaunt()
		end
	else
		msg.bottom("NOT_READY", playerID)
	end
end