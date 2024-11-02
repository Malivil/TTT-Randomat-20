local EVENT = {}

CreateConVar("randomat_magnetism_radius", 1000, FCVAR_ARCHIVE, "The radius around the dead player for magnetism", 250, 5000)

EVENT.Title = "Total Magnetism"
EVENT.Description = "When a player dies, all nearby players will be pulled toward their corpse"
EVENT.id = "magnetism"
EVENT.Categories = {"deathtrigger", "biased_innocent", "biased", "moderateimpact"}

function EVENT:Begin()
    local pull_force = 4000
    local jumping_pull_force = 2000
    local radius = GetConVar("randomat_magnetism_radius"):GetInt()
    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end

        local pos = victim:GetPos()
        for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
            if IsPlayer(ent) and ent:Alive() and not ent:IsSpec() then
                -- Get the direction toward the player who died
                local dir = (pos - ent:GetPos()):GetNormal()

                -- Pull with a different amount of force depending on whether they are on the ground or not
                local pull
                if ent:IsOnGround() then
                    pull = dir * pull_force
                else
                    pull = dir * jumping_pull_force
                end

                -- Add the extra pull to the player's current velocity
                local current_vel = ent:GetVelocity()
                local vel = current_vel + pull
                -- Don't make the player jump any more than they already are
                vel.z = current_vel.z

                -- Pull the victim
                ent:SetVelocity(vel)
            end
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"radius"}) do
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