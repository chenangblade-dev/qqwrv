modifier_invoker_chaos_meteor_lua_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_invoker_chaos_meteor_lua_thinker:IsHidden()
    return true
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_invoker_chaos_meteor_lua_thinker:OnCreated(kv)
    if IsServer() then
        -- references
        self.caster_origin = self:GetCaster():GetOrigin()
        self.parent_origin = self:GetParent():GetOrigin()
        if self.caster_origin ~=self.parent_origin then

            self.direction = self.parent_origin - self.caster_origin
            self.direction.z = 0
            self.direction = self.direction:Normalized()
            self.directionpoint=self.parent_origin
            self.caster_origin=self.caster_origin-self.direction*173

            self.direction1point=RotatePosition(self.caster_origin, QAngle(0, 30, 0), self.parent_origin)
            self.direction1 = self.direction1point - self.caster_origin
            self.direction1.z = 0
            self.direction1 = self.direction1:Normalized()
            self.direction1point=self.direction1point + Vector(0, 0, height_target)+100*self.direction1


            self.direction2point=RotatePosition(self.caster_origin, QAngle(0, -30, 0), self.parent_origin)
            self.direction2 =self.direction2point-self.caster_origin
            self.direction2.z = 0
            self.direction2 = self.direction2:Normalized()
            self.direction2point=self.direction2point + Vector(0, 0, height_target)+100*self.direction2





            self.delay = self:GetAbility():GetSpecialValueFor("land_time")
            self.radius = self:GetAbility():GetSpecialValueFor("area_of_effect")
            self.distance = self:GetAbility():GetSpecialValueFor("travel_distance")
            self.speed = self:GetAbility():GetSpecialValueFor("travel_speed")
            self.vision = self:GetAbility():GetSpecialValueFor("vision_distance")
            self.vision_duration = self:GetAbility():GetSpecialValueFor("end_vision_duration")

            self.interval = self:GetAbility():GetSpecialValueFor("damage_interval")
            self.duration = self:GetAbility():GetSpecialValueFor("burn_duration")
            local damage = self:GetAbility():GetSpecialValueFor("main_damage")
            local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_invoker_6")
            if talent and talent:GetLevel() > 0 then
                damage = damage * 1.8
            end

            -- variables
            self.fallen = false
            self.damageTable = {
                -- victim = target,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self:GetAbility(), --Optional.
            }

            self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
            
            self.nMoveStep = 0
            -- Start interval
            self:StartIntervalThink(self.delay)

            -- play effects
            self:PlayEffects1()
        end
    end
end

function modifier_invoker_chaos_meteor_lua_thinker:OnRefresh(kv)

end

function modifier_invoker_chaos_meteor_lua_thinker:OnDestroy()
    if IsServer() then
        -- add vision
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.vision, self.vision_duration, false)

        -- stop effects
        -- local sound_stop = "Hero_Invoker.ChaosMeteor.Destroy"
        -- EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), sound_stop, self:GetCaster())
        local sound_loop = "Hero_Invoker.ChaosMeteor.Loop"
        StopSoundOn(sound_loop, self:GetParent())
        if self.nLinearProjectile then
            ProjectileManager:DestroyLinearProjectile(self.nLinearProjectile)
        end
    end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_invoker_chaos_meteor_lua_thinker:OnIntervalThink()
    if not self.fallen then
        -- meatball has fallen
        self.fallen = true
        self:StartIntervalThink(self.interval)
        self:Burn()
        self:PlayEffects2()
    else
		self:Move_Burn()
    end
end

function modifier_invoker_chaos_meteor_lua_thinker:Burn()
    -- find enemies

    local dirtt={}
    table.insert (dirtt, self.directionpoint)

    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        table.insert (dirtt, self.direction1point)
        table.insert (dirtt, self.direction2point)
    end
    --printT(dirtt)
    for a=1,#dirtt do
        --print(a)
        --print(dirtt[a])
        local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(), -- int, your team number
        dirtt[a], -- point, center point
        nil, -- handle, cacheUnit. (not known)
        self.radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        0, -- int, flag filter
        0, -- int, order filter
        false	-- bool, can grow cache
        )
        --printT(enemies)
        for _, enemy in pairs(enemies) do
            -- apply damage
            self.damageTable.victim = enemy
            ApplyDamage(self.damageTable)

            -- add modifier
            enemy:AddNewModifier(
            self:GetCaster(), -- player source
            self:GetAbility(), -- ability source
            "modifier_invoker_chaos_meteor_lua_burn", -- modifier name
            { duration = self.duration } -- kv
            )
        end
    end
