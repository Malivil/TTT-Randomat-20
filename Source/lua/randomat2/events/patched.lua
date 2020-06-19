local EVENT = {}

CreateConVar("randomat_patched_chance", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The chance of the Glitch being made a Traitor", 0, 100)

EVENT.Title = "A Glitch has been patched"
EVENT.id = "patched"
EVENT.AltTitle = "Patched"

function EVENT:Begin()
    for _, v in pairs(self:GetAlivePlayers(true)) do
        if v:GetRole() == ROLE_GLITCH then
            if math.random(1,100) <= GetConVar("randomat_patched_chance"):GetInt() then
                Randomat:SetRole(v, ROLE_INNOCENT)
            else
                Randomat:SetRole(v, ROLE_TRAITOR)
            end
            SendFullStateUpdate()

            return
        end
    end
end

function EVENT:Condition()
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_GLITCH then
            return true
        end
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"chance"}) do
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