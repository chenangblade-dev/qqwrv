modifier_bom_truesight = class({})

function modifier_bom_truesight:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_bom_truesight:GetModifierAura()  return "modifier_truesight" end
----------------------------------------------------------------------------------------------------------
function modifier_bom_truesight:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_bom_truesight:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_bom_truesight:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

function modifier_bom_truesight:GetAuraRadius() 
	return 800 
end

function modifier_bom_truesight:GetTexture() return 'modifiers/truesight' end

function modifier_bom_truesight:OnCreated(params) 
end

function modifier_bom_truesight:IsHidden() return false end