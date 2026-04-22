-- 用来将天赋数据写到panorama的js中去
-- if io == nil then return end
-- do return end -- 暫時不要重複寫

-- 读取所有英雄的数据
local heroes = LoadKeyValues('scripts/npc/herolist.txt')
local hero_data = LoadKeyValues('scripts/npc/npc_heroes.txt')
local ability_data = LoadKeyValues('scripts/npc/npc_abilities.txt')
local hero_abilities_list = {
    "npc_dota_hero_abaddon.txt",
    "npc_dota_hero_abyssal_underlord.txt",
    "npc_dota_hero_alchemist.txt",
    "npc_dota_hero_ancient_apparition.txt",
    "npc_dota_hero_antimage.txt",
    "npc_dota_hero_arc_warden.txt",
    "npc_dota_hero_axe.txt",
    "npc_dota_hero_bane.txt",
    "npc_dota_hero_batrider.txt",
    "npc_dota_hero_beastmaster.txt",
    "npc_dota_hero_bloodseeker.txt",
    "npc_dota_hero_bounty_hunter.txt",
    "npc_dota_hero_brewmaster.txt",
    "npc_dota_hero_bristleback.txt",
    "npc_dota_hero_broodmother.txt",
    "npc_dota_hero_centaur.txt",
    "npc_dota_hero_chaos_knight.txt",
    "npc_dota_hero_chen.txt",
    "npc_dota_hero_clinkz.txt",
    "npc_dota_hero_crystal_maiden.txt",
    "npc_dota_hero_dark_seer.txt",
    "npc_dota_hero_dark_willow.txt",
    "npc_dota_hero_dawnbreaker.txt",
    "npc_dota_hero_dazzle.txt",
    "npc_dota_hero_death_prophet.txt",
    "npc_dota_hero_disruptor.txt",
    "npc_dota_hero_doom_bringer.txt",
    "npc_dota_hero_dragon_knight.txt",
    "npc_dota_hero_drow_ranger.txt",
    "npc_dota_hero_earthshaker.txt",
    "npc_dota_hero_earth_spirit.txt",
    "npc_dota_hero_elder_titan.txt",
    "npc_dota_hero_ember_spirit.txt",
    "npc_dota_hero_enchantress.txt",
    "npc_dota_hero_enigma.txt",
    "npc_dota_hero_faceless_void.txt",
    "npc_dota_hero_furion.txt",
    "npc_dota_hero_grimstroke.txt",
    "npc_dota_hero_gyrocopter.txt",
    "npc_dota_hero_hoodwink.txt",
    "npc_dota_hero_huskar.txt",
    "npc_dota_hero_invoker.txt",
    "npc_dota_hero_jakiro.txt",
    "npc_dota_hero_juggernaut.txt",
    "npc_dota_hero_keeper_of_the_light.txt",
    "npc_dota_hero_kunkka.txt",
    "npc_dota_hero_legion_commander.txt",
    "npc_dota_hero_leshrac.txt",
    "npc_dota_hero_lich.txt",
    "npc_dota_hero_life_stealer.txt",
    "npc_dota_hero_lina.txt",
    "npc_dota_hero_lion.txt",
    "npc_dota_hero_lone_druid.txt",
    "npc_dota_hero_luna.txt",
    "npc_dota_hero_lycan.txt",
    "npc_dota_hero_magnataur.txt",
    "npc_dota_hero_marci.txt",
    "npc_dota_hero_mars.txt",
    "npc_dota_hero_medusa.txt",
    "npc_dota_hero_meepo.txt",
    "npc_dota_hero_mirana.txt",
    "npc_dota_hero_monkey_king.txt",
    "npc_dota_hero_morphling.txt",
    "npc_dota_hero_muerta.txt",
    "npc_dota_hero_naga_siren.txt",
    "npc_dota_hero_necrolyte.txt",
    "npc_dota_hero_nevermore.txt",
    "npc_dota_hero_night_stalker.txt",
    "npc_dota_hero_nyx_assassin.txt",
    "npc_dota_hero_obsidian_destroyer.txt",
    "npc_dota_hero_ogre_magi.txt",
    "npc_dota_hero_omniknight.txt",
    "npc_dota_hero_oracle.txt",
    "npc_dota_hero_pangolier.txt",
    "npc_dota_hero_phantom_assassin.txt",
    "npc_dota_hero_phantom_lancer.txt",
    "npc_dota_hero_phoenix.txt",
    "npc_dota_hero_primal_beast.txt",
    "npc_dota_hero_puck.txt",
    "npc_dota_hero_pudge.txt",
    "npc_dota_hero_pugna.txt",
    "npc_dota_hero_queenofpain.txt",
    "npc_dota_hero_rattletrap.txt",
    "npc_dota_hero_razor.txt",
    "npc_dota_hero_riki.txt",
    "npc_dota_hero_rubick.txt",
    "npc_dota_hero_sand_king.txt",
    "npc_dota_hero_shadow_demon.txt",
    "npc_dota_hero_shadow_shaman.txt",
    "npc_dota_hero_shredder.txt",
    "npc_dota_hero_silencer.txt",
    "npc_dota_hero_skeleton_king.txt",
    "npc_dota_hero_skywrath_mage.txt",
    "npc_dota_hero_slardar.txt",
    "npc_dota_hero_slark.txt",
    "npc_dota_hero_snapfire.txt",
    "npc_dota_hero_sniper.txt",
    "npc_dota_hero_spectre.txt",
    "npc_dota_hero_spirit_breaker.txt",
    "npc_dota_hero_storm_spirit.txt",
    "npc_dota_hero_sven.txt",
    "npc_dota_hero_target_dummy.txt",
    "npc_dota_hero_techies.txt",
    "npc_dota_hero_templar_assassin.txt",
    "npc_dota_hero_terrorblade.txt",
    "npc_dota_hero_tidehunter.txt",
    "npc_dota_hero_tinker.txt",
    "npc_dota_hero_tiny.txt",
    "npc_dota_hero_treant.txt",
    "npc_dota_hero_troll_warlord.txt",
    "npc_dota_hero_tusk.txt",
    "npc_dota_hero_undying.txt",
    "npc_dota_hero_ursa.txt",
    "npc_dota_hero_vengefulspirit.txt",
    "npc_dota_hero_venomancer.txt",
    "npc_dota_hero_viper.txt",
    "npc_dota_hero_visage.txt",
    "npc_dota_hero_void_spirit.txt",
    "npc_dota_hero_warlock.txt",
    "npc_dota_hero_weaver.txt",
    "npc_dota_hero_windrunner.txt",
    "npc_dota_hero_winter_wyvern.txt",
    "npc_dota_hero_wisp.txt",
    "npc_dota_hero_witch_doctor.txt",
    "npc_dota_hero_zuus.txt",
     "npc_dota_hero_kez.txt",
}