end

--------------------------------------------------------------------------------
-- Motion effects
function modifier_invoker_chaos_meteor_lua_thinker:Move_Burn()
    local parent = self:GetParent()

    -- set position
    local target = self.direction * self.speed * self.interval
    parent:SetOrigin(parent:GetOrigin() + target)
    self.nMoveStep = self.nMoveStep+1
    self.directionpoint=self.directionpoint + self.direction * self.speed * self.interval
    self.direction1point=self.direction1point + self.direction1 * self.speed * self.interval
    self.direction2point=self.direction2point + self.direction2 * self.speed * self.interval

    -- Burn
    self:Burn()

    --修复陨石卡主
    if self.nMoveStep and self.nMoveStep > 20 then
        self:Destroy()
        return
    end

    -- check distance for next step
    if (parent:GetOrigin() - self.parent_origin + target):Length2D() > self.distance then
        self:Destroy()
        return
    end
end


--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_invoker_chaos_meteor_lua_thinker:PlayEffects1()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf"
    local sound_cast = "Hero_Invoker.ChaosMeteor.Cast"
    local sound_loop = "Hero_Invoker.ChaosMeteor.Loop"

    -- Get Data
    local height = 1000
    local height_target = -0

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    -- local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.caster_origin+ Vector(0, 0, height))
    ParticleManager:SetParticleControl(effect_cast, 1, self.parent_origin + Vector(0, 0, height_target))
    ParticleManager:SetParticleControl(effect_cast, 2, Vector(self.delay, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_cast)



    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        local effect_cast1 = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast1, 0, self.caster_origin + Vector(0, 0, height))
        ParticleManager:SetParticleControl(effect_cast1, 1, self.direction1point)
        ParticleManager:SetParticleControl(effect_cast1, 2, Vector(self.delay, 0, 0))
        ParticleManager:ReleaseParticleIndex(effect_cast1)

        local effect_cast2 = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast2, 0, self.caster_origin + Vector(0, 0, height))
        ParticleManager:SetParticleControl(effect_cast2, 1, self.direction2point)
        ParticleManager:SetParticleControl(effect_cast2, 2, Vector(self.delay, 0, 0))
        ParticleManager:ReleaseParticleIndex(effect_cast2)
    end

    -- Create Sound
    EmitSoundOnLocationWithCaster(self:GetCaster():GetOrigin(), sound_cast, self:GetCaster())
    EmitSoundOn(sound_loop, self:GetParent())
end

function modifier_invoker_chaos_meteor_lua_thinker:PlayEffects2()
    -- Get Resources
    local particle_loop = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf"
    local sound_impact = "Hero_Invoker.ChaosMeteor.Impact"
    local dirtb={}
    local dirta={}
    table.insert (dirtb, self.direction)
    table.insert (dirta, self.directionpoint)
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        table.insert (dirtb, self.direction1)
        table.insert (dirta, self.direction1point)
        table.insert (dirtb, self.direction2)
        table.insert (dirta, self.direction2point)
    end
    for a=1,#dirtb do

        local meteor_projectile = {
            Ability = self:GetAbility(),
            EffectName = particle_loop,
            vSpawnOrigin = dirta[a],

            fDistance = self.distance,
            fStartRadius = self.radius,
            fEndRadius = self.radius,
            Source = self:GetCaster(),
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_NONE,
            bDeleteOnHit = false,
            vVelocity = dirtb[a] * self.speed,
            bProvidesVision = true,
            iVisionRadius = self.vision,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber()
        }
        self.nLinearProjectile = ProjectileManager:CreateLinearProjectile(meteor_projectile)
    end
    EmitSoundOnLocationWithCaster(self.parent_origin, sound_impact, self:GetCaster())
end