local EVENT = {}

EVENT.Title = "Honey, I shrunk the terrorists"
EVENT.Description = "Scales each player's size and speed"
EVENT.id = "shrink"
EVENT.Categories = {"fun", "moderateimpact"}

CreateConVar("randomat_shrink_scale", 0.5, FCVAR_NONE, "The shrinking scale factor", 0.1, 0.9)

function EVENT:Begin()
    local sc = GetConVar("randomat_shrink_scale"):GetFloat()
    self:SetAllPlayerScales(sc)

    timer.Create("RdmtTimerShrinkHp", 1, 0, function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            local rat = ply:GetStepSize() / 18
            if ply:Health() > math.floor(rat * 100) then
                ply:SetHealth(math.floor(rat * 100))
            end
            ply:SetMaxHealth(math.floor(rat * 100))
        end
    end)
end

function EVENT:End()
    self:ResetAllPlayerScales()
    timer.Remove("RdmtTimerShrinkHp")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"scale"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 1
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)