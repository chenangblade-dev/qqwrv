utilsBonus = {}

local auto_use_items = {
    "item_coin",
}

-- 掉落物品
function utilsBonus.DropLootItem(itemname, position, radius, radius_max)
    radius = radius or 0
    if radius_max == nil then
        radius_max = radius
        radius = 0
    end

    local newItem = CreateItem(itemname, nil, nil)

    if not newItem then 
        print("ERROR: FAILED TO CREATE ITEM!!!!!")
        return 
    end

    newItem:SetPurchaseTime(0)
    local drop       = CreateItemOnPositionSync(position, newItem)
    local dropTargetPosition = position + RandomVector(RandomFloat(radius, radius_max))

    local maxTries = 0
    while not GridNav:CanFindPath(position, dropTargetPosition) do
        dropTargetPosition = position + RandomVector(RandomFloat(radius, radius_max))
        maxTries = maxTries + 1
        if maxTries > 10 then break end
    end

    -- 储存掉落位置
    dropTargetPosition = GetGroundPosition(dropTargetPosition, drop)
    drop.dropPosition = dropTargetPosition

    local autouse    = false

    -- 各种自动拾取的东西（就是不需要选择，都可以捡起来的，不会有任何坏处的）
    if table.contains(auto_use_items, itemname) then
        autouse = true
    end

    local height, time = 200, 0.5
    newItem:LaunchLoot(autouse, height, time, dropTargetPosition,nil)

    -- -- 显示特效
    -- if not drop.itemDropPcf then
    --     if table.contains(GameRules.RandomDropAbilityScrolls, itemname) then
    --         drop.itemDropPcf = ParticleManager:CreateParticle('particles/items/'..itemname..'.vpcf', PATTACH_ABSORIGIN, drop)
    --         ParticleManager:SetParticleControl(drop.itemDropPcf, 0, dropTargetPosition)
    --         GameRules.DroppedItemPCFs[drop:GetEntityIndex()] = {id = drop.itemDropPcf, found = true}
    --     end
    --     if itemname == "item_spellbook_normal" then
    --         -- 掉落特效
    --         local pcf = ParticleManager:CreateParticle('particles/items/item_spellbook_drop.vpcf', PATTACH_WORLDORIGIN, drop)
    --         ParticleManager:SetParticleControl(pcf, 0, dropTargetPosition)
    --         ParticleManager:ReleaseParticleIndex(pcf)
    --         -- 光环特效
    --         drop.itemDropPcf = ParticleManager:CreateParticle('particles/items/item_ground/spellbook_normal.vpcf', PATTACH_ABSORIGIN, drop)
    --         ParticleManager:SetParticleControl(drop.itemDropPcf, 0, dropTargetPosition)
    --         GameRules.DroppedItemPCFs[drop:GetEntityIndex()] = {id = drop.itemDropPcf, found = true}
    --     end
    --     if itemname == "item_spellbook_ultimate" then
    --         -- 掉落特效
    --         local pcf = ParticleManager:CreateParticle('particles/items/item_spellbook_drop_ultimate.vpcf', PATTACH_WORLDORIGIN, drop)
    --         ParticleManager:SetParticleControl(pcf, 0, dropTargetPosition)
    --         ParticleManager:ReleaseParticleIndex(pcf)
    --         -- 光环特效
    --         drop.itemDropPcf = ParticleManager:CreateParticle('particles/items/item_ground/spellbook_ultimate.vpcf', PATTACH_ABSORIGIN, drop)
    --         ParticleManager:SetParticleControl(drop.itemDropPcf, 0, dropTargetPosition)
    --         GameRules.DroppedItemPCFs[drop:GetEntityIndex()] = {id = drop.itemDropPcf, found = true}
    --     end

    --     if itemname == "item_spellbook_ultimate_courier" or itemname == "item_spellbook_normal_courier" then
    --         drop.itemDropPcf = ParticleManager:CreateParticle('particles/items/item_ground/spellbook_ultimate_courier.vpcf', PATTACH_ABSORIGIN, drop)
    --         ParticleManager:SetParticleControl(drop.itemDropPcf, 0, dropTargetPosition)
    --         GameRules.DroppedItemPCFs[drop:GetEntityIndex()] = {id = drop.itemDropPcf, found = true}
    --     end
    -- end

    return newItem, drop
end