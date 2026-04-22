if modifier_hero_attradd == nil then
    modifier_hero_attradd = class({})
end
LinkLuaModifier("modifier_item_brooch", "scripts/vscripts/modifiers/modifier_hero_attradd", LUA_MODIFIER_MOTION_NONE)
function modifier_hero_attradd:IsDebuff()
    return false
end

function modifier_hero_attradd:IsPurgable()
    return false
end

function modifier_hero_attradd:IsHidden()
    return true
end

function modifier_hero_attradd:RemoveOnDeath()
    return false
end

function modifier_hero_attradd:AllowIllusionDuplicate()
    return false
end
function modifier_hero_attradd:OnCreated(keys)
    if not IsServer() then return end
    --设置定时器
    self:StartIntervalThink(1)
end

function modifier_hero_attradd:OnDestroy()
    if not IsServer() then return end
end

function modifier_hero_attradd:DeclareFunctions()

end
function modifier_hero_attradd:OnIntervalThink()
    if not IsServer() then return end
    local hero=self:GetCaster()
    --遍历英雄物品栏
    self.xzflag=false
    hero:AddNewModifier(hero, self, "modifier_item_brooch", nil)
    for i=0,5 do
        local iteminfo=hero:GetItemInSlot(i)
        if iteminfo~=nil then
            local name=iteminfo:GetAbilityName()
            --如果拥有胸针，则需要加modifier
            if name=="item_revenants_brooch" then
                self.xzflag=true
            end
        end
    end
    --判断是否需要添加，不需要添加时把之前添加过的BUFF移除了
    if self.xzflag then
        --如果之前就有该modifier，则跳过,没有则添加

        if hero:HasModifier("modifier_item_brooch") and hero:IsRangedAttacker() then
            else
                --如果单位活着，则直接添加
                if hero:IsAlive() then
                    hero:AddNewModifier(hero, self, "modifier_item_brooch", nil)
                    --如果单位死亡了，则先复活在添加
                    else
                        hero:SetHealth(1)
                        hero:AddNewModifier(hero, self, "modifier_item_brooch", nil)
                        hero:SetHealth(0)
                end
        end
        --不需要添加，则把之前的BUFF给删了!
        else
            if hero:HasModifier("modifier_item_brooch") then
                hero:RemoveModifierByName("modifier_item_brooch")
            end
    end
end

--胸针的BUFF！
if modifier_item_brooch == nil then
    modifier_item_brooch = class({})
end

function modifier_item_brooch:IsDebuff()
    return false
end

function modifier_item_brooch:IsPurgable()
    return false
end

function modifier_item_brooch:IsHidden()
    return true
end

function modifier_item_brooch:RemoveOnDeath()
    return false
end

function modifier_item_brooch:AllowIllusionDuplicate()
    return false
end
--胸针加射程
function modifier_item_brooch:OnCreated(keys)
    if not IsServer() then return end
end

function modifier_item_brooch:OnDestroy()
    if not IsServer() then return end
end
--声明官方函数
function modifier_item_brooch:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

--增加攻击距离
function modifier_item_brooch:GetModifierAttackRangeBonus()
    return 150
end