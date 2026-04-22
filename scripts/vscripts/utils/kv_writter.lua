if io == nil then return end

local abilities = LoadKeyValues('scripts/npc/npc_abilities.txt')
local file = io.open('../../../content/dota_addons/da/panorama/scripts/custom_game/npc/npc_abilities.js', 'w')
abilities = JSON:encode(abilities)

file:write("var npc_abilities_kv = ")
file:write("'" .. abilities .. "'")
file:write('\n')
file:write('GameUI.NpcAbilitiesKV = JSON.parse(npc_abilities_kv)')
file:flush()
file:close()

print("write kv finished")