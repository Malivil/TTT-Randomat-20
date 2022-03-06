local EVENT = {}

CreateConVar("randomat_crabs_count", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of crabs spawned when someone dies", 1, 10)

EVENT.Title = "Crabs are People"
EVENT.Description = "Spawns hostile headcrabs when a player is killed"
EVENT.id = "crabs"
EVENT.Categories = {"deathtrigger", "moderateimpact"}

function EVENT:Begin()
    local plys = {}
    for k, ply in ipairs(player.GetAll()) do
        if not ply:IsSpec() then
            plys[k] = ply
        end
    end

    timer.Create("headcrabtimer", 1, 0, function()
        for k, ply in pairs(plys) do
            if not ply:Alive() then
                for i = 1, GetConVar("randomat_crabs_count"):GetInt() do
                    local crab = ents.Create("npc_headcrab")
                    crab:SetPos(ply:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), 0))
                    crab:Spawn()
                end
                plys[k] = nil
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("headcrabtimer")
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