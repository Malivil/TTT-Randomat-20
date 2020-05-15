local EVENT = {}

CreateConVar("randomat_cakes_count", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of cakes spawned per person")
CreateConVar("randomat_cakes_range", 200, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Distance cakes spawn from the player")
CreateConVar("randomat_cakes_timer", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between cake spawns")

EVENT.Title = "The Cake is a Lie!"
EVENT.id = "cakes"

local function TriggerCakes()
    local plys = {}
    for k, ply in pairs(player.GetAll()) do
        if not ply:IsSpec() then
            plys[k] = ply
        end
    end

    for _, ply in pairs(plys) do
        if ply:Alive() and not ply:IsSpec() then
            if (CLIENT) then return end

            for _ = 1, GetConVar("randomat_cakes_count"):GetInt() do
                local ent = ents.Create("ttt_randomat_cake")
                if not IsValid(ent) then return end

                local sc = GetConVar("randomat_cakes_range"):GetInt()
                ent:SetPos(ply:GetPos() + Vector(math.random(-sc, sc), math.random(-sc, sc), math.random(100, sc)))
                ent:Spawn()

                local phys = ent:GetPhysicsObject()
                if not IsValid(phys) then ent:Remove() return end
            end
        end
    end
end

function EVENT:Begin(notify)
    TriggerCakes()
    timer.Create("RdmtCakeSpawnTimer",GetConVar("randomat_cakes_timer"):GetInt(),0, TriggerCakes)
end

function EVENT:End()
    timer.Remove("RdmtCakeSpawnTimer")
end


Randomat:register(EVENT)