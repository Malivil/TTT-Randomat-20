local EVENT = {}

util.AddNetworkString("PumpYouUpEventBegin")
util.AddNetworkString("PumpYouUpEventEnd")
util.AddNetworkString("PumpYouUpPlayerVoted")
util.AddNetworkString("PumpYouUpReset")
util.AddNetworkString("PumpYouUpSetTarget")

CreateConVar("randomat_pumpyouup_buff", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Which buff the target should get", 0, 3)
CreateConVar("randomat_pumpyouup_damage_scale", 1.1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Target damage modifier (1.1 == 110% or a 10% bonus)", 0.05, 3)
CreateConVar("randomat_pumpyouup_speed_factor", 1.2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Target speed modifier (1.1 == 110% or a 10% bonus)", 0.05, 3)
CreateConVar("randomat_pumpyouup_regen_timer", 0.66, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How often (in seconds) the target should be healed", 0, 5)
CreateConVar("randomat_pumpyouup_shield_factor", 0.25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Percent less damage the target should take", 0.05, 1)
CreateConVar("randomat_pumpyouup_allow_self_vote", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to allow players to vote for themselves")
CreateConVar("randomat_pumpyouup_show_votes", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show when a target is voted for in chat")
CreateConVar("randomat_pumpyouup_show_votes_anon", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to hide who voted in chat")

EVENT.Title = "Pump You Up"
EVENT.Description = "Vote to buff a player. Votes can be changed at any time"
EVENT.id = "pumpyouup"
EVENT.Type = EVENT_TYPE_VOTING
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

local BUFF_DAMAGE = 0
local BUFF_SPEED = 1
local BUFF_REGEN = 2
local BUFF_SHIELD = 3

local playervotes = {}
local votableplayers = {}
local playersvoted = {}
local target = nil

function EVENT:Begin()
    local buff = GetConVar("randomat_pumpyouup_buff"):GetInt()
    local speed_factor = GetConVar("randomat_pumpyouup_speed_factor"):GetFloat()
    net.Start("PumpYouUpEventBegin")
    net.WriteUInt(buff, 4)
    net.WriteFloat(speed_factor)
    net.Broadcast()

    playervotes = {}
    votableplayers = {}
    playersvoted = {}

    for k, v in ipairs(self:GetAlivePlayers()) do
        votableplayers[k] = v
        playervotes[k] = 0
    end

    if buff == BUFF_DAMAGE then
        EVENT.Description = "Vote to buff a player's damage."
        local damage_scale = GetConVar("randomat_pumpyouup_damage_scale"):GetFloat()
        self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
            if not IsPlayer(ply) then return end
            local atk = dmginfo:GetAttacker()
            if not IsPlayer(atk) or atk ~= target then return end

            dmginfo:ScaleDamage(damage_scale)
        end)
    elseif buff == BUFF_SPEED then
        EVENT.Description = "Vote to buff a player's speed."
        self:AddHook("TTTSpeedMultiplier", function(ply, mults)
            if ply ~= target then return end
            if not IsPlayer(target) or not target:Alive() or target:IsSpec() then return end
            table.insert(mults, speed_factor)
        end)
    elseif buff == BUFF_REGEN then
        EVENT.Description = "Vote to buff a player with health regen."
        timer.Create("PumpYouUpRegen", 0.66, 0, function()
            if not IsPlayer(target) or not target:Alive() or target:IsSpec() then return end

            local hp = target:Health()
            if hp < target:GetMaxHealth() then
                target:SetHealth(hp + 1)
            end
        end)
    elseif buff == BUFF_SHIELD then
        EVENT.Description = "Vote to buff a player's damage resistance."
        local shield_factor = GetConVar("randomat_pumpyouup_shield_factor"):GetFloat()
        self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
            if not IsPlayer(ply) or ply ~= target then return end
            dmginfo:ScaleDamage(1 - shield_factor)
        end)
    end

    EVENT.Description = EVENT.Description .. " Votes can be changed at any time"
end

function EVENT:End()
    net.Start("PumpYouUpEventEnd")
    net.Broadcast()
    timer.Remove("PumpYouUpRegen")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"buff", "damage_scale", "speed_factor", "regen_timer", "shield_factor"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "buff" and 0 or 2
            })
        end
    end

    local checks = {}
    for _, v in ipairs({"allow_self_vote", "show_votes", "show_votes_anon"}) do
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

net.Receive("PumpYouUpPlayerVoted", function(ln, ply)
    local votee = net.ReadString()
    if not GetConVar("randomat_pumpyouup_allow_self_vote"):GetBool() and ply:Nick() == votee then
        ply:PrintMessage(HUD_PRINTTALK, "You can't vote for yourself.")
        return
    end

    local num
    local prev_vote = nil
    local prev_vote_num = 0
    for k, v in pairs(votableplayers) do
        -- Find which player was voted for
        if v:Nick() == votee then
            -- If this player already voted, find their previous vote and remove it
            if playersvoted[ply] then
                prev_vote = playersvoted[ply]:Nick()
                -- If this player's vote didn't change, just don't do anything
                if v:Nick() == prev_vote then
                    return
                end

                for k2, v2 in pairs(votableplayers) do
                    if v2:Nick() == prev_vote then
                        playervotes[k2] = playervotes[k2] - 1
                        prev_vote_num = playervotes[k2]
                        break
                    end
                end
            end
            -- Save this player's vote target
            playersvoted[ply] = v

            if GetConVar("randomat_pumpyouup_show_votes"):GetBool() then
                local anon = GetConVar("randomat_pumpyouup_show_votes_anon"):GetBool()
                local name
                if anon then
                    name = "Someone"
                else
                    name = ply:Nick()
                end
                Randomat:SendChatToAll(name .. " has voted to buff " .. votee)
            end

            playervotes[k] = playervotes[k] + 1
            num = playervotes[k]
            break
        end
    end

    net.Start("PumpYouUpPlayerVoted")
        net.WriteString(votee)
        net.WriteInt(num, 32)
    net.Broadcast()

    -- If a vote was removed, be sure to update that as well
    if prev_vote then
        net.Start("PumpYouUpPlayerVoted")
            net.WriteString(prev_vote)
            net.WriteInt(prev_vote_num, 32)
        net.Broadcast()
    end

    -- Figure out who has the most votes
    local max_index
    local max_votes = -1
    for k, v in pairs(playervotes) do
        if v == 0 then continue end

        if v > max_votes then
            max_index = k
            max_votes = v
        -- Don't allow ties
        elseif v == max_votes then
            max_index = nil
            max_votes = nil
            break
        end
    end

    -- Set the new target based on votes (ties mean nobody wins)
    local message
    local new_target = nil
    if not max_votes then
        message = "There is a tie, so nobody gets the buff!"
    else
        new_target = votableplayers[max_index]
        message = new_target:Nick() .. " has the most votes!"
    end

    -- Only perform updates and announcements when the target actually changes
    if target ~= new_target then
        target = new_target
        Randomat:SendChatToAll(message)
        Randomat:SmallNotify(message)

        net.Start("PumpYouUpSetTarget")
            net.WriteBool(IsPlayer(target))
            net.WriteEntity(target)
        net.Broadcast()
    end
end)

Randomat:register(EVENT)