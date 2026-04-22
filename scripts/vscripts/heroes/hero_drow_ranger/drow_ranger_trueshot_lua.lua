drow_ranger_trueshot_lua=class({})
LinkLuaModifier("modifier_drow_ranger_trueshot_lua", "heroes/hero_drow_ranger/drow_ranger_trueshot_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_trueshot_passive", "heroes/hero_drow_ranger/drow_ranger_trueshot_lua.lua", LUA_MODIFIER_MOTION_NONE)

function drow_ranger_trueshot_lua:GetIntrinsicModifierName()
    return "modifier_drow_ranger_trueshot_lua"
end

modifier_drow_ranger_trueshot_lua=class({})

function modifier_drow_ranger_trueshot_lua:IsPassive()
    return true
end
function modifier_drow_ranger_trueshot_lua:IsHidden()
    return true
end

function modifier_drow_ranger_trueshot_lua:IsPurgable()
    return false
end

function modifier_drow_ranger_trueshot_lua:IsPurgeException()
    return false
end

function modifier_drow_ranger_trueshot_lua:AllowIllusionDuplicate()
    return false
end
function modifier_drow_ranger_trueshot_lua:IsAura() return true end
function modifier_drow_ranger_trueshot_lua:GetModifierAura() return "modifier_drow_ranger_trueshot_passive" end
function modifier_drow_ranger_trueshot_lua:GetAuraRadius() return 25000 end
function modifier_drow_ranger_trueshot_lua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_RANGED_ONLY end
function modifier_drow_ranger_trueshot_lua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_drow_ranger_trueshot_lua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

function modifier_drow_ranger_trueshot_lua:OnCreated()
    if self:GetAbility() == nil then
		return
    end
end

modifier_drow_ranger_trueshot_passive=class({})

function modifier_drow_ranger_trueshot_passive:OnCreated() end

function modifier_drow_ranger_trueshot_passive:DeclareFunctions()
    return
    {
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_drow_ranger_trueshot_passive:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("trueshot_speed") * self:GetCaster():GetAgility() / 100
end

