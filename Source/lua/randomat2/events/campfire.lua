local EVENT = {}

EVENT.Title = "Camp Fire"
EVENT.id = "campfire"

local playermovetime = {}
local playermoveloc = {}

CreateConVar("randomat_campfire_timer", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Amount of time a player must camp before they are punished")
CreateConVar("randomat_campfire_distance", 35, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The distance a player must move before they are considered not camping anymore")

function EVENT:Begin()
    hook.Add("SetupMove", "RdmtCampfireMovementHook", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            local loc = ply:GetPos()
            local distance = GetConVar("randomat_campfire_distance"):GetInt()
            -- If we haven't seen the player move yet or they are now in a different location, save their location and update the movement time
            if playermoveloc[ply:GetName()] == nil or math.abs(playermoveloc[ply:GetName()]:Distance(loc)) > distance then
                playermoveloc[ply:GetName()] = loc
                playermovetime[ply:GetName()] = CurTime()
            end
        end
    end);

    local plys = {}
    for _, v in pairs(player.GetAll()) do
        plys[v:GetName()] = v
    end

    local tmr = GetConVar("randomat_campfire_timer"):GetInt()
    hook.Add("Think", "RdmtCampfirePunishHook", function()
        for _, v in pairs(plys) do
            if v:Alive() and not v:IsSpec() then
                -- If we haven't seen this player move yet, save the current time
                -- This handles the case where the player hasn't moved since the event started
                if playermovetime[v:GetName()] == nil then
                    playermovetime[v:GetName()] = CurTime()
                end

                -- If the player hasn't moved in the configured amount of time, set them on fire
                if (CurTime() - playermovetime[v:GetName()]) > tmr then
                    if not v:IsOnFire() then
                        v:ChatPrint("Here's a fire for all that camping you've been doing.")
                        v:Ignite(tmr * 10)
                    end
                -- Extinguish them as soon as they move
                elseif v:IsOnFire() then
                    v:Extinguish()
                end
            else
                if playermovetime[v:GetName()] ~= nil then
                    playermovetime[v:GetName()] = nil
                end
                if plys[v:GetName()] ~= nil then
                    plys[v:GetName()] = nil
                end
            end
        end
    end)

    hook.Add("PlayerSpawn", "RdmtCampfireSpawnHook", function(ply)
        if plys[ply:GetName()] == nil then
            plys[ply:GetName()] = ply
        end
    end)
end

function EVENT:End()
    hook.Remove("SetupMove", "RdmtCampfireMovementHook")
    hook.Remove("Think", "RdmtCampfirePunishHook")
    hook.Remove("PlayerSpawn", "RdmtCampfireSpawnHook")
end

Randomat:register(EVENT)