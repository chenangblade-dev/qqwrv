local m = class({})

function m:IsPurgable()
	return false
end

function m:RemoveOnDeath()
	return false
end

function m:DeclareFunctions() 
	return MODIFIER_PROPERTY_VISUAL_Z_DELTA
end

function m:GetVisualZDelta()
	return -90
end

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function m:OnCreated(kv)
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)

		self:GetParent():ForcePlayActivityOnce(ACT_DOTA_IDLE_RARE)
	end
end	

function m:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}
end

local function transferItem(unit, item)
	local containedItem = item:GetContainedItem()
	local itemName = containedItem:GetAbilityName()

	if not itemName then return end
	local hero = unit.__Owner
	if not hero then return end
	local charges = containedItem:GetCurrentCharges()
	
	local function addItemToInventory()
		if hero:HasItemInInventory(itemName) then
			local inventoryItem = hero:FindItemInInventory(itemName)
			inventoryItem:SetCurrentCharges(inventoryItem:GetCurrentCharges() + charges)
		else
			local instash = false
			for i = 0, 20 do
				local stashItem = hero:GetItemInSlot(i)
				if stashItem and stashItem:GetAbilityName() == itemName then
					stashItem:SetCurrentCharges(stashItem:GetCurrentCharges() + charges)
					instash = true
					break
				end
			end
			if not instash then
				hero:AddItemByName(itemName)
				local addeditem = hero:FindItemInInventory(itemName)
				if addeditem then
					addeditem:SetCurrentCharges(charges)
				end
			end
		end
	end

	if table.contains(GameRules.RandomDropAbilityScrolls, itemName) then
		local abilityName = string.sub(itemName, 6)
		local ability = hero:FindAbilityByName(abilityName)
		if ability and ability:GetLevel() < ability:GetMaxLevel() and ability:GetLevel() < hero:GetLevel() then
			ability:UpgradeAbility(false)
		else
			addItemToInventory()
		end
	else
		addItemToInventory()
	end

	-- 移除物品，确保传送和移除同时执行？
	-- UTIL_Remove(item)
	item:RemoveSelf()

	local info = {
		Target = hero,
		Source = unit,
		Ability = unit:FindAbilityByName("empty_1"),
		EffectName = "particles/events/candy_projectile.vpcf",
		bDodgeable = false,
		bProvidesVision = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		iMoveSpeed = 1000,
		iVisionRadius = 0,
		iVisionTeamNumber = hero:GetTeamNumber(),
	}
	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn('Brewmaster_Earth.Boulder.Cast', unit)
end

function m:OnIntervalThink()
	if IsServer() then
		if self.Owner == nil then self.Owner = self:GetParent() end
		if self.Hero == nil then self.Hero = self:GetCaster() end
		if not IsValidAlive(self.Hero) then
			return
		end

		if (self.Owner:GetOrigin() - self.Hero:GetOrigin()):Length2D() > 1300 then
			ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf", PATTACH_ABSORIGIN, self.Owner))
			FindClearSpaceForUnit(self.Owner, self.Hero:GetOrigin() + RandomVector(200), false)
			self.Owner:SetForwardVector(self.Hero:GetForwardVector())
			self.Owner:Stop()
			ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/blink_dagger_end_fm06.vpcf", PATTACH_ABSORIGIN, self.Owner))
		end

		local items = Entities:FindAllByClassname("dota_item_drop")
		local nearbyItems = {}
		for _, item in pairs(items) do
			if self.Hero:CanEntityBeSeenByMyTeam(item) then
				local itemName = item:GetContainedItem():GetAbilityName()

				if itemName == "item_spellbook_normal" or itemName == "item_spellbook_ultimate" then
					nearbyItems[item] = true
				end
				if table.contains(GameRules.RandomDropAbilityScrolls, itemName) then
					if self.Hero:HasItemInInventory(itemName) then
						nearbyItems[item] = true
					else
						local abilityName = string.sub(itemName, 6)
						if self.Hero:HasAbility(abilityName) then
							local ab = self.Hero:FindAbilityByName(abilityName)
							if ab:GetLevel() < ab:GetMaxLevel() then
								nearbyItems[item] = true
							end
						end
					end
				end
			end
		end

		-- 没有想要的物品，那么就随便走走
		if table.count(nearbyItems) <= 0 then
			if (self.Owner:GetOrigin() - self.Hero:GetOrigin()):Length2D() > 500 or RollPercentage(10) then
				local targetPosition = self.Hero:GetOrigin() + RandomVector(200)
				if GridNav:CanFindPath(self.Owner:GetOrigin(), targetPosition) then
					self.Owner:MoveToPosition(targetPosition)
				end
			end
		else
			-- 不然就去拾取物品
			-- 选择最近的
			local distance = 1500
			local targetItem
			for item in pairs(nearbyItems) do
				local pos = item:GetOrigin()
				local d = (pos - self.Owner:GetOrigin()):Length2D()
				if d < distance then
					distance = d
					targetItem = item
				end
			end
			if (targetItem ~= nil) then
				local distance = (targetItem:GetOrigin() - self.Owner:GetOrigin()):Length2D()
				if (distance < 128) then
					transferItem(self.Owner, targetItem)
				else
					self.Owner:MoveToPosition(targetItem:GetOrigin())
				end
			end
		end
	end
		
end


modifier_bom_courier = m