juggernaut_blade_dance_lua=class({})
LinkLuaModifier("modifier_juggernaut_blade_dance_lua_pa", "heroes/hero_juggernaut/juggernaut_blade_dance_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_juggernaut_blade_dance_lua_move", "heroes/hero_juggernaut/juggernaut_blade_dance_lua.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

function juggernaut_blade_dance_lua:IsHiddenWhenStolen() 
    return false 
end

function juggernaut_blade_dance_lua:IsStealable() 
    return false 
end


function juggernaut_blade_dance_lua:GetIntrinsicModifierName() 
    return "modifier_juggernaut_blade_dance_lua_pa" 
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


function juggernaut_blade_dance_lua:OnSpellStart()

end

function juggernaut_blade_dance_lua:OnProjectileHit_ExtraData(target, location, kv)
    local caster=self:GetCaster()
  --  TG_IS_ProjectilesValue1(caster,function()
   --     target=nil
 --   end)
	if target==nil then
		return
	end
	if target:IsAlive() then
	    caster:PerformAttack(target, false, true, true, false, true, false, true)  
    end 
end

modifier_juggernaut_blade_dance_lua_pa=class({})

function modifier_juggernaut_blade_dance_lua_pa:IsHidden() 			
    return true 
end

function modifier_juggernaut_blade_dance_lua_pa:IsPurgable() 			
    return false 
end

function modifier_juggernaut_blade_dance_lua_pa:IsPurgeException() 	
    return false 
end

function modifier_juggernaut_blade_dance_lua_pa:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
    }
end

function modifier_juggernaut_blade_dance_lua_pa:AllowIllusionDuplicate() 
    return false 
end

function modifier_juggernaut_blade_dance_lua_pa:OnCreated() 
    self.crit = {} 
end

function modifier_juggernaut_blade_dance_lua_pa:GetModifierPreAttack_CriticalStrike(tg)
    if not IsServer() or self:GetParent():IsIllusion()  then
		return
	end 
    if tg.attacker == self:GetParent() and not tg.target:IsBuilding() and not self:GetParent():PassivesDisabled() then
        local ch=self:GetParent():HasModifier("modifier_omni_slash_buff") and 50 or self:GetAbility():GetSpecialValueFor("ch")
        if RollPseudoRandomPercentage(ch,0,self:GetParent()) then
			self:GetParent():EmitSound("Hero_Juggernaut.BladeDance.Arcana")
            self.crit[tg.record] = true
            return self:GetAbility():GetSpecialValueFor("crit_mult")
		else
			return 0
		end
	end
    return false
end

function TG_Direction(fpos,spos)
  local DIR=( fpos - spos):Normalized()
  DIR.z=0
  return DIR
end

function TG_Direction2(fpos,spos)
  local DIR=( fpos - spos):Normalized()
  return DIR
end

--[[local fxtx={
        "particles/mjjcjn/fx_1.vpcf",
        "particles/mjjcjn/fx_2.vpcf",
        "particles/mjjcjn/fx_3.vpcf",
        "particles/mjjcjn/fx_4.vpcf",
        "particles/mjjcjn/fx_5.vpcf",
        "particles/mjjcjn/fx_6.vpcf",
        "particles/mjjcjn/fx_7.vpcf",

        }

local fxtx1={
        "particles/mjjcjn/fx_1.vpcf",
        "particles/mjjcjn/fx_3.vpcf",
        "particles/mjjcjn/fx_5.vpcf",

        }
]]--

