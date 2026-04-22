LinkLuaModifier('modifier_baoji_critical_strike', 'abilities/items/modifiers/modifier_baoji_critical_strike.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_baoji_passive', 'abilities/items/modifiers/modifier_baoji_passive.lua', LUA_MODIFIER_MOTION_NONE)

baoji = class({})

function baoji:GetIntrinsicModifierName()
	return 'modifier_baoji_passive'
end

function baoji:OnUpgrade()
	local hero = self:GetCaster()
	local ability = self
	local ability_name = self:GetAbilityName()

	if ability:GetLevel() <= 1 then
		return
	end

	if not hero:IsRealHero() then return end

	local hero_level = hero:GetLevel()
	local ability_level = ability:GetLevel()
	
	if ability_level > hero_level then
		Notifications:Bottom(PlayerResource:GetPlayer(hero:GetPlayerID()),{text="#ability_cant_bigger_than_hero_level", duration=1, style={color="red", ["font-size"]="40px", border="0px"}})
		hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
		ability:SetLevel(ability:GetLevel() - 1)
	end
end
