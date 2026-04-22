print('loading diretide module')

if DireTide == nil then DireTide = class({}) end

function DireTide:constructor()
	ListenToGameEvent('entity_killed', Dynamic_Wrap(DireTide, 'OnEntityKilled'), self)
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( DireTide, 'OnGameRulesStateChange' ), self )

    if GameRules:GetGameModeEntity().SetCustomTerrainWeatherEffect ~= nil then
        GameRules:GetGameModeEntity():SetCustomTerrainWeatherEffect('particles/rain_fx/econ_weather_pestilence.vpcf')
    end
end

function DireTide:OnEntityKilled(keys)
	local hKilled = EntIndexToHScript(keys.entindex_killed)
    local hAttacker = EntIndexToHScript(keys.entindex_attacker)
    -- 如果是野怪
    if hKilled:IsCreature() or hKilled:IsNeutralUnitType() then
    	if RollPercentage(2) then
    		utilsBonus.DropLootItem('item_diretide_candy', hKilled:GetOrigin(), 10)
    	end
    end


    local hero = hKilled
    if hero:IsRealHero() and hAttacker:IsControllableByAnyPlayer() then
        for i = 0, 15 do
            local candies = hero:GetItemInSlot(i)
            if candies then
                if candies:GetAbilityName() == "item_diretide_candy" then
                    local stacks = candies:GetCurrentCharges()
                    for i = 1, stacks do
                        utilsBonus.DropLootItem('item_diretide_candy', hero:GetOrigin(), 150)
                    end

                    candies:RemoveSelf()
                end
            end
        end
    end
end

function DireTide:OnGameRulesStateChange()
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- 在地图中间创建糖果篮子

        local bucket_spawn_delay = 600
        if IsInToolsMode() then
            bucket_spawn_delay = 10
        end

        local gameEvent = {
            player_id = 0,
            int_value = bucket_spawn_delay,
            teamnumber = -1,
            message = "#GameMessage_BucketSpawn",
        }
        FireGameEvent( "dota_combat_event_message", gameEvent )


        local function createBucketAtPosition(position)
            local pid = ParticleManager:CreateParticle('particles/neutral_fx/roshan_timer_b.vpcf', PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(pid, 0, position)
            ParticleManager:SetParticleControl(pid, 1, position)
            ParticleManager:SetParticleControl(pid, 9, Vector(150, 1, 1))
            ParticleManager:SetParticleControl(pid, 10, Vector(0, 0, 60))
            ParticleManager:SetParticleControl(pid, 11, Vector(bucket_spawn_delay, 0, 6))
            ParticleManager:SetParticleControl(pid, 12, Vector(bucket_spawn_delay, 0, 0))
            ParticleManager:SetParticleControl(pid, 13, Vector(bucket_spawn_delay, 0, 0))

            Timer(bucket_spawn_delay, function()
                local bucket = CreateUnitByName('npc_diretide_bucket', position, true, nil, nil, DOTA_TEAM_NEUTRALS)
                ParticleManager:DestroyParticle(pid, true)
                ParticleManager:ReleaseParticleIndex(pid)
                bucket:AddNewModifier(bucket, nil, 'modifier_candy_bucket', {})
                bucket:SetForwardVector(Vector(0, -1, 0))
            end)

            for _, team in pairs({2,3,6,7,8,9,10,11,12,13}) do
                AddFOWViewer(team, position, 800, 6000, true)
            end
        end

        createBucketAtPosition(Vector(-1744, -116, 300))
        createBucketAtPosition(Vector(-200, 430, 300))
    end
end

GameRules.DireTide = DireTide()
