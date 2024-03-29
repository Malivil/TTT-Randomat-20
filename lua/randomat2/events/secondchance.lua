local EVENT = {}

EVENT.Title = "Second Chance"
EVENT.Description = "Respawns the first player who is killed as a random vanilla role"
EVENT.id = "secondchance"
EVENT.Type = EVENT_TYPE_RESPAWN
EVENT.Categories = {"deathtrigger", "rolechange", "moderateimpact"}

function EVENT:Begin()
    local first = nil
    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        if not IsValid(killer) then return end
        -- Don't reward people who kill themselves trying to get a different role
        if victim == killer then return end
        self:RemoveHook("PlayerDeath")

        first = victim
        Randomat:PrintMessage(victim, MSG_PRINTBOTH, "You will be respawning shortly...")
        timer.Create("RdmtSecondChanceTimer", 1, 1, function()
            local body = victim.server_ragdoll or victim:GetRagdollEntity()
            victim:SpawnForRound(true)
            -- Change the victim's role to either innocent or traitor
            Randomat:SetRole(victim, math.random(0, 1) == 1 and ROLE_INNOCENT or ROLE_TRAITOR)
            self:StripRoleWeapons(victim)
            if IsValid(body) then
                body:Remove()
            end
            SendFullStateUpdate()
        end)
    end)

    -- Don't show the attacker's role for the player being respawned
    self:AddHook("TTTDeathNotifyOverride", function(victim, inflictor, attacker, reason, killerName, role)
        if not IsPlayer(first) then return end
        if not IsPlayer(victim) then return end
        if reason ~= "ply" then return end
        if victim ~= first then return end

        -- Reset this so they see the role the next time they die
        first = nil
        return reason, killerName, ROLE_NONE
    end)
end

function EVENT:End()
    timer.Remove("RdmtSecondChanceTimer")
end

Randomat:register(EVENT)