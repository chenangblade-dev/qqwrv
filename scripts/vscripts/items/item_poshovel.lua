
item_poshovel = class({})
LinkLuaModifier("modifier_item_poshovel", "items/item_poshovel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_poshovel_thinker", "items/item_poshovel", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function item_poshovel:GetIntrinsicModifierName() return "modifier_item_poshovel" end
function item_poshovel:IsRefreshable() return false end
function item_poshovel:OnSpellStart()
	if IsServer() then
		self.vPos = self:GetCaster():GetCursorPosition()
		self.hShovelThinker = CreateModifierThinker(self:GetCaster(), self, "modifier_item_poshovel_thinker", {}, self.vPos, self:GetCaster():GetTeamNumber(), false)
		
		EmitSoundOn("SeasonalConsumable.TI9.Shovel.Dig", self:GetCaster())
	end
end
function item_poshovel:OnChannelFinish(bInterrupted)
	if IsServer() then
		if self.hShovelThinker and not self.hShovelThinker:IsNull() then
			UTIL_Remove(self.hShovelThinker)
		end
		if not bInterrupted then

			local nRandomSeed = RandomInt(11, 100)
			if nRandomSeed <= 34 then
				local hTarget = self:GetCaster()
				local Randomgold=RandomInt(100, 400)*-1
				hTarget:ModifyGold(Randomgold, true, DOTA_ModifyGold_Unspecified)
				local player = hTarget:GetPlayerOwner()
				SendOverheadEventMessage(player, OVERHEAD_ALERT_MANA_LOSS, hTarget, Randomgold, player)
			elseif nRandomSeed <= 43 then
				local hNewItem = CreateItem("item_dimensional_doorway", nil, nil)
				hNewItem:SetPurchaseTime(0)
				hNewItem:SetCurrentCharges(1)
				hNewItem:SetSellable(false)
				local drop = CreateItemOnPositionSync(self.vPos, hNewItem)
				hNewItem:LaunchLoot(false, 150, 0.5, self.vPos, nil)
			elseif nRandomSeed <= 55 then
				local hNewItem = CreateItem("item_dimensional_doorway", nil, nil)
				hNewItem:SetPurchaseTime(0)
				hNewItem:SetCurrentCharges(1)
				hNewItem:SetSellable(false)
				local drop = CreateItemOnPositionSync(self.vPos, hNewItem)
				hNewItem:LaunchLoot(false, 150, 0.5, self.vPos, nil)
			elseif nRandomSeed <= 85 then
				local hNewItem = CreateItem("item_spellbook_normal", nil, nil)
				hNewItem:SetPurchaseTime(0)
				hNewItem:SetCurrentCharges(1)
				hNewItem:SetSellable(false)
				local drop = CreateItemOnPositionSync(self.vPos, hNewItem)
				hNewItem:LaunchLoot(false, 150, 0.5, self.vPos, nil)
			elseif nRandomSeed <= 96 then
				local hNewItem = CreateItem("item_spellbook_ultimate", nil, nil)
				hNewItem:SetPurchaseTime(0)
				hNewItem:SetCurrentCharges(1)
				hNewItem:SetSellable(false)
				local drop = CreateItemOnPositionSync(self.vPos, hNewItem)
				hNewItem:LaunchLoot(false, 150, 0.5, self.vPos, nil)
			elseif nRandomSeed <= 98 then
				local hNewItem = CreateItem("item_spellbook_normal_courier", nil, nil)
				hNewItem:SetPurchaseTime(0)
				hNewItem:SetCurrentCharges(1)
				hNewItem:SetSellable(false)
				local drop = CreateItemOnPositionSync(self.vPos, hNewItem)
				hNewItem:LaunchLoot(false, 150, 0.5, self.vPos, nil)
			elseif nRandomSeed <= 100 then
				local hNewItem = CreateItem("item_spellbook_ultimate_courier", nil, nil)
				hNewItem:SetPurchaseTime(0)
				hNewItem:SetCurrentCharges(1)
				hNewItem:SetSellable(false)
				local drop = CreateItemOnPositionSync(self.vPos, hNewItem)
				hNewItem:LaunchLoot(false, 150, 0.5, self.vPos, nil)
			end
			
			local nFXIndex2 = ParticleManager:CreateParticle( "particles/econ/events/ti9/shovel_dig_streak.vpcf", PATTACH_WORLDORIGIN, nil )
			ParticleManager:SetParticleControl(nFXIndex2, 0, self.vPos)
			ParticleManager:ReleaseParticleIndex(nFXIndex2)
		end
	end
end

--------------------------------------------------------------------------------





--------------------------------------------------------------------------------

modifier_item_poshovel_thinker = class({})
function modifier_item_poshovel_thinker:IsHidden() return true end
function modifier_item_poshovel_thinker:IsPurgable() return false end
--------------------------------------------------------------------------------
function modifier_item_poshovel_thinker:OnCreated( kv )
	if IsServer() then
		local nFXIndex2 = ParticleManager:CreateParticle( "particles/econ/events/ti9/shovel_dig.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex2, 0, self:GetParent():GetAbsOrigin() )
		
		self:AddParticle(nFXIndex2, true, false, -1, false, false)
	end
end
--------------------------------------------------------------------------------





--------------------------------------------------------------------------------

modifier_item_poshovel = class({})
function modifier_item_poshovel:IsHidden()		return true		end
function modifier_item_poshovel:IsPurgable()	return false	end

--------------------------------------------------------------------------------

function modifier_item_poshovel:OnCreated( kv )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
end

--------------------------------------------------------------------------------

function modifier_item_poshovel:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

----------------------------------------

function modifier_item_poshovel:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

----------------------------------------

function modifier_item_poshovel:GetModifierHealthBonus()
	return self.bonus_health
end
