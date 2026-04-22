modifier_npc_dota_hero_night_stalker_1 = class({})
--[[function modifier_npc_dota_hero_night_stalker_1:IsDebuff()			return false end
function modifier_npc_dota_hero_night_stalker_1:IsHidden() 		return true end
function modifier_npc_dota_hero_night_stalker_1:IsPurgable() 		return false end
function modifier_npc_dota_hero_night_stalker_1:IsPurgeException() return false end
function modifier_npc_dota_hero_night_stalker_1:IsPermanent() 		return true end
function modifier_npc_dota_hero_night_stalker_1:RemoveOnDeath()    return false end  
function modifier_npc_dota_hero_night_stalker_1:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
	return funcs
end

function modifier_npc_dota_hero_night_stalker_1:GetModifierIgnoreMovespeedLimit() 
	local parent=self:GetParent()
    if  parent:HasModifier("modifier_item_aghanims_shard") and  parent:HasModifier("modifier_night_stalker_darkness") then
        return 1
    end
end

function modifier_npc_dota_hero_night_stalker_1:OnPlayerLearnedAbility(event)
    if IsServer() then
        if event.PlayerID == self:GetParent():GetPlayerOwnerID() then
            self:ForceRefresh()
        end
    end
end

function modifier_npc_dota_hero_night_stalker_1:GetModifierPreAttack_BonusDamage()
	local parent=self:GetParent()
    if parent:HasModifier("modifier_night_stalker_darkness") and parent:HasModifier("modifier_item_aghanims_shard") then
        return parent:GetMoveSpeedModifier(parent:GetBaseMoveSpeed(), true)+185
    end
end
]]--
function modifier_npc_dota_hero_night_stalker_1:IsDebuff()          return false end
function modifier_npc_dota_hero_night_stalker_1:IsHidden()      return true end
function modifier_npc_dota_hero_night_stalker_1:IsPurgable()        return false end
function modifier_npc_dota_hero_night_stalker_1:IsPurgeException() return false end
function modifier_npc_dota_hero_night_stalker_1:IsPermanent()       return true end
function modifier_npc_dota_hero_night_stalker_1:RemoveOnDeath()    return false end  
function modifier_npc_dota_hero_night_stalker_1:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_HEROFACET_OVERRIDE ,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_npc_dota_hero_night_stalker_1:GetModifierHeroFacetOverride() 
    return 2
end

function modifier_npc_dota_hero_night_stalker_1:GetModifierBonusStats_Agility()
    return 666
end
