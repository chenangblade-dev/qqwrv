
modifier_oldsky_abolt_stack = class({})

function modifier_oldsky_abolt_stack:IsHidden() return false end
function modifier_oldsky_abolt_stack:IsBuff() return true end
function modifier_oldsky_abolt_stack:IsDebuff() return false end
function modifier_oldsky_abolt_stack:IsStunDebuff() return false end
function modifier_oldsky_abolt_stack:IsPurgable() return false end
function modifier_oldsky_abolt_stack:IsPurgeException() return false end

function modifier_oldsky_abolt_stack:OnCreated()
    if not IsServer() then return end
    local caster = self:GetParent()

    self:SetStackCount(1)

end


function modifier_oldsky_abolt_stack:OnRefresh()
    if not IsServer() then return end
    if self:GetStackCount()>50 then 
        self:SetStackCount(50)
    else            
        self:IncrementStackCount()
    end

end

function modifier_oldsky_abolt_stack:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function modifier_oldsky_abolt_stack:RemoveOnDeath() 
    if self:GetCaster():HasScepter() then
            return false
    end
        return true
end


function modifier_oldsky_abolt_stack:GetModifierBonusStats_Intellect()
    if not self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("abolt_stackint"))
    end
    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("abolt_stackint")* 2)
end

function modifier_oldsky_abolt_stack:OnDeath(tg)
    if IsServer() then
        if tg.unit == self:GetParent() and self:GetCaster():HasScepter()then
            self:SetStackCount(self:GetStackCount()*0.8)
        end
    end
end