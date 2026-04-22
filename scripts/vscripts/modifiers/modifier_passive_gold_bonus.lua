local m = class({})

function m:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function m:OnIntervalThink()
	if IsServer() then
		local hero = self:GetParent()
		local state = GameRules:State_Get()
		if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			hero:ModifyGold(2, true, DOTA_ModifyGold_Unspecified)
		end
	end
end

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function m:IsPurgable()
	return false
end

function m:IsHidden()
	return true
end

function m:RemoveOnDeath()
	return false
end

modifier_passive_gold_bonus = m