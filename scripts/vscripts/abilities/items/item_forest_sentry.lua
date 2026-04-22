function CreateSentry(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local pos = target:GetAbsOrigin()
    local radius = ability:GetSpecialValueFor('radius')
    local duration = ability:GetSpecialValueFor('duration')
    AddFOWViewer(caster:GetTeamNumber(), pos, 1000, 60, false)
end
