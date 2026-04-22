LinkLuaModifier("modifier_diretide_candy", "abilities/events/item_diretide_candy.lua", LUA_MODIFIER_MOTION_NONE)

item_diretide_candy = class({})

function item_diretide_candy:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local modifier_candy = caster:FindModifierByName("modifier_diretide_candy")

		local info = {
			Target = target,
			Source = caster,
			Ability = self,
			EffectName = "particles/events/candy_projectile.vpcf",
			bDodgeable = false,
			bProvidesVision = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			iMoveSpeed = 1000,
			iVisionRadius = 0,
			iVisionTeamNumber = caster:GetTeamNumber(),
--			ExtraData = {special_cast = special_cast}
		}
		ProjectileManager:CreateTrackingProjectile( info )

		EmitSoundOn('Brewmaster_Earth.Boulder.Cast', caster)
	end
end

function item_diretide_candy:OnProjectileHit(hTarget, vLocation)
	if IsServer() then
		local charges = self:GetCurrentCharges()
		if charges >= 1 then

			if hTarget:IsRealHero() then
				hTarget:AddItemByName('item_diretide_candy')
				return
			end
			if hTarget:GetUnitName() == "npc_diretide_bucket" then
				-- 掉一本无限制技能书在地上
				-- if RollPercentage(50) then
					hTarget:ForcePlayActivityOnce(ACT_DOTA_ATTACK)

					local position = hTarget:GetAbsOrigin()
					local book = CreateItem('item_spellbook_unlimited', nil, nil)
	    			book:SetPurchaseTime(0)
				    local drop       = CreateItemOnPositionSync(position, book)
				    local caster = self:GetCaster()
				    local dropTarget = caster:GetOrigin() + RandomVector(100)
	    			book:LaunchLoot(false, 150, 0.5, dropTarget)
				-- end
			end

			self:SetCurrentCharges(self:GetCurrentCharges()-1)
			if self:GetCurrentCharges() <= 0 then self:RemoveSelf() end
		end
	end
end

function item_diretide_candy:CastFilterResultTarget(hTarget)
	if IsServer() then
		if hTarget:IsHero() and hTarget ~= self:GetCaster() then
			return UF_SUCCESS
		end
		if hTarget:GetUnitName() == 'npc_diretide_bucket' then
			return UF_SUCCESS
		end
		return UF_FAIL_CUSTOM
	end
end

function item_diretide_candy:GetCustomCastErrorTarget(hTarget)
	if IsServer() then
		if hTarget:IsHero() and hTarget ~= self:GetCaster() then
			return UF_SUCCESS
		end
		if hTarget:GetUnitName() == 'npc_diretide_bucket' then
			return UF_SUCCESS
		end
		return 'hud_error_not_a_valid_target'
	end
end

function item_diretide_candy:GetIntrinsicModifierName()
	return "modifier_diretide_candy"
end

modifier_diretide_candy = class({})

function modifier_diretide_candy:GetTexture()
	return "general/diretide_candy"
end

function modifier_diretide_candy:OnCreated()
	if IsServer() then
		self.ability = self:GetAbility()    
		self.hp_loss_pct = self.ability:GetSpecialValueFor("hp_loss_pct")
		self:StartIntervalThink(0.1)
	end
end

function modifier_diretide_candy:OnIntervalThink()
	if IsServer() then
		if self.ability then
			local charges = self.ability:GetCurrentCharges()
			self:SetStackCount(charges)
		end

		local owner = self:GetParent()

		owner:CalculateStatBonus()

		if not owner.OverHeadJingu then 
			owner.OverHeadJingu = ParticleManager:CreateParticle("particles/events/candy_carrying_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, owner)
			ParticleManager:SetParticleControl(owner.OverHeadJingu, 0, owner:GetAbsOrigin())
		end
		if self:GetStackCount() < 10 then
			ParticleManager:SetParticleControl(owner.OverHeadJingu, 2, Vector(0, self:GetStackCount(), 0))
		elseif self:GetStackCount() >= 10 and self:GetStackCount() < 20 then
			ParticleManager:SetParticleControl(owner.OverHeadJingu, 2, Vector(1, self:GetStackCount()-10, 0))
		elseif self:GetStackCount() >= 20 and self:GetStackCount() < 30 then
			ParticleManager:SetParticleControl(owner.OverHeadJingu, 2, Vector(2, self:GetStackCount()-20, 0))
		end
	end
end

function modifier_diretide_candy:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}

	return decFuncs
end

function modifier_diretide_candy:GetModifierExtraHealthPercentage()
	if IsServer() then
		local hp_to_reduce = self.hp_loss_pct / 100 * self:GetStackCount() * (-1)
		if hp_to_reduce < -0.99 then
			return -0.99
		end

		return hp_to_reduce
	end
end

function modifier_diretide_candy:OnDestroy()
	local owner = self:GetParent()
	if owner.OverHeadJingu then
		ParticleManager:DestroyParticle(owner.OverHeadJingu, false)
		ParticleManager:ReleaseParticleIndex(owner.OverHeadJingu)
		owner.OverHeadJingu = nil
	end
end