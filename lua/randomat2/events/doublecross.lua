local EVENT = {}

CreateConVar("randomat_doublecross_chance", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The chance of the Innocent being made a Traitor", 0, 100)

EVENT.Title = "Double Cross"
EVENT.id = "doublecross"
EVENT.AltTitle = ""

function EVENT:Begin()
    for _, v in pairs(self:GetAlivePlayers(true)) do
        if v:GetRole() == ROLE_INNOCENT then
            if math.random(1,100) <= GetConVar("randomat_doublecross_chance"):GetInt() then
                Randomat:SetRole(v, ROLE_GLITCH)
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
    local vanilla = false
    local glitch = false
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_INNOCENT then
            vanilla = true
            i = i + 1
        end
        if v:GetRole() == ROLE_GLITCH then
            glitch = true
            i = i + 1
        end
        if v:GetRole() == ROLE_DETECTIVE or v:GetRole() == ROLE_MERCENARY or v:GetRole() == ROLE_PHANTOM then
            i = i + 1
        end
    end

    return vanilla and glitch and i > 1
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