for _, hero_script in pairs(hero_abilities_list) do
    pcall(function()
        local single_hero_data = LoadKeyValues("scripts/npc/heroes/" .. hero_script)
        for ability_name, hero_ability_data in pairs(single_hero_data) do
            ability_data[ability_name] = hero_ability_data
        end
    end)
end
local hero_talent_data = {}

local hero_attribute_data = {}

local hero_talent_special_value_data = {}

for heroName in pairs(heroes) do
	local data = hero_data[heroName]

	local talents = {}
	for i = 1, 24 do
		local ability = data['Ability' .. i]
		if ability and string.find(ability, 'special_bonus_') then
			table.insert(talents, ability)

			-- 将special value 写入
			if ability_data[ability] and ability_data[ability].AbilitySpecial and ability_data[ability].AbilitySpecial['01'] then
				for k, v in pairs(ability_data[ability].AbilitySpecial['01']) do
					if k ~= "var_type" then
						hero_talent_special_value_data[ability] = {name = k, data = v}
						if ability == 'special_bonus_spell_block_15' then
							print(k, v)
						end
					end
				end

			end
		end
		if ability and ability_data[ability] and ability_data[ability].AbilityValues ~= nil then
            -- "damage"
            -- {
            -- 	"value"						"75 150 225 300"
            -- 	"special_bonus_unique_muerta_dead_shot_damage"	"+100"
            -- }
            for k, v in pairs(ability_data[ability].AbilityValues) do
                if type(v) == 'table' then
                    for kk, vv in pairs(v) do
                        if string.find(kk, 'special_bonus_') then
                            hero_talent_special_value_data[kk] = {
                                name = k,
                                data = vv
                            }
                        end
                    end
                end
            end
        end
	end

	table.insert(hero_talent_data, {hero = heroName, talents = talents})

	table.insert(hero_attribute_data, {hero = heroName, attribute = data.AttributePrimary})
end

print('GameUI.vTalentData = {')

for _, data in pairs(hero_talent_data) do
	local str = '"' .. data.hero .. '":{'
	for index, talent in pairs(data.talents) do
		str = str .. index ..  ':"' .. talent .. '",'
	end
	str = str .. '},'
	print(str)
end

print('}')




do return end

local file = io.open('../../../content/dota_addons/da/panorama/scripts/custom_game/talents.js', 'w')
file:write('GameUI.vTalentData = {\n')

for _, data in pairs(hero_talent_data) do
	local str = '"' .. data.hero .. '":{'
	for index, talent in pairs(data.talents) do
		str = str .. index ..  ':"' .. talent .. '",'
	end
	-- str = string.sub(str, 1, string.len(str) - 1)
	str = str .. '},\n'
	file:write(str)
end

file:write('}\n')

file:write('GameUI.vTalentValueData = {\n')
print('GameUI.vTalentValueData = {')
for k, data in pairs(hero_talent_special_value_data) do
	local str = '\t"' .. k  .. '":{  "' .. data.name  .. '":"' .. data.data .. '"  },\n'
	file:write(str)
	print(str)
end
print('}')
file:write('}')

file:flush()
file:close()

local file = io.open('../../../content/dota_addons/da/panorama/scripts/custom_game/attributes.js', 'w')
file:write('GameUI.vAttributeData = {\n')

for _, data in pairs(hero_attribute_data) do
	local str = '"' .. data.hero .. '":'
	-- str = string.sub(str, 1, string.len(str) - 1)
	str = str .. '"'.. data.attribute .. '",\n'
	file:write(str)
end

file:write('}')
file:flush()
file:close()