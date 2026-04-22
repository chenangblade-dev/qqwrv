imba_luna_moon_glaive = class({})

LinkLuaModifier("modifier_imba_luna_moon_glaive", "heroes/hero_luna/imba_luna_moon_glaive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_luna_moon_glaive_nodmg", "heroes/hero_luna/imba_luna_moon_glaive.lua", LUA_MODIFIER_MOTION_NONE)

function imba_luna_moon_glaive:GetIntrinsicModifierName() return "modifier_imba_luna_moon_glaive" end
function imba_luna_moon_glaive:Init()
	if IsServer() then
	self.bounces = self:GetSpecialValueFor("bounces")
	self.range = self:GetSpecialValueFor("range")
	self.damage_reduction = self:GetSpecialValueFor("damage_reduction_percent")
	self.damageTable=	{
						attacker = self:GetCaster(),
						ability = self, 
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
						}
	end
end
function imba_luna_moon_glaive:OnUpgrade()
	if not IsServer() then return end
	if self then
		self.bounces = self:GetSpecialValueFor("bounces")
		self.range = self:GetSpecialValueFor("range")
		self.damage_reduction = self:GetSpecialValueFor("damage_reduction_percent")
	end
end

function imba_luna_moon_glaive:GlaiveAttck(source, damage, bounce)
	local target = nil 
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), source:GetAbsOrigin(), nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= source then
			target = enemy
			break
		end
	end
	if target == nil then
		return
	end
	local info = 
	{
		Target = target,
		Source = source,
		Ability = self,	
		EffectName = self:GetCaster():GetUnitName() == "npc_dota_hero_luna" and self:GetCaster():GetRangedProjectileName() or "particles/units/heroes/hero_luna/luna_moon_glaive.vpcf",
		iMoveSpeed = (self:GetCaster():IsRangedAttacker() and self:GetCaster():GetProjectileSpeed() or 900),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		bProvidesVision = false,
		ExtraData = {bounces = bounce, dmg = damage}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_luna_moon_glaive:OnProjectileHit_ExtraData(target, location, keys)
	local damage_reduction  = GameRules:IsDaytime()  and self.damage_reduction or 0
	local damage = keys.dmg * (1 - damage_reduction / 100)
	if target then
		target:EmitSound("Hero_Luna.MoonGlaive.Impact")
		damage=target:IsBuilding() and keys.dmg*0.1 or damage
		self.damageTable.victim = target
		self.damageTable.damage = damage
		ApplyDamage(self.damageTable)
		local bounce = keys.bounces + 1 
		if bounce >= self.bounces then
			return
		end
		local next_target = target
		self:GlaiveAttck(next_target, damage, bounce)
	end
end

modifier_imba_luna_moon_glaive = class({})

function modifier_imba_luna_moon_glaive:IsDebuff()			return false end
function modifier_imba_luna_moon_glaive:IsHidden() 			return false end
function modifier_imba_luna_moon_glaive:IsPurgable() 		return false end
function modifier_imba_luna_moon_glaive:IsPurgeException() 	return false end
function modifier_imba_luna_moon_glaive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_EVENT_ON_DEATH,MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_imba_luna_moon_glaive:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("range_bonus")
	end
end
function modifier_imba_luna_moon_glaive:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_ambient_moon_glaive.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		self:SetStackCount(0)
	end
end

function modifier_imba_luna_moon_glaive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsOther() or self:GetParent():PassivesDisabled()  or not keys.target:IsAlive() then
		return
	end
	local dmg = keys.original_damage
	self:GetAbility():GlaiveAttck(keys.target, dmg, 0)
end

function modifier_imba_luna_moon_glaive:OnDeath(keys)
--not self:GetCaster():IsAlive() or keys.unit~= self:GetParent() 
	if not IsServer() then return end

	if keys.unit:IS_TrueHero_TG() and keys.attacker == self:GetParent() then
		self:SetStackCount(self:GetStackCount() + 1)
	end
end








