local EVENT = {}

EVENT.Title = "Can't stop, won't stop."
EVENT.Description = "Causes every player to constantly move forward"
EVENT.id = "cantstop"

CreateConVar("randomat_cantstop_disableback", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the \"s\" key is disabled")

function EVENT:Begin()
    local plys = {}
    for k, v in ipairs(player.GetAll()) do
        plys[k] = v
    end
    self:AddHook("Think", function()
        for _, v in pairs(plys) do
            if v:Alive() and not v:IsSpec() then
                v:ConCommand("+forward")
                if GetConVar("randomat_cantstop_disableback"):GetBool() then
                    v:ConCommand("-back")
                end
            end
        end
    end)
    self:AddHook("PostPlayerDeath", function(v)
        v:ConCommand("-forward")
    end)
end

function EVENT:End()
    for _, v in ipairs(player.GetAll()) do
        v:ConCommand("-forward")
    end
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"disableback"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return {}, checks
end

Randomat:register(EVENT)
