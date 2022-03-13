local EVENT = {}

CreateConVar("randomat_cakes_count", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of cakes spawned per person", 1, 10)
CreateConVar("randomat_cakes_range", 200, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Distance cakes spawn from the player", 0, 1000)
CreateConVar("randomat_cakes_timer", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between cake spawns", 1, 600)
CreateConVar("randomat_cakes_health", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the player will regain from eating a cake", 1, 100)
CreateConVar("randomat_cakes_damage", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the player will lose from eating a cake", 1, 100)
CreateConVar("randomat_cakes_damage_time", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of time the player will take damage after eating a cake", 1, 60)
CreateConVar("randomat_cakes_damage_interval", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How often the player will take damage after eating a cake", 1, 60)
CreateConVar("randomat_cakes_damage_over_time", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the player will lose each tick after eating a cake", 1, 100)

EVENT.Title = "The Cake is a Lie!"
EVENT.Description = "Rains cakes down around players which have a 50/50 chance or either healing or hurting when eaten"
EVENT.id = "cakes"
EVENT.Categories = {"entityspawn", "moderateimpact"}

local function TriggerCakes()
    local plys = {}
    for k, ply in ipairs(player.GetAll()) do
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

function EVENT:Begin()
    TriggerCakes()
    timer.Create("RdmtCakeSpawnTimer",GetConVar("randomat_cakes_timer"):GetInt(),0, TriggerCakes)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        timer.Remove(victim:GetName() .. "RdmtCakeDamageTimer")
    end)
end

function EVENT:End()
    timer.Remove("RdmtCakeSpawnTimer")
    for _, ply in ipairs(player.GetAll()) do
        timer.Remove(ply:GetName() .. "RdmtCakeDamageTimer")
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"count", "range", "timer", "health", "damage", "damage_time", "damage_interval", "damage_over_time"}) do
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