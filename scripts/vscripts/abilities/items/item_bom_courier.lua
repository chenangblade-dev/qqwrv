LinkLuaModifier("modifier_bom_courier", "abilities/items/modifiers/modifier_bom_courier.lua", LUA_MODIFIER_MOTION_NONE)



function SpawnCourier(keys)
	if GameRules.nCountDownTimer < 360 then
		return
	end

	local caster = keys.caster
	local playerId = caster:GetPlayerID()

	local function RandomCourierSkin(playerId, courier)
		
			-- plus会员可以有几个免费的模型
			local randomPool = {
				"models/items/courier/mole_messenger/mole_messenger_lvl2.vmdl",
			
			}
			local model = table.random(randomPool)
			--[[local steamid = PlayerResource:GetSteamAccountID(playerId)
			if steamid == 195026381 then
				table.insert(randomPool, 
				table.insert(randomPool, 'models/items/courier/ig_dragon/ig_dragon_flying.vmdl')
				table.insert(randomPool, 'models/courier/baby_rosh/babyroshan_flying.vmdl')
			end
			if steamid == 135669347 or steamid == 1015466411 then
				randomPool = {
				'models/courier/baby_rosh/babyroshan_flying.vmdl',
				'models/courier/baby_winter_wyvern/baby_winter_wyvern_flying.vmdl',
				"models/courier/baby_rosh/babyroshan_winter18.vmdl",
				'models/courier/baby_rosh/babyroshan_ti10_flying.vmdl',
				}
			end
			if steamid == 144151309 or steamid == 146222002 or steamid == 144440710 or steamid == 165264514 then
				randomPool = {
				'models/courier/baby_rosh/babyroshan_flying.vmdl',
				'models/courier/baby_rosh/babyroshan_ti10_flying.vmdl',
				'models/courier/baby_winter_wyvern/baby_winter_wyvern_flying.vmdl',
				}
			end
			if steamid == 344877421 then
				model = "models/courier/baby_rosh/babyroshan_ti10_flying.vmdl"
			end

			if model == "models/courier/baby_rosh/babyroshan_ti10_flying.vmdl" then
				if not courier.___vvvPct then
					local particleName = "particles/econ/courier/courier_babyroshan_ti10/courier_babyroshan_ti10_ambient_flying.vpcf"
					local pid = ParticleManager:CreateParticle(particleName,PATTACH_ABSORIGIN_FOLLOW,courier)
					ParticleManager:SetParticleControlEnt(pid,0,courier,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",courier:GetAbsOrigin(),true)
					courier.___vvvPct = pid
				end
				courier:SetModelScale(0.7)
			elseif model == "models/courier/baby_rosh/babyroshan_flying.vmdl" then
				if not courier.___vvvPct then
					local particleName = "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient_flying.vpcf"
					local pid = ParticleManager:CreateParticle(particleName,PATTACH_ABSORIGIN_FOLLOW,courier)
					ParticleManager:SetParticleControlEnt(pid,0,courier,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",courier:GetAbsOrigin(),true)
					courier.___vvvPct = pid
				end
				courier:SetModelScale(0.8)
			elseif model == "models/courier/baby_rosh/babyroshan_winter18.vmdl" then
				if not courier.___vvvPct then
					local particleName = "particles/econ/courier/courier_babyroshan_winter18/courier_babyroshan_winter18_ambient.vpcf"
					local pid = ParticleManager:CreateParticle(particleName,PATTACH_ABSORIGIN_FOLLOW,courier)
					ParticleManager:SetParticleControlEnt(pid,0,courier,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",courier:GetAbsOrigin(),true)
					courier.___vvvPct = pid
				end
				courier:SetModelScale(0.8)
			else
				if courier.__vCourierPCF then
					ParticleManager:DestroyParticle(courier.__vCourierPCF, true)
					courier.__vCourierPCF = nil
				end
				courier:SetModelScale(0.8)
			end]]--

			courier:SetModel(model)
			courier:SetOriginalModel(model)

		
	end

	if caster.__Courier then
		RandomCourierSkin(playerId, caster.__Courier)
		UTIL_Remove(keys.ability)
		return
	end

	local spawnPos = caster:GetOrigin() + caster:GetForwardVector() * 128
	local unit = CreateUnitByName("npc_dota_bom_courier", spawnPos, true, caster, caster:GetPlayerOwner(), caster:GetTeamNumber())
	caster.__Courier = unit
	unit.__Owner = caster
	unit:AddNewModifier(caster, nil, "modifier_bom_courier", {})
	UTIL_Remove(keys.ability)

	GameRules.vAllCouriers = GameRules.vAllCouriers or {}
	table.insert(GameRules.vAllCouriers, unit)

	RandomCourierSkin(playerId, unit) -- plus会员的免费皮肤
end