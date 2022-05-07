local EVENT = {}

CreateConVar("randomat_barrelinjustice_count", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of barrels spawned", 0, 5)
CreateConVar("randomat_barrelinjustice_range", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Minimum distance from the player for a barrel to explode", 50, 200)

EVENT.Title = "Barrel (In)Justice"
EVENT.Description = "Explodes barrels if a player gets too close and then spawns more"
EVENT.id = "barrelinjustice"
EVENT.Categories = {"entityspawn", "moderateimpact"}

function EVENT:Begin()
    local count = GetConVar("randomat_barrelinjustice_count"):GetInt()
    local range = GetConVar("randomat_barrelinjustice_range"):GetInt()
    self:AddHook("FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end

        -- If there are any barrels near to this player
        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), range)) do
            if ent:GetClass() ~= "prop_physics" then continue end
            if ent:GetModel() ~= "models/props_c17/oildrum001_explosive.mdl" then continue end

            -- Explode the barrel
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(1000)
            dmginfo:SetAttacker(ply)
            dmginfo:SetInflictor(ply)
            dmginfo:SetDamageType(DMG_BULLET)
            ent:TakeDamageInfo(dmginfo)

            -- Spawn more
            if count > 0 then
                for _ = 1, count do
                    Randomat:SpawnBarrel(ply:GetPos(), range * 3, range * 2)
                end
            end
        end
    end)
end

function EVENT:Condition()
    return not Randomat:IsEventActive("bomberman")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"count", "range"}) do
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