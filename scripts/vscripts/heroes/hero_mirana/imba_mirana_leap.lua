imba_mirana_leap = class({})

LinkLuaModifier("modifier_imba_leap", "heroes/hero_mirana/imba_mirana_leap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_leap_motion", "heroes/hero_mirana/imba_mirana_leap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_leap_day", "heroes/hero_mirana/imba_mirana_leap.lua", LUA_MODIFIER_MOTION_NONE)

function imba_mirana_leap:IsHiddenWhenStolen() 		return false end
function imba_mirana_leap:IsRefreshable() 			return true end
function imba_mirana_leap:IsStealable() 			return true end
function imba_mirana_leap:GetIntrinsicModifierName() return "modifier_imba_leap_day" end
function imba_mirana_leap:GetCastRange() return ((self:GetCaster():GetModifierStackCount("modifier_imba_leap_day", self:GetCaster()) == 0 or self:GetCaster():HasScepter()) and 50000 or self:GetSpecialValueFor("base_distance")) end

function imba_mirana_leap:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local distance = (pos - caster:GetAbsOrigin()):Length2D()
	local time = distance / self:GetSpecialValueFor("min_speed")
	local extra_cd = math.max(0, (distance - self:GetSpecialValueFor("base_distance")) / self:GetSpecialValueFor("base_distance")) * self:GetSpecialValueFor("cooldown_increase")
	local height = self:GetSpecialValueFor("base_height") + math.min(math.max(0, (distance - self:GetSpecialValueFor("base_distance")) / self:GetSpecialValueFor("base_distance")) * self:GetSpecialValueFor("height_step"), self:GetSpecialValueFor("max_height"))
	self:EndCooldown()
	self:StartCooldown((self:GetCooldown(self:GetLevel() - 1) + extra_cd) * caster:GetCooldownReduction())
	caster:AddNewModifier(caster, self, "modifier_imba_leap_motion", {duration = time, pos_x = pos.x, pos_y = pos.y, pos_z = pos.z, height = height})
	--caster:StartGesture(ACT_DOTA_CAST3_STATUE)
	caster:EmitSound("Ability.Leap")
end

modifier_imba_leap_day = class({})  -- use this to know day and night

function modifier_imba_leap_day:IsDebuff()			return false end
function modifier_imba_leap_day:IsHidden() 			return true end
function modifier_imba_leap_day:IsPurgable() 		return false end
function modifier_imba_leap_day:IsPurgeException() 	return false end
function modifier_imba_leap_day:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end
function modifier_imba_leap_day:OnIntervalThink()
	if GameRules:IsDaytime() then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

modifier_imba_leap_motion = class({})

function modifier_imba_leap_motion:IsDebuff()			return false end
function modifier_imba_leap_motion:IsHidden() 			return true end
function modifier_imba_leap_motion:IsPurgable() 		return false end
function modifier_imba_leap_motion:IsPurgeException() 	return false end
function modifier_imba_leap_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_leap_motion:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_3 end
function modifier_imba_leap_motion:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_leap_motion:IsMotionController() return true end
function modifier_imba_leap_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_imba_leap_motion:OnCreated(keys)
	if IsServer() then
		if self:CheckMotionControllers() then
			self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
			self.height = keys.height
			self:OnIntervalThink()
			self:StartIntervalThink(FrameTime())
		else
			self:Destroy()
		end
	end
end
 
function modifier_imba_leap_motion:OnIntervalThink()
	local total_ticks = self:GetDuration() / FrameTime()
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local distance = self:GetAbility():GetSpecialValueFor("min_speed") / (1.0 / FrameTime())
	local height = self.height
	local direction = (self.pos - self:GetParent():GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + direction * distance, nil)
	next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
	self:GetParent():SetOrigin(next_pos)
	--local allies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), next_pos, nil, self:GetAbility():GetSpecialValueFor("buff_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	--for _, ally in pairs(allies) do
	self:GetCaster():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_leap", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
	--end
end

function modifier_imba_leap_motion:OnDestroy()
	if IsServer() then
		self.pos = nil
		self.height = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_imba_leap_motion:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true}
end

modifier_imba_leap = class({})
function IsUnit(BaseNPC)
	return BaseNPC:IsHero() or BaseNPC:IsCreep() or BaseNPC:IsBoss()
end




function modifier_imba_leap:IsDebuff()			return false end
function modifier_imba_leap:IsHidden() 			return false end
function modifier_imba_leap:IsPurgable() 		return true end
function modifier_imba_leap:IsPurgeException() 	return true end
function modifier_imba_leap:DeclareFunctions() 
	return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, 
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ATTACK_FAIL} 
		end
function modifier_imba_leap:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return self:GetAbility():GetSpecialValueFor("leap_speedbonus") 
	end
	return self:GetAbility():GetSpecialValueFor("leap_speedbonus")+40
end

function modifier_imba_leap:GetModifierAttackSpeedBonus_Constant() 
	return self:GetAbility():GetSpecialValueFor("leap_speedbonus_as")
end

function modifier_imba_leap:GetModifierIgnoreMovespeedLimit()
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        return 1
    end
end

function modifier_imba_leap:OnCreated() 
	self.crit = {} 
	self.ability=self:GetAbility()
end
function modifier_imba_leap:OnDestroy() self.crit = nil end
--暴击
function modifier_imba_leap:GetModifierPreAttack_CriticalStrike(keys)
	if not self:GetCaster():Has_Aghanims_Shard() then
		return 
	end
	if IsServer() and keys.attacker == self:GetParent() and IsUnit(keys.target) and not self:GetParent():PassivesDisabled() then		
		self.crit[keys.record] = true		
		return self.ability:GetSpecialValueFor("crit_multiplier")
	end
end

function modifier_imba_leap:OnAttackFail(keys) self.crit[keys.record] = nil end
function modifier_imba_leap:OnAttackLanded(keys)
	if not IsServer() then
		return 
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or not keys.target:IsAlive() then
		return
	end
	if keys.target:IsBuilding() or keys.target:IsOther() then
		return
	end
	self.crit[keys.record] = nil
end