util.AddNetworkString("TTT_Zombified")

local EVENT = {}

EVENT.Title = "RISE FROM YOUR GRAVE"
EVENT.Description = "Causes the dead to rise again as Zombies"
EVENT.id = "grave"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

CreateConVar("randomat_grave_health", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The health that the Zombies respawn with", 10, 100)
CreateConVar("randomat_grave_include_dead", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to resurrect dead players at the start")

local function ShouldZombify(ply)
    return not ply:Alive() and ply:GetRole() ~= ROLE_ZOMBIE and not Randomat:IsZombifying(ply)
end

local function ZombifyPlayer(ply, skip_missing_corpse)
    local body = ply.server_ragdoll or ply:GetRagdollEntity()
    if skip_missing_corpse and not IsValid(body) then return false end

    net.Start("TTT_Zombified")
    net.WriteString(ply:Nick())
    net.Broadcast()

    ply:SpawnForRound(true)
    ply:SetCredits(0)
    ply:SetRole(ROLE_ZOMBIE)
    if ply.SetZombiePrime then
        ply:SetZombiePrime(false)
    end
    ply:SetHealth(GetConVar("randomat_grave_health"):GetInt())
    ply:SetMaxHealth(GetConVar("randomat_grave_health"):GetInt())
    ply:StripWeapons()
    ply:Give("weapon_zom_claws")
    if IsValid(body) then
        ply:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
        body:Remove()
    end

    return true
end

function EVENT:Begin(filter_class)
    -- Update this in case the role names have been changed
    EVENT.Description = "Causes the dead to rise again as " .. Randomat:GetRolePluralString(ROLE_ZOMBIE)

    local include_dead = not filter_class and GetConVar("randomat_grave_include_dead"):GetBool()
    if include_dead then
        local zombified = false
        for _, p in ipairs(self:GetDeadPlayers()) do
            if ShouldZombify(p) then
                zombified = zombified or ZombifyPlayer(p, true)
            end
        end

        -- Don't update everyone if nobody actually changed
        if zombified then
            SendFullStateUpdate()
        end
    end

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        timer.Create(victim:SteamID64() .. "RdmtZombieTimer", 0.25, 1, function()
            if (not filter_class or (IsValid(killer) and killer:GetClass() == filter_class)) and ShouldZombify(victim) then
                ZombifyPlayer(victim, false)
                SendFullStateUpdate()
            end
        end)
    end)
end

function EVENT:End()
    for _, v in ipairs(player.GetAll()) do
        timer.Remove(v:SteamID64() .. "RdmtZombieTimer")
    end
end

function EVENT:Condition()
    -- Don't do zombies if there is a Mad Scientist because that just makes their job too easy
    if ConVarExists("ttt_madscientist_enabled") then
        for _, p in ipairs(player.GetAll()) do
            if p:GetRole() == ROLE_MADSCIENTIST then
                return false
            end
        end
    end
    return ConVarExists("ttt_zombie_enabled")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"health"}) do
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

    local checks = {}
    for _, v in ipairs({"include_dead"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return sliders, checks
end

Randomat:register(EVENT)