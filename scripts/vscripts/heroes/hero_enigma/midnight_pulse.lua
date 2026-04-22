midnight_pulse=class({})
LinkLuaModifier("modifier_midnight_pulse_debuff", "heroes/hero_enigma/midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_midnight_pulse_debuff1", "heroes/hero_enigma/midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_midnight_pulse_buff", "heroes/hero_enigma/midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE)
function midnight_pulse:IsHiddenWhenStolen() 
    return false 
end

function midnight_pulse:IsStealable() 
    return true 
end

function midnight_pulse:IsRefreshable() 			
    return true 
end


function midnight_pulse:OnSpellStart() 
    local caster = self:GetCaster()
    local cur_pos = self:GetCursorPosition()
    local duration =self:GetSpecialValueFor("duration")
    local radius =self:GetSpecialValueFor("radius")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_enigma_9")
        if talent and talent:GetLevel() > 0 then
            radius = radius + 200
        end
    caster:EmitSound("Hero_Enigma.Midnight_Pulse")
    GridNav:DestroyTreesAroundPoint(cur_pos, radius, false)
    CreateModifierThinker(caster, self, "modifier_midnight_pulse_debuff", {duration=duration,radius=radius}, cur_pos, caster:GetTeamNumber(), false)
end

modifier_midnight_pulse_debuff= class({})

function modifier_midnight_pulse_debuff:IsDebuff() 			
    return true 
end

function modifier_midnight_pulse_debuff:IsHidden() 			
    return true 
end

function modifier_midnight_pulse_debuff:IsPurgable() 		
    return false
end

function modifier_midnight_pulse_debuff:IsPurgeException() 
    return false 
end

function modifier_midnight_pulse_debuff:OnCreated(tg) 
    self.damageTable = {
        attacker = self:GetCaster(),
        damage_type =DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
        }
    if not IsServer() then
        return 
    end
    self.radius=tg.radius
    self.pos=self:GetParent():GetAbsOrigin()
    local fx= ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf", PATTACH_CUSTOMORIGIN,nil)
    ParticleManager:SetParticleControl(fx, 0,  self.pos)
    ParticleManager:SetParticleControl(fx, 1, Vector(self.radius,self.radius,self.radius))
    self:AddParticle(fx, false, false, 20, false, false)
    self:StartIntervalThink(1)
end

--[[
★判断目标是否是友军（厉害了我的中国）。
--]]
function Is_Chinese_TG(tar1, tar2)
    if tar1:GetTeamNumber()==tar2:GetTeamNumber() then
        return true
    end
       return false
end


function modifier_midnight_pulse_debuff:OnIntervalThink() 
    local heros = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self.pos,
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_BOTH, 
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
        FIND_CLOSEST,
        false)
    if #heros>0 then
        for _, hero in pairs(heros) do
            if not Is_Chinese_TG( self:GetParent(),hero) and  not hero:IsBoss() then
                    self.damageTable.damage = hero:GetMaxHealth()*self:GetAbility():GetSpecialValueFor("damage_percent")*0.01
                    self.damageTable.victim = hero
                    ApplyDamage(self.damageTable)
            end
        end
    end
end