

item_xizhilangjelly = class({})
LinkLuaModifier("modifier_item_xizhilangjelly", "items/item_xizhilangjelly", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function item_xizhilangjelly:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		self.gold = self:GetSpecialValueFor("gold")
		hTarget:ModifyGold(self.gold, true, DOTA_ModifyGold_Unspecified)
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_item_xizhilangjelly", {duration = -1})
		EmitSoundOn("DOTA_Item.HotD.Activate", self:GetCaster())
		if self:GetCurrentCharges() > 1 then
			self:SpendCharge()
		else
			self:GetCaster():RemoveItem(self)
		end
	end
end

--------------------------------------------------------------------------------

function item_xizhilangjelly:CastFilterResultTarget(hTarget)
	if IsServer() then
		if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			return UF_FAIL_ENEMY
		end
		if not hTarget:IsHero() then
			return UF_FAIL_CREEP
		end
		if hTarget:HasModifier("modifier_item_xizhilangjelly") then

			return UF_FAIL_CUSTOM
		end
	end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------

function item_xizhilangjelly:GetCustomCastErrorTarget(hTarget)
	return "dota_hud_error_item_xizhilangjelly_cannot_stack"
end

modifier_item_xizhilangjelly = class({})
function modifier_item_xizhilangjelly:IsHidden()	return false end
function modifier_item_xizhilangjelly:IsPurgable()	return false end
function modifier_item_xizhilangjelly:RemoveOnDeath()	return false end
function modifier_item_xizhilangjelly:IsDebuff()	return false end
function modifier_item_xizhilangjelly:GetTexture()	return "item_xizhilangjelly" end
function modifier_item_xizhilangjelly:OnCreated( kv )
	self.bonus_hp_regen = self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
	self.bonus_mp_regen = self:GetAbility():GetSpecialValueFor("bonus_mp_regen")
end
function modifier_item_xizhilangjelly:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end
function modifier_item_xizhilangjelly:GetModifierConstantHealthRegen(params)
	return self.bonus_hp_regen
end
function modifier_item_xizhilangjelly:GetModifierConstantManaRegen(params)
	return self.bonus_mp_regen
end

