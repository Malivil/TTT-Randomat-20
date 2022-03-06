local EVENT = {}

CreateConVar("randomat_barrels_count", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of barrels spawned per person", 1, 5)
CreateConVar("randomat_barrels_range", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Distance barrels spawn from the player", 50, 200)
CreateConVar("randomat_barrels_timer", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between barrel spawns", 10, 120)

EVENT.Title = "Gunpowder, Treason, and Plot"
EVENT.Description = "Spawns explosive barrels around every player repeatedly until the event ends"
EVENT.id = "barrels"
EVENT.Categories = {"moderateimpact"}

local function TriggerBarrels()
    local plys = {}
    for k, ply in ipairs(player.GetAll()) do
        if not ply:IsSpec() then
            plys[k] = ply
        end
    end

    local range = GetConVar("randomat_barrels_range"):GetInt()
    for _, ply in pairs(plys) do
        if ply:Alive() and not ply:IsSpec() then
            for _ = 1, GetConVar("randomat_barrels_count"):GetInt() do
                Randomat:SpawnBarrel(ply:GetPos(), range)
            end
        end
    end
end

function EVENT:Begin()
    TriggerBarrels()
    timer.Create("RdmtBarrelSpawnTimer",GetConVar("randomat_barrels_timer"):GetInt(), 0, TriggerBarrels)
end

function EVENT:End()
    timer.Remove("RdmtBarrelSpawnTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"count", "range", "timer"}) do
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