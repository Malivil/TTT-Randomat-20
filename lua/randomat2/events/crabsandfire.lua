local EVENT = {}

CreateConVar("randomat_crabsandfire_crab_count", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of crabs spawned", 1, 10)
CreateConVar("randomat_crabsandfire_fire_count", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of fire spawned", 1, 10)
CreateConVar("randomat_crabsandfire_fire_length", 20, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of time fire will last", 1, 10)

EVENT.Title = "Full of Crabs and Fire!"
EVENT.Description = "Spawns hostile headcrabs and fire around the detective when they are killed"
EVENT.id = "crabsandfire"
EVENT.Categories = {"deathtrigger", "entityspawn", "moderateimpact"}

function EVENT:Begin()
    local crab_count = GetConVar("randomat_crabsandfire_crab_count"):GetInt()
    local fire_count = GetConVar("randomat_crabsandfire_fire_count"):GetInt()
    local fire_length = GetConVar("randomat_crabsandfire_fire_length"):GetInt()

    local target
    for _, p in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(p) then
            target = p
            break
        end
        if Randomat:IsEvilDetectiveLike(p) then
            target = p
        end
    end

    self:AddHook("PostPlayerDeath", function(ply)
        if not IsPlayer(ply) then return end
        if target ~= ply then return end

        local pos = ply:GetPos()
        for i = 1, crab_count do
            local crab = ents.Create("npc_headcrab")
            crab:SetPos(pos + Vector(math.random(-100, 100), math.random(-100, 100), 0))
            crab.CrabsAndFireSpawnTime = CurTime()
            crab:Spawn()
        end

        local tr = util.TraceLine({start=pos, endpos=pos + Vector(0,0,-32), mask=MASK_SHOT_HULL, filter=ply})
        StartFires(pos, tr, fire_count, fire_length, false, ply)
    end)

    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not ent.CrabsAndFireSpawnTime then return end
        if not dmginfo:IsDamageType(DMG_BURN) then return end
        -- Let the crabs be immune to fire for the configured seconds
        if (CurTime() - ent.CrabsAndFireSpawnTime) < fire_length then
            dmginfo:SetDamage(0)
            dmginfo:ScaleDamage(0)
        end
    end)
end

function EVENT:Condition()
    for _, p in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(p) then return true end
        if Randomat:IsEvilDetectiveLike(p) then return true end
    end
    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"crab_count", "fire_count", "fire_length"}) do
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