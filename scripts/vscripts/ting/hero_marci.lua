--龙拳
imba_marci_1 = class({})

LinkLuaModifier("modifier_imba_marci_1_move", "ting/hero_marci", LUA_MODIFIER_MOTION_BOTH)


function imba_marci_1:IsStealable() return false end



function imba_marci_1:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	EmitSoundOn("Hero_Lina.DragonSlave", self.caster)
	self.caster:AddNewModifier(self.caster,self,"modifier_imba_marci_1_move",{duration = 0.1})
	if self.caster:TG_HasTalent("special_bonus_imba_marci_t4") then
		ProjectileManager:ProjectileDodge(self.caster)
	end
	

	
	
end

modifier_imba_marci_1_move = class({})
function modifier_imba_marci_1_move:GetStatusEffectName()
    return "particles/status_fx/status_effect_omnislash.vpcf"
end


function modifier_imba_marci_1_move:IsDebuff() return false end
function modifier_imba_marci_1_move:IsHidden() return true end
function modifier_imba_marci_1_move:IsPurgable() return false end

function modifier_imba_marci_1_move:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_marci_1_move:GetModifierPreAttack_BonusDamage() return self.damage end
function modifier_imba_marci_1_move:GetMotionPriority() 	
	return DOTA_MOTION_CONTROLLER_PRIORITY_LOW
end
function modifier_imba_marci_1_move:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_imba_marci_1_move:OnCreated(params)
	if not IsServer() then return end
	if self:GetAbility() == nil then return end
	
	
	self.caster = self:GetCaster()
	self.parent = self:GetParent()   
	self.ability = self:GetAbility()

	self.distance =self.ability:GetSpecialValueFor("distance")
	if not self.parent:IsRangedAttacker() then 
		self.distance = self.ability:GetSpecialValueFor("distance")*1.5
	end
	self.width =self.ability:GetSpecialValueFor("width")
	self.damage = self.ability:GetSpecialValueFor("damage")
	
	self.pos = self.parent:GetAbsOrigin()
	self.angle = self:GetParent():GetForwardVector() 
	self.force_pos = GetGroundPosition(( self.pos + self.angle * self.distance ), nil)
	
	self.speed = self.distance / self:GetDuration()
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,3)

    local p1 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_dash.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControlEnt(p1, 0, self.parent, PATTACH_ABSORIGIN, nil, self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(p1, 0, self.force_pos)
    ParticleManager:SetParticleControl(p1, 1, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(p1, 2, self.force_pos)
	ParticleManager:SetParticleControlForward( p1, 0, self.angle*-1 )
	ParticleManager:SetParticleControlForward( p1, 1, self.angle*-1 )
	ParticleManager:SetParticleControlForward( p1, 2, self.angle*-1 )
    --ParticleManager:SetParticleControl(p1, 2, self.force_pos)
    ParticleManager:ReleaseParticleIndex(p1)
	local enemies = FindUnitsInLine(
			self.caster:GetTeamNumber(),
			self.pos,
			self.force_pos, 
			self.parent,
			self.width, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 
			DOTA_UNIT_TARGET_FLAG_NONE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
	
			for _,enemy in pairs( enemies ) do
				self.caster:PerformAttack(enemy, true, true, true, false, false, false, true)	
			end

	if self:ApplyHorizontalMotionController() == false then
		self:Destroy()
	end
	
end

function modifier_imba_marci_1_move:OnDestroy()
	if not IsServer() then return end


	self:GetParent():RemoveHorizontalMotionController( self )
	--self:GetParent():FadeGesture(ACT_DOTA_ATTACK)
	--ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)

end

function modifier_imba_marci_1_move:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end
	local distance = (self.force_pos - me:GetAbsOrigin()):Normalized()
	local next_pos = me:GetAbsOrigin() + distance * self.speed * dt
	me:SetOrigin( next_pos )
	GridNav:DestroyTreesAroundPoint(next_pos, 80, false)
end

function modifier_imba_marci_1_move:OnHorizontalMotionInterrupted()
	self:Destroy()
end



