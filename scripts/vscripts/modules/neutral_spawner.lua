-- 这个刷怪系统作为开始的辅助方法，帮助玩家度过初始阶段
local TOTAL_CREATURES_SPAWN = 200
local MAP_MAX_BASIC_CREATURES = 150
local EACH_SPAWN_BATCH_SPAWN_COUNT = 10
local creatureCount = 20


local ALL_CREATURES = {
	"npc_dota_creature_basic_zombie_exploding",
	"npc_dota_creature_zombie",
	"npc_dota_creature_zombie_crawler",
	"npc_dota_creature_bear",
	"npc_dota_creature_bear_large",
	"npc_dota_creature_tormented_soul",
	"npc_dota_creature_spider",
	"npc_dota_creature_red_bear",
}

GameRules.vXavierCreatedCreatures = ALL_CREATURES

local DEATH_SOUND = {
	npc_dota_creature_zombie = "Zombie.Death",
	npc_dota_creature_bear = "Bear.Death",
	npc_dota_creature_bear_large = "BearLarge.Death",
}

if NeutralSpawner == nil then NeutralSpawner = class({}) end

function NeutralSpawner:constructor()
	--if IsInToolsMode() then return end
	self:PrepareSpawner()
end

function NeutralSpawner:PrepareSpawner()
	for k, v in pairs(ALL_CREATURES) do
		PrecacheUnitByNameAsync(v, function() end)
	end

	self.vCreatures = {}

	ListenToGameEvent("entity_killed", Dynamic_Wrap(NeutralSpawner, "OnEntityKilled"), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(NeutralSpawner, "OnGameRulesStateChange"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(NeutralSpawner, "OnNpcSpawned"), self)

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:SetupCreatureSpawners()
		self:Begin()
	end
end

function NeutralSpawner:OnNpcSpawned(keys)
	local unit = EntIndexToHScript(keys.entindex)
	if unit and unit.GetUnitName and table.contains(ALL_CREATURES, unit:GetUnitName()) then
		unit:SetForwardVector(RandomVector(1))
	end	
end

function NeutralSpawner:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	-- if IsInToolsMode() then return end

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:SetupCreatureSpawners()
		self:Begin()
		for i = 1, 20 do
			self:SpawnACreature()
		end
	end
end

function NeutralSpawner:Begin()
	Timer(function()
		-- 怪物死亡后重新刷怪的判断，每次根据场上有多少怪物来计算是否需要刷怪
		local spawnLimit = 150
		if GameRules.nCountDownTimer <= GameRules.FightingArea.vTimeMarks[1] + 50 then
			spawnLimit = 30
		end
		if GameRules.nCountDownTimer <= GameRules.FightingArea.vTimeMarks[2] + 1 then
			spawnLimit = 20
		end
		if GameRules.nCountDownTimer <= GameRules.FightingArea.vTimeMarks[3] + 1 then
			spawnLimit = 8
		end

		if creatureCount < spawnLimit  then
			for i = 1, 10 do
				self:SpawnACreature()
			end
			creatureCount= creatureCount + 10
		end

		return 2
	end)
end
function NeutralSpawner:SpawnACreature()
	local unit = table.random(ALL_CREATURES)
	local randomPos = GameRules.GameMode:GetRandomValidPosition()
	CreateUnitByNameAsync(unit, randomPos, true, nil, nil, DOTA_TEAM_NEUTRALS, nil)
end

function NeutralSpawner:OnEntityKilled(keys)
	if keys.entindex_killed == nil then return end
	local hDeadUnit = EntIndexToHScript( keys.entindex_killed )

	if hDeadUnit:IsCreature() then		
		local sound = DEATH_SOUND[hDeadUnit:GetUnitName()]
		if sound then
			EmitSoundOn(sound, hDeadUnit)
		else
			EmitSoundOn("Zombie.Death", hDeadUnit)
		end
		creatureCount= creatureCount - 1
	end
end

function NeutralSpawner:CreateNeutralSpawnerAtPos(pos)
	local volume_name = DoUniqueString("volume")
    local volume_perfab = Entities:FindByName(nil,"neutral_volume")
  local volume = SpawnEntityFromTableSynchronous("trigger_dota",{
        targetname = volume_name,
        origin = pos,
        model = volume_perfab:GetModelName(),
		every_unit = true
    })

    local spawner = SpawnEntityFromTableSynchronous("npc_dota_neutral_spawner", {
        targetname = "spawner_" .. volume_name,
        origin = pos,
        NeutralType = RandomInt(0, 3),
        PullType = 1,
		AggroType = 0,
        ForcedSubType = -1,
		MaxUpgradeCount = 0,
		MinSpawnType = 1,
		MaxSpawnType = 6,
		BatchLimit = 0,
        VolumeName = volume_name,
    })

    return spawner, volume
end

----------------------------------------------------------------------------------------------------
-- 在固定的位置生成刷怪器
----------------------------------------------------------------------------------------------------
function NeutralSpawner:SetupCreatureSpawners()
    local ents = Entities:FindAllByClassname("info_target") -- 在所有的creature_camp_mark位置生成一个野怪刷怪点
    for _, pos_ent in pairs(ents) do
        if string.find(pos_ent:GetName(), "creature_camp_mark") then
            local spawner = self:CreateNeutralSpawnerAtPos(pos_ent:GetAbsOrigin())
            spawner:SetForwardVector(pos_ent:GetForwardVector())
        end
    end
end

function NeutralSpawner:OnFightingAreaRescale(center, radius)
	local neutralSpawners = Entities:FindAllByClassname("npc_dota_neutral_spawner")
	for _, spawner in pairs(neutralSpawners) do
		if ((spawner:GetOrigin() - center):Length2D() > radius) then
			UTIL_Remove(spawner)
		end
	end
end