function modifier_juggernaut_blade_dance_lua_pa:OnAttackLanded(tg)
    if not IsServer() then
		return
	end
	if tg.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled()  or tg.target:IsBuilding() or not tg.target:IsAlive() then
		return
    end
    if self.crit[tg.record] then
        local pos=tg.attacker:GetAbsOrigin()
        local spawn=tg.target:GetAbsOrigin()
        local dirt=TG_Direction(spawn+Vector(1,1,1),pos)
        self:GetParent():EmitSound("TG.juggjump")
        local projname = "particles/heros/jugg/jugg_shockwave.vpcf"
        --[[local steamid = tonumber(tostring(PlayerResource:GetSteamID(self:GetCaster():GetPlayerOwnerID())))
        local idtable = {
                        76561198095935075,  --我
                        76561198155292109,  --ho爷
                        76561198373494791,  --阿杰
                        

                    }
        local idtable1 = {
                        76561198103303225,  --SS
                        76561198104417037,  --月爷
                   }
        local idtable2 = {
                        76561198305143149,  --agust
                   }
        local idtable3 = {
                        76561198112208819,  --深拥
                   }
        local green = Is_DATA_TG(idtable,steamid)     --单色
        local gquan = Is_DATA_TG(idtable1,steamid)    --全色
        local gqthree = Is_DATA_TG(idtable2,steamid)    --三色
        if green then 
            projname = "particles/mjjcjn/fx_1.vpcf"
        elseif Is_DATA_TG(idtable3,steamid) then 
            projname = "particles/mjjcjn/fx_7.vpcf" 
        elseif gquan then
            projname = fxtx[RandomInt(1, #fxtx)]
        elseif gqthree then 
            projname = fxtx[RandomInt(1, #fxtx1)]  
        end]]--
        local Projectile = 
        {
        Ability = self:GetAbility(),
        EffectName = projname,
        vSpawnOrigin = self:GetParent():GetAbsOrigin(),
        fDistance = 3000,
        fStartRadius =200 ,
        fEndRadius =200,
        Source = self:GetParent(),
        fMaxSpeed = 2000,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        vVelocity = dirt*2000,
        bVisibleToEnemies = true,
        }                
        ProjectileManager:CreateLinearProjectile( Projectile )
    local p = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_crit_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, tg.target)
    ParticleManager:SetParticleControlEnt(p, 1, tg.target, PATTACH_ABSORIGIN_FOLLOW, nil, tg.target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)
    end
    self.crit[tg.record] = nil
    end

function modifier_juggernaut_blade_dance_lua_pa:OnAttackFail(tg) 
        if not IsServer() then
            return
        end
        self.crit[tg.record] = nil
end

function modifier_juggernaut_blade_dance_lua_pa:OnDestroy() 
        self.crit = nil 
end


modifier_juggernaut_blade_dance_lua_move=class({})


function modifier_juggernaut_blade_dance_lua_move:IsHidden() 			
    return false 
end

function modifier_juggernaut_blade_dance_lua_move:IsPurgable() 			
    return false 
end

function modifier_juggernaut_blade_dance_lua_move:IsPurgeException() 	
    return false 
end

function modifier_juggernaut_blade_dance_lua_move:OnCreated(tg)
    if not IsServer() then
        return
    end
    local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_trail_spirit/courier_trail_spirit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle( particle, false, false, 20, false, false )
    local particle2 = ParticleManager:CreateParticle("particles/heros/jugg/jugg_jump.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle( particle2, false, false, 20, false, false )    
    self.DIR=ToVector(tg.dir)
    self.POS=self:GetParent():GetAbsOrigin()
		if not self:ApplyHorizontalMotionController()then 
			self:Destroy()
		end

end

function modifier_juggernaut_blade_dance_lua_move:UpdateHorizontalMotion( t, g )
    if not IsServer() then
        return
    end  
    self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin()+self.DIR* (1500 / (1.0 / g )))
end


function modifier_juggernaut_blade_dance_lua_move:OnDestroy()
    if not IsServer() then
        return
    end
    self:GetParent():RemoveHorizontalMotionController(self)
end

function modifier_juggernaut_blade_dance_lua_move:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}
end

function modifier_juggernaut_blade_dance_lua_move:GetOverrideAnimation()
    return ACT_DOTA_VICTORY
end

function modifier_juggernaut_blade_dance_lua_move:GetModifierTurnRate_Percentage() 	
	return 100
end

function modifier_juggernaut_blade_dance_lua_move:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED] = true,
    }
end