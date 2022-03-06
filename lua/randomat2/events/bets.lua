local EVENT = {}

util.AddNetworkString("RdmtHedgeBetsBegin")
util.AddNetworkString("RdmtHedgeBetsEnd")
util.AddNetworkString("RdmtHedgeBetsPlayerBet")

EVENT.Title = "Hedge Your Bets"
EVENT.Description = "Dead players bet on who is going to live to the end. Winners are respawned to fight them."
EVENT.id = "bets"
EVENT.Type = EVENT_TYPE_VOTING
EVENT.Categories = {"spectator", "biased", "rolechange", "moderateimpact"}

local playerswhobet = {}
local bets = {}
function EVENT:Begin()
    playerswhobet = {}
    bets = {}
    for _, p in ipairs(self:GetDeadPlayers()) do
        net.Start("RdmtHedgeBetsBegin")
        net.Send(p)
    end

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        net.Start("RdmtHedgeBetsEnd")
        net.Send(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        if not playerswhobet[victim:SteamID64()] then
            net.Start("RdmtHedgeBetsBegin")
            net.Send(victim)
        end
    end)

    self:AddHook("TTTCheckForWin", function(fromrdmt)
        if fromrdmt then return end

        -- Gather the list of dead people who bet on a player who is still alive
        local living_bets = {}
        local living_bet_count = 0
        for _, p in ipairs(self:GetAlivePlayers()) do
            local sid = p:SteamID64()
            -- If this living player has bets on them
            if bets[sid] and #bets[sid] > 0 then
                -- Find all the valid ones representing dead players
                for _, v in ipairs(bets[sid]) do
                    if v ~= nil then
                        local ply = player.GetBySteamID64(v)
                        if IsValid(ply) and (not ply:Alive() or ply:IsSpec()) then
                            -- Save the opposite role to respawn the player as
                            if Randomat:IsTraitorTeam(p) then
                                living_bets[v] = ROLE_INNOCENT
                            elseif Randomat:IsInnocentTeam(p) then
                                living_bets[v] = ROLE_TRAITOR
                            -- If the living player is not an innocent or traitor, randomize what the dead plyer comes back as
                            else
                                living_bets[v] = math.random(0, 1) == 1 and ROLE_INNOCENT or ROLE_TRAITOR
                            end
                            living_bet_count = living_bet_count + 1
                        end
                    end
                end
            end
        end

        local result = hook.Run("TTTCheckForWin", true)
        -- If the round was supposed to end but someone won the bet, respawn them and delay the end of the round
        if result ~= WIN_NONE and living_bet_count > 0 then
            -- Respawn all the bet winners
            for sid, role in pairs(living_bets) do
                local ply = player.GetBySteamID64(sid)
                if IsValid(ply) and (not ply:Alive() or ply:IsSpec()) then
                    Randomat:SetRole(ply, role)
                    ply:PrintMessage(HUD_PRINTTALK, "You won your bet and have respawned. Good luck!")
                    ply:PrintMessage(HUD_PRINTCENTER, "You won your bet and have respawned. Good luck!")
                    ply:SpawnForRound(true)
                    local body = ply.server_ragdoll or ply:GetRagdollEntity()
                    if IsValid(body) then
                        body:Remove()
                    end
                end
            end
            SendFullStateUpdate()

            -- Remove the hook so this only happens once
            self:RemoveHook("TTTCheckForWin")
            return WIN_NONE
        end
    end)
end

function EVENT:End()
    net.Start("RdmtHedgeBetsEnd")
    net.Broadcast()
end

net.Receive("RdmtHedgeBetsPlayerBet", function(ln, ply)
    local sid = ply:SteamID64()
    for k, v in pairs(playerswhobet) do
        if k == sid and v ~= nil then
            ply:PrintMessage(HUD_PRINTTALK, "You have already bet.")
            return
        end
    end

    local bet_name = net.ReadString()
    local bet_sid = nil
    for _, v in ipairs(player.GetAll()) do
        if v:Nick() == bet_name then
            bet_sid = v:SteamID64()
            break
        end
    end

    if not bet_sid then
        ply:PrintMessage(HUD_PRINTTALK, "No player named " .. bet_name .. " found. Try again.")
        return
    end

    if not bets[bet_sid] then
        bets[bet_sid] = {}
    end
    table.insert(bets[bet_sid], sid)
    playerswhobet[sid] = bet_sid
end)

Randomat:register(EVENT)