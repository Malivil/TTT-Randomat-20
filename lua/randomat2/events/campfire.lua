local EVENT = {}

EVENT.Title = "Camp Fire"
EVENT.Description = "Sets any player that has not moved enough on fire until they move from their current location"
EVENT.id = "campfire"
EVENT.Categories = {"moderateimpact"}

local playermovetime = {}
local playermoveloc = {}

CreateConVar("randomat_campfire_timer", 20, FCVAR_NONE, "Seconds a player must camp before they are punished", 1, 600)
CreateConVar("randomat_campfire_distance", 35, FCVAR_NONE, "Distance a player must move before they are not camping anymore", 1, 1000)

function EVENT:Begin()
    self:AddHook("FinishMove", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            local loc = ply:GetPos()
            local distance = GetConVar("randomat_campfire_distance"):GetInt()
            -- If we haven't seen the player move yet or they are now in a different location, save their location and update the movement time
            local sid64 = ply:SteamID64()
            if playermoveloc[sid64] == nil or math.abs(playermoveloc[sid64]:Distance(loc)) > distance then
                playermoveloc[sid64] = loc
                playermovetime[sid64] = CurTime()
            end
        end
    end)

    local plys = {}
    for _, v in player.Iterator() do
        plys[v:SteamID64()] = v
    end

    local tmr = GetConVar("randomat_campfire_timer"):GetInt()
    self:AddHook("Think", function()
        for _, v in pairs(plys) do
            local sid64 = v:SteamID64()
            if v:Alive() and not v:IsSpec() then
                -- If we haven't seen this player move yet, save the current time
                -- This handles the case where the player hasn't moved since the event started
                if playermovetime[sid64] == nil then
                    playermovetime[sid64] = CurTime()
                end

                -- If the player hasn't moved in the configured amount of time, set them on fire
                if (CurTime() - playermovetime[sid64]) > tmr then
                    if not v:IsOnFire() then
                        v:ChatPrint("Here's a fire for all that camping you've been doing.")
                        v:Ignite(tmr * 10)
                    end
                -- Extinguish them as soon as they move
                elseif v:IsOnFire() then
                    v:Extinguish()
                end
            else
                if playermovetime[sid64] ~= nil then
                    playermovetime[sid64] = nil
                end
                if plys[sid64] ~= nil then
                    plys[sid64] = nil
                end
            end
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        local sid64 = ply:SteamID64()
        if plys[sid64] == nil then
            plys[sid64] = ply
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "distance"}) do
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