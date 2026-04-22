-- 奥术天球
modifier_npc_dota_hero_enigma_1 = class({})
function modifier_npc_dota_hero_enigma_1:IsDebuff()			return false end
function modifier_npc_dota_hero_enigma_1:IsHidden() 		return true end
function modifier_npc_dota_hero_enigma_1:IsPurgable() 		return false end
function modifier_npc_dota_hero_enigma_1:IsPurgeException() return false end
function modifier_npc_dota_hero_enigma_1:IsPermanent() 		return true end
function modifier_npc_dota_hero_enigma_1:RemoveOnDeath()    return false end
function modifier_npc_dota_hero_enigma_1:OnPlayerLearnedAbility(event)
    if IsServer() then
        if event.PlayerID == self:GetParent():GetPlayerOwnerID() then
            self:ForceRefresh()
        end
    end
end
function modifier_npc_dota_hero_enigma_1:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}
	return funcs
end
function modifier_npc_dota_hero_enigma_1:GetModifierOverrideAbilitySpecial( params )
	local talent = self:GetParent():FindAbilityByName("special_bonus_unique_enigma_4")

	if self:GetParent() == nil or params.ability == nil or not talent or talent:GetLevel() < 1 then
		return 0
	end
	local szAbilityName = params.ability:GetAbilityName()
	local szSpecialValueName = params.ability_special_value
	if szAbilityName ~= "enigma_black_hole" then
		return 0
	end	 
    if szSpecialValueName == "AbilityCooldown" then		
		return 1
	end 
    if szSpecialValueName == "radius" then		
		return 1
	end   
	return 0
end

function modifier_npc_dota_hero_enigma_1:GetModifierOverrideAbilitySpecialValue( params )
	local szAbilityName = params.ability:GetAbilityName()
	if szAbilityName ~= "enigma_black_hole"  then
		return 0
	end
	local szSpecialValueName = params.ability_special_value
    if szSpecialValueName == "AbilityCooldown" then
		return 60
	end  	
	if szSpecialValueName == "radius" then
		return 520
	end 
	return 0	
end
