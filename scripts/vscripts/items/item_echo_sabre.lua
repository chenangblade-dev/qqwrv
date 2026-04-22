
item_imba_echo_sabre = class({})
function item_imba_echo_sabre:GetIntrinsicModifierName() 
	if self:GetCaster():IsRangedAttacker() then
	   	return ""
    else
		return "modifier_imba_echo_sabre_passive" 
	end
end
LinkLuaModifier("modifier_item_imba_echo_sabre_slow", "items/item_echo_sabre", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_echo_sabre_passive", "items/item_echo_sabre", LUA_MODIFIER_MOTION_NONE)

modifier_imba_echo_sabre_passive = class({})

function modifier_imba_echo_sabre_passive:IsDebuff()			return false end
function modifier_imba_echo_sabre_passive:IsHidden() 			return true end
function modifier_imba_echo_sabre_passive:IsPurgable() 			return false end
function modifier_imba_echo_sabre_passive:IsPurgeException() 	return false end
function modifier_imba_echo_sabre_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_echo_sabre_passive:GetPriority()	return MODIFIER_PRIORITY_LOW end
function modifier_imba_echo_sabre_passive:DeclareFunctions() 
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, 
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, 
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
			MODIFIER_EVENT_ON_ATTACK} 
end
function modifier_imba_echo_sabre_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_imba_echo_sabre_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_echo_sabre_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_imba_echo_sabre_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_arm") end
function modifier_imba_echo_sabre_passive:GetBonusNightVision() return self:GetAbility():GetSpecialValueFor("bonus_vision") end
function modifier_imba_echo_sabre_passive:GetModifierAttackSpeedBonus_Constant()
	if IsServer() and self:GetStackCount() > 0 and self.buff== true then
		return (self:GetAbility():GetSpecialValueFor("bonus_attack_speed") + 10000)
	else
		return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end
function modifier_imba_echo_sabre_passive:GetModifierBaseAttackTimeConstant()
	if IsServer() and self:GetStackCount() > 0 and self.buff== true then
		return (1.0)
	else
		return nil
	end
end

function modifier_imba_echo_sabre_passive:GetModifierMoveSpeedBonus_Constant()
	return  self:GetAbility():GetSpecialValueFor("move_speedb")
end
function modifier_imba_echo_sabre_passive:OnCreated()
	if IsServer() then
		self.hit=3
	end
	self.buff = false

end

function modifier_imba_echo_sabre_passive:OnIntervalThink()
	if self:GetStackCount() < self.hit then
		self.buff = false
		self.hit = RandomInt(2, 3)
		self:SetStackCount(self.hit)
	end
	self:StartIntervalThink(-1)

end

function modifier_imba_echo_sabre_passive:OnAttack(keys)
	if IsServer() and self:GetParent() == keys.attacker then
		if self:GetStackCount() == self.hit and not self:GetAbility():IsCooldownReady() then
			return
		end
		if self:GetStackCount() == self.hit then
			self.buff = true
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_echo_sabre_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
		end
		self:DecrementStackCount()
		if self:GetStackCount() ~= self.hit and self:GetAbility():IsCooldownReady() then
			self:StartIntervalThink(1)
			self:GetAbility():UseResources(false,false,false,true)
		end
	end
end

modifier_item_imba_echo_sabre_slow = class({})

function modifier_item_imba_echo_sabre_slow:IsDebuff()			return true end
function modifier_item_imba_echo_sabre_slow:IsHidden() 			return false end
function modifier_item_imba_echo_sabre_slow:IsPurgable() 		return false end
function modifier_item_imba_echo_sabre_slow:IsPurgeException() 	return false end
function modifier_item_imba_echo_sabre_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, } end
function modifier_item_imba_echo_sabre_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("movement_slow")) end
