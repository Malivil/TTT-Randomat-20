local EVENT = {}

CreateConVar("randomat_patched_chance", 50, FCVAR_NONE, "The chance of the Glitch being made a Traitor", 0, 100)

EVENT.Title = "A Glitch has been patched"
EVENT.Description = "Changes a random glitch into either an innocent or a traitor"
EVENT.id = "patched"
EVENT.AltTitle = "Patched"
EVENT.StartSecret = true
EVENT.Categories = {"rolechange", "moderateimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description = "Changes a random " .. Randomat:GetRoleString(ROLE_GLITCH):lower() .. " into either " .. Randomat:GetRoleExtendedString(ROLE_INNOCENT):lower() .. " or " .. Randomat:GetRoleExtendedString(ROLE_TRAITOR):lower()
end

function EVENT:Begin()
    for _, v in ipairs(self:GetAlivePlayers(true)) do
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
    local i = 0
    local glitch = false
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsInnocentTeam(v) then
            i = i + 1
            if v:GetRole() == ROLE_GLITCH then
                glitch = true
            end
        end
    end

    return glitch and i > 1
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"chance"}) do
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