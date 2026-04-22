if ability_hero_Gunslinger == nil then
	ability_hero_Gunslinger = class({})
end
-- 关联buff
LinkLuaModifier("modifier_Gunslinger_passive", "heroes/hero_muerta//ability_hero_Gunslinger.lua", LUA_MODIFIER_MOTION_NONE)

--被动添加的BUFF
function ability_hero_Gunslinger:GetIntrinsicModifierName()
    return "modifier_Gunslinger_passive"
end


--声明技能类型
function ability_hero_Gunslinger:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

--BUFF初始化
if modifier_Gunslinger_passive == nil then
	modifier_Gunslinger_passive = class({})
end

--是否隐藏
function modifier_Gunslinger_passive:IsHidden()
    return false
end

--buff创建时初始化
function modifier_Gunslinger_passive:OnCreated()
    if not IsServer() then
        return
    end
end
--能否被清除
function modifier_Gunslinger_passive:IsPurgable()
    return false
end

--是否debuff
function modifier_Gunslinger_passive:IsDebuff()
    return false
end

--死亡时是否移除
function modifier_Gunslinger_passive:RemoveOnDeath()
    return false
end

--声明攻击事件
function modifier_Gunslinger_passive:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACKED
    }
end

--监听攻击事件
--监听攻击事件
function modifier_Gunslinger_passive:OnAttacked(keys)
    local ta = keys.target
    -- local dam = keys.damage
    local at = keys.attacker
    local ability=self:GetAbility()
    local hero=self:GetCaster()
    local cooldown=keys.no_attack_cooldown
    if cooldown then
        return
    end
    self.cfgl=ability:GetSpecialValueFor("cfgl")
    --从KV获取触发的概率
    --是穷比+20
    if hero:GetUnitName()=="npc_dota_hero_muerta" then
        self.cfgl=self.cfgl+20
    end
    local attacked=nil
    local range=0
    --额外半径加成
    local isranged=hero:IsRangedAttacker()
    --如果是远程，则不享受额外半径，近战+350半径
    if isranged then
        else
            range=range+350
    end
    --如果攻击者是当前buff拥有者
    if at==hero then
        if RollPercentage(self.cfgl) then
            --查找英雄单位
            local dr_hero=FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), self, hero:Script_GetAttackRange()+range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS, 1, false)
            --查找普通单位
            local dr_unit=FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), self, hero:Script_GetAttackRange()+range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS, 1, false)

            if #dr_hero >0 then
                if #dr_hero>1 or #dr_unit==0 then
                    attacked=dr_hero
                else
                    attacked=dr_unit
                end
            elseif #dr_unit>0 then
                attacked=dr_unit
            end

        if #attacked == 1 then 
            hero:PerformAttack(attacked[1], true, true, true, false, true, false, false)
            return
        end
        if attacked ~=nil then
                for _, enemy in pairs(attacked) do
                    --if not hero or not enemy then print(3) return end
                    --对目标发动一次攻击，第四个参数一定给false 给ture就成时间锁定了
                    if enemy ~= ta then 
                        hero:PerformAttack(enemy, true, true, true, false, true, false, false)
                    --hero:PerformAttack(enemy, false, true, true, false, false, false, true)
                    --播放攻击动画
                    --StartAnimation(hero, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=5})
                    --播放攻击音效
                        hero:EmitSound("Hero_Muerta.Gunslinger")
                        break
                    end
                end
            end
        end
    end
end