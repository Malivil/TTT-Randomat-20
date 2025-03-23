local EVENT = {}

CreateConVar("randomat_imbees_count", 3, FCVAR_NONE, "The amount of bees spawned when someone dies", 1, 10)

EVENT.Title = "Stop, I'm Bees!"
EVENT.Description = "Spawns bees when a player is killed"
EVENT.id = "imbees"
EVENT.Categories = {"deathtrigger", "entityspawn", "moderateimpact"}

function EVENT:Begin()
    local plys = {}
    for k, ply in player.Iterator() do
        if not ply:IsSpec() then
            plys[k] = ply
        end
    end

    timer.Create("RdmtImBeesTimer", 1, 0, function()
        for k, ply in pairs(plys) do
            if not ply:Alive() then
                for _ = 1, GetConVar("randomat_imbees_count"):GetInt() do
                    Randomat:SpawnBee(ply, nil, math.random(25, 50))
                end
                plys[k] = nil
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtImBeesTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"count"}) do
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