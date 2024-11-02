local EVENT = {}

EVENT.Title = "Can't stop, won't stop."
EVENT.Description = "Causes every player to constantly move forward"
EVENT.id = "cantstop"
EVENT.Categories = {"moderateimpact"}

CreateConVar("randomat_cantstop_disableback", 1, FCVAR_ARCHIVE, "Whether the \"s\" key is disabled")

function EVENT:Begin()
    local plys = {}
    for k, v in player.Iterator() do
        plys[k] = v
    end

    self:AddHook("Think", function()
        local backwards = Randomat:IsEventActive("opposite")
        for _, v in pairs(plys) do
            if v:Alive() and not v:IsSpec() then
                if backwards then
                    v:ConCommand("+back")
                else
                    v:ConCommand("+forward")
                end
                if GetConVar("randomat_cantstop_disableback"):GetBool() then
                    if backwards then
                        v:ConCommand("-forward")
                    else
                        v:ConCommand("-back")
                    end
                end
            end
        end
    end)
    self:AddHook("PostPlayerDeath", function(v)
        v:ConCommand("-forward")
        v:ConCommand("-back")
    end)
end

function EVENT:End()
    for _, v in player.Iterator() do
        v:ConCommand("-forward")
        v:ConCommand("-back")
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
