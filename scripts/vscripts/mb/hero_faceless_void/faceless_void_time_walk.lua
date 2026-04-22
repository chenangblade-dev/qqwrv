-- Author: MysticBug 08/30/2021

--------------------------------------------------------------
--		   		 IMBA_FACELESS_VOID_TIME_WALK               --
--------------------------------------------------------------
imba_faceless_void_time_walk = class({})

LinkLuaModifier("modifier_imba_faceless_void_time_walk_motion", "mb/hero_faceless_void/faceless_void_time_walk", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_imba_time_walk_damage", "mb/hero_faceless_void/faceless_void_time_walk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_time_walk_damage_counter", "mb/hero_faceless_void/faceless_void_time_walk", LUA_MODIFIER_MOTION_NONE)
--scepter
require("mb/hero_faceless_void/faceless_void_chronosphere")

function imba_faceless_void_time_walk:IsHiddenWhenStolen() 		return false end
function imba_faceless_void_time_walk:IsRefreshable() 			return true  end
function imba_faceless_void_time_walk:IsStealable() 			return true  end
function imba_faceless_void_time_walk:IsNetherWardStealable() 	return true end
function imba_faceless_void_time_walk:GetCastRange(location , target)
	if IsClient() then 
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then 
			return self:GetSpecialValueFor("range")	+  self:GetSpecialValueFor("range_shard")
		else
			return self:GetSpecialValueFor("range")
		end	
	end
end
--Talent

function imba_faceless_void_time_walk:GetCooldown(i) return self.BaseClass.GetCooldown(self, i) end
function imba_faceless_void_time_walk:GetIntrinsicModifierName() return "modifier_imba_time_walk_damage" end
function imba_faceless_void_time_walk:OnSpellStart()
	if not IsServer() then return end
	local caster       = self:GetCaster()
	local original_pos = caster:GetAbsOrigin()
	local pos          = self:GetCursorPosition()
	--local direction  = (pos - caster:GetAbsOrigin()):Normalized()  pfx maybe casuse bug 
	local direction    = (pos ~= original_pos and (pos - original_pos):Normalized()) or caster:GetForwardVector()
	direction.z = 0
	local max_distance = self:GetSpecialValueFor("range") + caster:GetCastRangeBonus()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then 
		max_distance = max_distance + self:GetSpecialValueFor("range_shard")
	end
	local distance        = math.min(max_distance, (caster:GetAbsOrigin() - pos):Length2D())
	local tralve_duration = distance / self:GetSpecialValueFor("speed")
	local sound_name      = "Hero_FacelessVoid.TimeWalk.Aeons"
	--if HeroItems:UnitHasItem(caster, "jewel_of_aeons") then
	--sound_name = "Hero_FacelessVoid.TimeWalk.Aeons"
	--end
	caster:AddNewModifier(caster, self, "modifier_imba_faceless_void_time_walk_motion", {duration = tralve_duration, direction = direction , distance = distance})
	local buffs = caster:FindAllModifiersByName("modifier_imba_time_walk_damage_counter")
	local heal  = 0 
	for _, buff in pairs(buffs) do
		heal = heal + buff:GetStackCount() / 10
	end
	caster:EmitSound(sound_name)
	caster:Heal(heal, caster)
end

function StringToVector(sString)
	--Input: "123 123 123"
	local temp = {}
	for str in string.gmatch(sString, "%S+") do
		if tonumber(str) then
			temp[#temp + 1] = tonumber(str)
		else
			return nil
		end
	end
	return Vector(temp[1], temp[2], temp[3])
end

--------------------------------------------------------------
--		  MODIFIER_IMBA_FACELESS_VOID_TIME_WALK_MOTION      --
--------------------------------------------------------------
modifier_imba_faceless_void_time_walk_motion = class({})
function modifier_imba_faceless_void_time_walk_motion:IsDebuff()			return false end
function modifier_imba_faceless_void_time_walk_motion:IsHidden() 			return true end
function modifier_imba_faceless_void_time_walk_motion:IsPurgable() 			return false end
function modifier_imba_faceless_void_time_walk_motion:IsPurgeException() 	return false end
function modifier_imba_faceless_void_time_walk_motion:GetEffectName() return "particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_jewel.vpcf" end
function modifier_imba_faceless_void_time_walk_motion:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_faceless_void_time_walk_motion:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_faceless_void_time_walk_motion:IsMotionController() return true end
function modifier_imba_faceless_void_time_walk_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_imba_faceless_void_time_walk_motion:OnCreated(keys)
	if not IsServer() then return end
	self.ability          = self:GetAbility()
	self.caster           = self.ability:GetCaster()
	self.parent           = self:GetParent()
	--kv
	self.direction        = StringToVector(keys.direction)
	self.speed            = self.ability:GetSpecialValueFor("speed")
	self.walk_pos         = self.caster:GetAbsOrigin() + self.direction * keys.distance
	self.debuff_duration  = self.ability:GetSpecialValueFor("duration")
	self.bShard           = keys.bShard
	self.effected_enemies = {}
	--speed
	--self.walk_pos	= GetGroundPosition(Vector(self.direction.x, self.direction.y, 0), nil)
	
	--start Horizontal motion controller
	if self:ApplyHorizontalMotionController() == false then
		self:Destroy()
	end
end

function modifier_imba_faceless_void_time_walk_motion:OnRefresh()
	self:OnCreated(keys)
end


function IsInTable(value, hTable)
	for i=0, #hTable do
		if hTable[i] == value then
			return true
		end
	end
	return false
end


function modifier_imba_faceless_void_time_walk_motion:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end
	--Horizontal
	me:SetOrigin( me:GetAbsOrigin() + self.direction * self.speed * dt )
	--record effected enemies
	local enemy = FindUnitsInRadius(me:GetTeamNumber(), me:GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("chrono_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		if not IsInTable(enemy[i], self.effected_enemies) then
			self.effected_enemies[#self.effected_enemies + 1] = enemy[i]
			enemy[i]:AddNewModifier_RS(self.caster, self.ability, "modifier_stunned", {duration = 0.1})
		end
	end
end

function modifier_imba_faceless_void_time_walk_motion:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_imba_faceless_void_time_walk_motion:OnDestroy()
	if not IsServer() then return end
	--over motion
	self.parent:RemoveHorizontalMotionController( self )
	--position reset
	self.parent:SetAbsOrigin(self.walk_pos)
	--ResolveNPCPositions(self.walk_pos, 128) --maybe cause bug
	FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
	--buff
	local radius_scepter = self.ability:GetSpecialValueFor("radius_scepter")
	--05-09 Scepter by MysteryBug
	if self.caster:HasScepter() and self.ability:GetName() == "imba_faceless_void_time_walk" and not self.bShard and self.parent:HasAbility("faceless_void_time_lock") then 
		local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, radius_scepter, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		CreateChronosphere(self.parent, self.ability, self.caster:GetAbsOrigin(), radius_scepter, 0.5, 2)
		for _, enemy in pairs(enemies) do
			self.parent:PerformAttack(enemy, false, true, true, true, false, false, false)
		end
	end
end

--------------------------------------------------------------
modifier_imba_time_walk_damage_counter = class({})

function modifier_imba_time_walk_damage_counter:IsDebuff()				return false end
function modifier_imba_time_walk_damage_counter:IsHidden() 				return true end
function modifier_imba_time_walk_damage_counter:IsPurgable() 			return false end
function modifier_imba_time_walk_damage_counter:IsPurgeException() 		return false end
function modifier_imba_time_walk_damage_counter:GetAttributes()			return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_time_walk_damage_counter:RemoveOnDeath() return false end

--------------------------------------------------------------
modifier_imba_time_walk_damage = class({})

function modifier_imba_time_walk_damage:IsDebuff()				return false end
function modifier_imba_time_walk_damage:IsHidden() 				return true end
function modifier_imba_time_walk_damage:IsPurgable() 			return false end
function modifier_imba_time_walk_damage:IsPurgeException() 		return false end
function modifier_imba_time_walk_damage:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_time_walk_damage:OnTakeDamage(keys)
	if not IsServer() then 
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then
		return
	end
	local damage_time = self:GetAbility():GetSpecialValueFor("damage_time") 
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_time_walk_damage_counter", {duration = damage_time})
	if buff ~= nil then 
		buff:SetStackCount(keys.damage * 10)
	end
end


