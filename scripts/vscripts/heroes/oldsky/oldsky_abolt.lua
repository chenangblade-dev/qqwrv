oldsky_abolt = class({})

LinkLuaModifier( "modifier_oldsky_abolt_stack", "heroes/oldsky/modifier_oldsky_abolt_stack", LUA_MODIFIER_MOTION_NONE )

function oldsky_abolt:IsHiddenWhenStolen() 	return false end
function oldsky_abolt:IsRefreshable() 		return true end
function oldsky_abolt:IsStealable() 			return true end
--[[
★创建投射物。
--]]
function TG_CreateProjectile(t)
  local ID = t.id==0 and ProjectileManager:CreateLinearProjectile(t.p) or ProjectileManager:CreateTrackingProjectile(t.p)
  if not t.owner.PID then
    return
  end
  t.projectile=ID
  table.insert (t.owner.PID,t)
  table.insert (CDOTA_PlayerResource.Projectile , t)
 --[[ Timers:CreateTimer(15, function()
    for num=1,#CDOTA_PlayerResource.Projectile do
      if CDOTA_PlayerResource.Projectile[num]==t then
   --     table.remove (CDOTA_PlayerResource.Projectile,num)
      end
    end
    return nil
  end)]]
  return t
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


function oldsky_abolt:OnSpellStart(scepter,talent)
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    caster:EmitSound("Hero_SkywrathMage.ArcaneBolt.Cast")

    local projname = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf"

    local steamid = tonumber(tostring(PlayerResource:GetSteamID(self:GetCaster():GetPlayerOwnerID())))
    local idtable = {
                        76561198095935075,  --我
                        76561198155292109,  --ho爷

                    }
    local green = Is_DATA_TG(idtable,steamid)    --绿色C
	if green then projname = "particles/dlparticles/oldsky_abolt/green_p_skywrath_mage_arcane_bolt.vpcf" end

	local projspeed = self:GetSpecialValueFor("abolt_speed")
	if caster:Has_Aghanims_Shard() then projspeed = projspeed + 300 end	--魔晶加C速度

    local info =
    {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = projname ,
        iMoveSpeed = projspeed ,
        bDrawsOnMinimap = false,
        bDodgeable = false,
        bIsAttack = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        flExpireTime = GameRules:GetGameTime() + 10,

        bProvidesVision = true, --Bad key for entity "npc_dota_base": Out of range parsed value for field "teamnumber" (-1)!
		iVisionRadius = self:GetSpecialValueFor("abolt_visionrad"),
		fVisionDuration = 10,
		iVisionTeamNumber = caster:GetTeamNumber(), --如果不加这一行就会出现上面那种报错
    }

    TG_CreateProjectile({id=1,team=caster:GetTeamNumber(),owner=caster,p=info})

	if caster:HasScepter() and not scepter then                 --A杖C。因为加了参数所以不会触发下面代码
		local radius = self:GetSpecialValueFor("abolt_range") + caster:GetCastRangeBonus()
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
		for _, hero in pairs(heroes) do
			if hero ~= target then
				caster:SetCursorCastTarget(hero)
				self:OnSpellStart(true) --当成功触发onspellstart，下面的代码也将停止执行。简单完美地还原了A杖效果，秒啊
				return
			end
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
		for _, unit in pairs(units) do
			if unit ~= target then
				caster:SetCursorCastTarget(unit)
				self:OnSpellStart(true)
				return
			end
		end
    end

	if  not talent then     --天赋加一个C，onspellstart加一个参数,注意一旦上面A杖的onspellstart触发就不继续往下走了

        local radius = self:GetSpecialValueFor("abolt_range") + caster:GetCastRangeBonus()					--搜寻排序跟A杖区别开换成最远，否则永远都是3个C打两个人 ↓
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_FARTHEST, false)
		for _, hero in pairs(heroes) do
			if hero ~= target then
				caster:SetCursorCastTarget(hero)
				self:OnSpellStart(true,true) --当成功触发onspellstart，下面的代码也将停止执行。简单完美地还原了A杖效果，秒啊
				return
			end
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_FARTHEST, false)
		for _, unit in pairs(units) do
			if unit ~= target then
				caster:SetCursorCastTarget(unit)
				self:OnSpellStart(true,true)
				return
			end
		end
    end

end


function oldsky_abolt:OnProjectileHit(target, location)
    if not target then return end
    if target:IsMagicImmune() or target:TriggerStandardTargetSpell(self) or not target:IsAlive() then return end
    if target:TG_TriggerSpellAbsorb(self) then return end

    target:EmitSound("Hero_SkywrathMage.ArcaneBolt.Impact")
    local caster = self:GetCaster()

    local aboltintcostack = self:GetSpecialValueFor("abolt_intco_stack")
	if caster:HasScepter() then aboltintcostack = aboltintcostack *2 end	--A帐加系数

    AddFOWViewer(caster:GetTeamNumber(), location, self:GetSpecialValueFor("abolt_visionrad"), self:GetSpecialValueFor("abolt_visiondur"), false)

    caster:AddNewModifier(caster, self, "modifier_oldsky_abolt_stack", {duration = self:GetSpecialValueFor("abolt_stackdur")})

    local buff = caster:FindModifierByName("modifier_oldsky_abolt_stack")
    local intco_stack = 0
    if buff then intco_stack = buff:GetStackCount()*aboltintcostack end --可能可以防报错

    local intco = self:GetSpecialValueFor("abolt_intco") + intco_stack   --基础智力系数加层数智力系数

	local dmg = self:GetSpecialValueFor("abolt_damage") + caster:GetIntellect() * intco
	local damageTable = {
						victim = target,
						attacker = caster,
						damage = dmg,
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
end
  