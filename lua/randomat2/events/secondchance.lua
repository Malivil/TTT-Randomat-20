local EVENT = {}

EVENT.Title = "Second Chance"
EVENT.Description = "Respawns the first player who is killed as a random vanilla role"
EVENT.id = "secondchance"
EVENT.Type = EVENT_TYPE_RESPAWN
EVENT.Categories = {"deathtrigger", "rolechange", "moderateimpact"}

function EVENT:Begin()
    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        if not IsValid(killer) then return end
        -- Don't reward people who kill themselves trying to get a different role
        if victim == killer then return end
        self:RemoveHook("PlayerDeath")

        victim:PrintMessage(HUD_PRINTTALK, "You will be respawning shortly...")
        victim:PrintMessage(HUD_PRINTCENTER, "You will be respawning shortly...")
        timer.Create("RdmtSecondChanceTimer", 1, 1, function()
            local body = victim.server_ragdoll or victim:GetRagdollEntity()
            victim:SpawnForRound(true)
            -- Change the victim's role to either innocent or traitor
            Randomat:SetRole(victim, math.random(0, 1) == 1 and ROLE_INNOCENT or ROLE_TRAITOR)
            if IsValid(body) then
                body:Remove()
            end
            SendFullStateUpdate()
        end)
    end)
end

function EVENT:End()
    timer.Remove("RdmtSecondChanceTimer")
end

Randomat:register(EVENT)