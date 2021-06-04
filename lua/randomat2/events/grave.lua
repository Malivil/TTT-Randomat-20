util.AddNetworkString("TTT_Zombified")

local EVENT = {}

EVENT.Title = "RISE FROM YOUR GRAVE"
EVENT.Description = "Causes anyone who dies to be resurrected as a Zombie"
EVENT.id = "grave"

CreateConVar("randomat_grave_health", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The health that the Zombies respawn with", 10, 100)

function EVENT:Begin(...)
    local params = ...
    local filter_class = nil
    if params ~= nil and params[1] ~= nil then
        filter_class = params[1]
    end

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        timer.Create(victim:SteamID64() .. "RdmtZombieTimer", 0.25, 1, function()
            if (filter_class == nil or (IsValid(killer) and killer:GetClass() == filter_class)) and not victim:Alive() and victim:GetRole() ~= ROLE_ZOMBIE and victim:GetPData("IsZombifying", 0) ~= 1 then
                net.Start("TTT_Zombified")
                net.WriteString(victim:Nick())
                net.Broadcast()

                local body = victim.server_ragdoll or victim:GetRagdollEntity()
                victim:SpawnForRound(true)
                victim:SetCredits(0)
                victim:SetRole(ROLE_ZOMBIE)
                if victim.SetZombiePrime then
                    victim:SetZombiePrime(false)
                end
                victim:SetHealth(GetConVar("randomat_grave_health"):GetInt())
                victim:SetMaxHealth(GetConVar("randomat_grave_health"):GetInt())
                victim:StripWeapons()
                victim:Give("weapon_zom_claws")
                if IsValid(body) then
                    victim:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
                    body:Remove()
                end
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
    return ConVarExists("ttt_zombie_enabled") and not Randomat:IsEventActive("prophunt") and not Randomat:IsEventActive("harpoon") and not Randomat:IsEventActive("slam") and not Randomat:IsEventActive("murder")
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
    return sliders
end

Randomat:register(EVENT)