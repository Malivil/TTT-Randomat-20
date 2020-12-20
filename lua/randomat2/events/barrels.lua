local EVENT = {}

CreateConVar("randomat_barrels_count", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of barrels spawned per person", 1, 5)
CreateConVar("randomat_barrels_range", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Distance barrels spawn from the player", 50, 200)
CreateConVar("randomat_barrels_timer", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between barrel spawns", 10, 120)

EVENT.Title = "Gunpowder, Treason, and Plot"
EVENT.Description = "Spawns explosive barrels around every player repeatedly until the event ends"
EVENT.id = "barrels"

local function TriggerBarrels()
    local plys = {}
    for k, ply in pairs(player.GetAll()) do
        if not ply:IsSpec() then
            plys[k] = ply
        end
    end

    for _, ply in pairs(plys) do
        if ply:Alive() and not ply:IsSpec() then
            for _ = 1, GetConVar("randomat_barrels_count"):GetInt() do
                local ent = ents.Create("prop_physics")

                if (not IsValid(ent)) then return end

                ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
                local sc = GetConVar("randomat_barrels_range"):GetInt()
                ent:SetPos(ply:GetPos() + Vector(math.random(-sc, sc), math.random(-sc, sc), math.random(5, sc)))
                ent:Spawn()

                local phys = ent:GetPhysicsObject()
                if (not IsValid(phys)) then ent:Remove() return end
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
    for _, v in pairs({"count", "range", "timer"}) do
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