local EVENT = {}

CreateConVar("randomat_evasive_force", 2000, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Amount of force to push players with", 1000, 5000)
CreateConVar("randomat_evasive_jumping_force", 1000, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Amount of force to push jumping players with", 256, 5000)

EVENT.Title = "Evasive Maneuvers"
EVENT.Description = "Causes players who are shot to \"dodge\" out of the way of further bullets"
EVENT.id = "evasive"

function EVENT:Begin()
    local push_force = GetConVar("randomat_evasive_force"):GetInt()
    local jumping_push_force = GetConVar("randomat_evasive_jumping_force"):GetInt()
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not dmginfo:IsBulletDamage() or not IsValid(ent) or not ent:IsPlayer() then return end
        local att = dmginfo:GetAttacker()
        if not IsValid(att) or not att:IsPlayer() or ent == att then return end

        -- Get the direction "away" from the attacker
        local dir = (ent:GetPos() - att:GetPos()):GetNormal()

        -- Push with a different amount of force depending on whether they are on the ground or not
        local push
        if ent:IsOnGround() then
            push = dir * push_force
        else
            push = dir * jumping_push_force
        end

        -- Add the extra push to the player's current velocity
        local current_vel = ent:GetVelocity()
        local vel = current_vel + push
        -- Don't make the player jump any more than they already are
        vel.z = current_vel.z

        -- Push the victim
        ent:SetVelocity(vel)
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"force", "jumping_force"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)