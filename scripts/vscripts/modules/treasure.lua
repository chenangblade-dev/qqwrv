if Treasure == nil then Treasure = class({}) end

local INITIAL_TRASURE_SPAWN_TIME = 600
local TREASURE_SPAWN_INTERVAL = 180

local tier_def = {
	[10] = {
		[1] = {25, 40, 28, 5, 2},
		[2] = {20, 20, 40, 18, 2},
		[3] = {10, 20, 30, 25, 5},
		[4] = {10, 20, 30, 25, 5},
		[5] = {0, 10, 34, 34, 7},
		[6] = {0, 10, 34, 34, 7},
		[7] = {0, 5, 25, 40, 10},
		[8] = {0, 5, 25, 40, 10},
		[9] = {0, 0, 28, 40, 12},
		[10] = {0, 0, 28, 40, 12},
	},
	[6] = {
		[1] = {25, 40, 28, 5, 2},
		[2] = {20, 20, 40, 16, 4},
		[3] = {0, 10, 34, 34, 7},
		[4] = {0, 10, 34, 34, 7},
		[5] = {0, 5, 25, 40, 10},
		[6] = {0, 0, 28, 40, 12},
	},
	[4] = {
		[1] = {25, 40, 28, 5, 2},
		[2] = {0, 10, 34, 34, 7},
		[3] = {0, 10, 34, 34, 7},
		[4] = {0, 0, 28, 40, 12},
	},
	[3] = {
		[1] = {25, 40, 28, 5, 2},
		[2] = {0, 10, 34, 34, 7},
		[3] = {0, 0, 28, 40, 12},
	},
	[2] = {
		[1] = {25, 40, 28, 5, 2},
		[2] = {0, 0, 28, 40, 12},
	},
}

local itemList = {
	[1] = 
	{ 
		"item_keen_optic"	,
		"item_broom_handle"	,
		"item_faded_broach"	,
		"item_arcane_ring"	,
		"item_chipped_vest"	,
		"item_mysterious_hat",
		"item_ogre_seal_totem",
		"item_poshovel",
		"item_pogo_stick",
		"item_unstable_wand",
	},
	[2] =
	{
		"item_ring_of_aquila",
		"item_nether_shawl",
		"item_dragon_scale",
		"item_vambrace",
		"item_grove_bow",
		"item_philosophers_stone",
		"item_essence_ring",
		"item_quicksilver_amulet",
		"item_bogduggs_lucky_femur",
		"item_paintball",
		"item_quicksilver_amulet",
	},
	[3] = 
	{
		"item_spider_legs",
		"item_paladin_sword",
		"item_orb_of_destruction",
		"item_titan_sliver",
		"item_mind_breaker",
		"item_enchanted_quiver",
		"item_elven_tunic",
		"item_cloak_of_flames",
		"item_ceremonial_robe",
		"item_psychic_headband",
		"item_dimensional_doorway",
		"item_psychic_headband",
	},
	[4] =
	{	
		"item_timeless_relic",
		"item_havoc_hammer",
		"item_flicker",
		"item_ninja_gear",
		"item_illusionsts_cape",
		"item_the_leveller",
		"item_minotaur_horn",
		"item_spy_gadget",
		"item_trickster_cloak",
		"item_stormcrafter",
		"item_penta_edged_sword",
		"item_rhyziks_eye",
		"item_havoc_hammer",
		"item_panic_button",
		"item_heavy_blade",
		"item_ascetic_cap",
	},
	[5] =
	{
		"item_force_boots",
		"item_desolator_2",
		"item_seer_stone",
		"item_mirror_shield",
		-- "item_apex",
		"item_woodland_striders",
		"item_ballista",
		"item_demonicon",
		"item_fallen_sky",
		"item_pirate_hat",
		"item_ex_machina",
		"item_giants_ring",
		"item_recipe_trident" ,
		"item_dredged_trident",
		"item_force_field",
		"item_vengeances_shadow",
	},
}

