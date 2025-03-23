local EVENT = {}

util.AddNetworkString("RdmtOurSecretHaloStart")
util.AddNetworkString("RdmtOurSecretHaloEnd")

CreateConVar("randomat_oursecret_min_delay", 15, FCVAR_NONE, "The minimum delay before showing role", 1, 60)
CreateConVar("randomat_oursecret_max_delay", 30, FCVAR_NONE, "The maximum delay before showing role", 1, 120)
CreateConVar("randomat_oursecret_highlight_time", 5, FCVAR_NONE, "How long to show role color", 1, 60)

EVENT.Title = "Our Little Secret"
EVENT.Description = "Pairs players together, temporarily revealing their roles after a short delay"
EVENT.id = "oursecret"
EVENT.Categories = {"biased_innocent", "biased", "moderateimpact"}

local timers = {}
function EVENT:Begin()
    timers = {}

    local ply1 = {}
    local ply2 = {}
    local x = 0
    for _, v in ipairs(self:GetAlivePlayers(true)) do
        -- Don't pick the detective since everyone knows who they are already
        if not Randomat:IsDetectiveTeam(v) then
            if x % 2 == 0 then
                table.insert(ply1, v)
            else
                table.insert(ply2, v)
            end
            x = x+1
        end
    end

    local min_delay = GetConVar("randomat_oursecret_min_delay"):GetInt()
    local max_delay = math.max(min_delay, GetConVar("randomat_oursecret_max_delay"):GetInt())
    local highlight_time = GetConVar("randomat_oursecret_highlight_time"):GetInt()
    for i = 1, #ply2 do
        local player1 = ply1[i]
        local player2 = ply2[i]
        local delay = math.random(min_delay, max_delay)

        local timer_id = "RdmtOurSecretTimer_" .. player1:SteamID64() .. "_" .. player2:SteamID64()
        table.insert(timers, timer_id)

        local message_timer_id = timer_id .. "_Message"
        table.insert(timers, message_timer_id)

        -- Delay these messages slightly so they come after the event description
        timer.Create(message_timer_id, 0.25, 1, function()
            Randomat:PrintMessage(player1, MSG_PRINTBOTH, "Your buddy is " .. player2:Nick() .. ". You have " .. delay .. " seconds to find them.")
            Randomat:PrintMessage(player2, MSG_PRINTBOTH, "Your buddy is " .. player1:Nick() .. ". You have " .. delay .. " seconds to find them.")
        end)
        Randomat:LogEvent("[RANDOMAT] " .. player1:Nick() .. " and " .. player2:Nick() .. " are now buddies with a delay of " .. delay .. " seconds.")

        timer.Create(timer_id, 1, delay, function()
            local ply1_dead = not player1:Alive() or player1:IsSpec()
            local ply2_dead = not player2:Alive() or player2:IsSpec()
            -- If either player is dead, let the other one know and stop the timer
            if ply1_dead or ply2_dead then
                -- Send death message to whichever is alive
                if ply1_dead and not ply2_dead then
                    player2:PrintMessage(HUD_PRINTTALK, "Your buddy has died :(")
                end
                if ply2_dead and not ply1_dead then
                    player1:PrintMessage(HUD_PRINTTALK, "Your buddy has died :(")
                end
                timer.Remove(timer_id)
                return
            end

            local reps_left = timer.RepsLeft(timer_id)
            if reps_left > 5 then return end

            -- Give the players a 5 second warning
            if reps_left > 0 then
                player1:PrintMessage(HUD_PRINTTALK, "Quick! You only have " .. reps_left .. " seconds to find your buddy, " .. player2:Nick() .. "!")
                player2:PrintMessage(HUD_PRINTTALK, "Quick! You only have " .. reps_left .. " seconds to find your buddy, " .. player1:Nick() .. "!")
                return
            end

            player1:PrintMessage(HUD_PRINTTALK, "Your buddy (" .. player2:Nick() .. ")'s role has been revealed for " .. highlight_time .. " seconds!")
            player2:PrintMessage(HUD_PRINTTALK, "Your buddy (" .. player1:Nick() .. ")'s role has been revealed for " .. highlight_time .. " seconds!")

            -- Enable halo for both players
            net.Start("RdmtOurSecretHaloStart")
            net.WritePlayer(player2)
            net.Send(player1)

            net.Start("RdmtOurSecretHaloStart")
            net.WritePlayer(player1)
            net.Send(player2)

            -- Disable the halo for both players after a certain amount of time
            local halo_timer_id = timer_id .. "_Halo"
            table.insert(timers, halo_timer_id)

            timer.Create(halo_timer_id, highlight_time, 1, function()
                net.Start("RdmtOurSecretHaloEnd")
                net.Send(player1)

                net.Start("RdmtOurSecretHaloEnd")
                net.Send(player2)
            end)
        end)
    end

    if ply1[#ply2+1] then
        Randomat:PrintMessage(ply1[#ply2+1], MSG_PRINTBOTH, "You have no buddy :(")
        Randomat:LogEvent("[RANDOMAT] " .. ply1[#ply2+1]:Nick() .. " has no buddy :(")
    end
end

function EVENT:End()
    for _, timer_id in ipairs(timers) do
        timer.Remove(timer_id)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"min_delay", "max_delay", "highlight_time"}) do
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