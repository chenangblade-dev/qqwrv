impetus= class({})
LinkLuaModifier("modifier_impetus", "heroes/hero_enchantress/impetus.lua", LUA_MODIFIER_MOTION_NONE)

function impetus:GetIntrinsicModifierName()
    return "modifier_impetus"
end


modifier_impetus = class({})

function modifier_impetus:IsPassive()
	return true
end

function modifier_impetus:IsPurgable()
    return false
end

function modifier_impetus:IsPurgeException()
    return false
end

function modifier_impetus:IsHidden()
    return true
end

function modifier_impetus:IsPermanent()
    return true
end

function modifier_impetus:OnCreated()
	if self:GetAbility() == nil then return end
    if IsServer() then
        if self:GetAbility() == nil  then
            return
        end
        self.ability=self:GetAbility()
        self.parent=self:GetParent()
        self.team=self.parent:GetTeamNumber()
        self.dam=self.ability:GetSpecialValueFor("dam")*0.01

        self.damage= {
            attacker = self.parent,
            damage_type =DAMAGE_TYPE_MAGICAL,
            ability = self.ability,
            }
    end
end

function modifier_impetus:OnRefresh()
    self:OnCreated()
end

function modifier_impetus:OnAttackStart(tg)
	if not IsServer() then
		return
    end
    if tg.attacker == self.parent then
        self.parent:EmitSound("Hero_Enchantress.Impetus")
    end
end
function modifier_impetus:OnAttackLanded(tg)
	if not IsServer() then
		return
	end
    if tg.attacker == self.parent  then
        if  tg.target:IsOther() or tg.target:IsBuilding() or self.parent:IsIllusion() then
            return
        end
        local dis=(tg.target:GetAbsOrigin()-tg.attacker:GetAbsOrigin()):Length2D()
        local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_enchantress_4")
        if talent and talent:GetLevel() > 0 then
            self.dam=55*0.01
        end
        local dmg=dis*self.dam
        self.damage.damage=dmg
        self.damage.victim = tg.target
        self.damage.damage_type = DAMAGE_TYPE_PURE 
        ApplyDamage(self.damage)
    end
end


function modifier_impetus:DeclareFunctions()
    return
    {   MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
end

function modifier_impetus:GetModifierProjectileName()
    return  "particles/econ/items/enchantress/enchantress_virgas/ench_impetus_virgas.vpcf"
end