function Treasure:OnPlayerPickupItem( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	local hero = owner:GetClassname()
	local ownerTeam = owner:GetTeamNumber()

	local rank = GameRules.GameMode:GetCurrentRank(owner)
	local teamCount = GameRules.GameMode.nTeamCount
	local chance = RandomInt(1, 100)
	local chance_table = tier_def[teamCount][rank]
	local total = 0
	local tier = 1
	for i, v in ipairs(chance_table) do
		if total <= chance and chance < total + v then
			tier = i
			break
		end
		total = total + v
	end

	local spawnedItem = table.random(itemList[tier])
	if RollPercentage(1) and RollPercentage(15) then
		spawnedItem = 'item_apex' -- apex只有极低概率在空投出现
	end
	owner:AddItemByName( spawnedItem )
	EmitGlobalSound("powerup_04")
	local overthrow_item_drop =
	{
		hero_id = hero,
		dropped_item = spawnedItem
	}
	CustomGameEventManager:Send_ServerToAllClients( "overthrow_item_drop", overthrow_item_drop )
end

function Treasure:WarnItem()
	local pos = GameRules.GameMode:GetRandomValidPosition()
	self.itemSpawnLocation = pos
	local spawnLocation = self.itemSpawnLocation
	CustomGameEventManager:Send_ServerToAllClients( "item_will_spawn", {} )
	EmitGlobalSound( "powerup_03" )

	self.fakeItemSpawnLocation = {}

	local fakePosition = GameRules.GameMode:GetRandomValidPosition()

	local maxTries = 10
	while (fakePosition - pos):Length2D() < 4000 and maxTries > 0 do
		fakePosition = GameRules.GameMode:GetRandomValidPosition()
		maxTries = maxTries - 1
	end
	table.insert(self.fakeItemSpawnLocation, fakePosition)

	CustomGameEventManager:Send_ServerToAllClients( "item_will_spawn", table.join(self.fakeItemSpawnLocation, {self.itemSpawnLocation}) )
end

function Treasure:_SpawnItem(targetLocation, real)
	CustomGameEventManager:Send_ServerToAllClients( "item_has_spawned", {} )
	EmitGlobalSound( "powerup_05" )

	local minx, miny, maxx, maxy = GetWorldMinX(), GetWorldMinY(), GetWorldMaxX(), GetWorldMaxY()
	local spawnPos = Vector(minx, miny, 0)
	if (targetLocation.x > 0 and targetLocation.y > 0) then
	elseif targetLocation.x > 0 and targetLocation.y < 0 then
		spawnPos = Vector(minx, maxy, 0)
	elseif targetLocation.x < 0 and targetLocation.y > 0 then
		spawnPos = Vector(maxx, miny, 0)
	elseif targetLocation.x < 0 and targetLocation.y < 0 then
		spawnPos = Vector(maxx, maxy, 0)
	end

	local treasureCourier = CreateUnitByName( "npc_dota_treasure_courier" , spawnPos, true, nil, nil, DOTA_TEAM_NEUTRALS )

	if real then treasureCourier.real = true end

	local treasureAbility = treasureCourier:FindAbilityByName( "dota_ability_treasure_courier" )
	treasureAbility:SetLevel( 1 )
    local goalEntity = SpawnEntityFromTableSynchronous("info_target",{
        origin = targetLocation,
    })
    local teams = {2,3,6,7,8,9,10,11,12,13}
    treasureCourier.fowViewers = {}
	Timer(55, function()
		for _, team in pairs(teams) do
    		table.insert(treasureCourier.fowViewers,CreateUnitByName("npc_vision_revealer",targetLocation,false,nil,nil,team))
    	end
	end)
    --[[for _, team in pairs(teams) do
    	local unit = CreateUnitByName("npc_vision_revealer",spawnPos,false,nil,nil,team)
    	Timer(0.03, function()
    		if IsValidAlive(treasureCourier) then
    			unit:SetOrigin(treasureCourier:GetOrigin())
    			return 0.03
    		else
    			UTIL_Remove( unit )
    			return nil
    		end
    	end)
    end]]--
    treasureCourier:SetInitialGoalEntity(goalEntity)

    --local particleTreasure = ParticleManager:CreateParticle( "particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN, treasureCourier )
	--ParticleManager:SetParticleControlEnt( particleTreasure, PATTACH_ABSORIGIN, treasureCourier, PATTACH_ABSORIGIN, "attach_origin", treasureCourier:GetAbsOrigin(), true )
	--treasureCourier:Attribute_SetIntValue( "particleID", particleTreasure )

	Timer(function()
		local to = treasureCourier:GetOrigin()
		local o = goalEntity:GetOrigin()
		if (to - o):Length2D() < 5000 then
			self:ShowHintAtLocation(to)
			return nil
		else
			return 1
		end
	end)
end

function Treasure:ShowHintAtLocation(pos)
	for i = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:GetPlayer(i) and PlayerResource:GetPlayer(i):GetAssignedHero() then
			ent = PlayerResource:GetPlayer(i):GetAssignedHero()
		end
	end
	for _, team in pairs(GameRules.vTeamsInGame) do
		MinimapEvent(team, ent, pos.x, pos.y, DOTA_MINIMAP_EVENT_HINT_LOCATION , 3)
	end
end

function Treasure:ForceSpawnItem()
	self:WarnItem()
	self:SpawnItem()
end

function Treasure:TreasureDrop( treasureCourier )
	--Create the death effect for the courier
	local spawnPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
	spawnPoint.z = 400
	local fxPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
	fxPoint.z = 400
	local deathEffects = ParticleManager:CreateParticle( "particles/treasure_courier_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( deathEffects, 0, fxPoint )
	ParticleManager:SetParticleControlOrientation( deathEffects, 0, treasureCourier:GetForwardVector(), treasureCourier:GetRightVector(), treasureCourier:GetUpVector() )
	EmitGlobalSound( "lockjaw_Courier.Impact" )
	EmitGlobalSound( "lockjaw_Courier.gold_big" )

	local fowViewers = treasureCourier.fowViewers
	Timer(10, function()
		for _, v in pairs(fowViewers) do
			UTIL_Remove( v )
		end
	end)

	local real = treasureCourier.real
	local rightVector = treasureCourier:GetRightVector()
	UTIL_Remove( treasureCourier )

	--Spawn the treasure chest at the selected item spawn location
	local newItem = CreateItem( "item_treasure_chest", nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	drop:SetForwardVector(rightVector)
	newItem:LaunchLootInitialHeight( false, 0, 50, 0.25, spawnPoint )

	-- destroy trees
	GridNav:DestroyTreesAroundPoint(spawnPoint,500,true)

	if real then
		-- 在附近掉1-2张普通技能卷轴和有概率的1张终极技能卷轴
		local normalAbilityCount = 1
		if RollPercentage(40) then normalAbilityCount = 2 end
		for i = 1, normalAbilityCount do
            utilsBonus.DropLootItem("item_spellbook_normal_courier", spawnPoint, 400, 500)
		end
		if RollPercentage(30) then
            utilsBonus.DropLootItem("item_spellbook_ultimate_courier", spawnPoint, 400, 500)
		end
	end
end

function Treasure:SpawnItem()
	self:_SpawnItem(self.itemSpawnLocation, true)
	for _, loc in pairs(self.fakeItemSpawnLocation) do
		self:_SpawnItem(loc, false)
	end
end

function Treasure:ThinkSpecialItemDrop()
	local now = GameRules:GetDOTATime(false,false)
	if self.flLastItemDropTime == nil then
		self.flLastItemDropTime = now + INITIAL_TRASURE_SPAWN_TIME - TREASURE_SPAWN_INTERVAL
	end
	if now - self.flLastItemDropTime > TREASURE_SPAWN_INTERVAL then
		self:WarnItem()
		self.flLastItemDropTime = now
		Timer(5, function()
			self:SpawnItem()
		end)
	end
end

function Treasure:constructor()
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(Treasure, "OnGameRulesStateChange"), self)
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( Treasure, "OnNpcGoalReached" ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( Treasure, "OnItemPickUp" ), self )
end

function Treasure:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Timer(1, function()
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS 
				and GameRules.nCountDownTimer > 200
				then
				self:ThinkSpecialItemDrop()
			end
			return 1
		end)
	end
end

function Treasure:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		local pos = npc:GetOrigin()
		self:ShowHintAtLocation(pos)		
		Timer(RandomFloat(3,6), function()
			self:TreasureDrop( npc )
		end)
	end
end

function Treasure:OnItemPickUp( event )
	if event.HeroEntityIndex and event.ItemEntityIndex then
		local item = EntIndexToHScript( event.ItemEntityIndex )
		local owner = EntIndexToHScript( event.HeroEntityIndex )
		if event.itemname == "item_treasure_chest" then
			self:OnPlayerPickupItem( event )
			UTIL_Remove( item )
		end
	end
end


if GameRules.Treasure == nil then GameRules.Treasure = Treasure() end