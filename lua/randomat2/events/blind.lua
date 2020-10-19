AddCSLuaFile()

local EVENT = {}

CreateConVar("randomat_blind_duration", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "The duration the players should be blinded for")

util.AddNetworkString("blindeventactive")

EVENT.Title = "All traitors have been blinded for "..GetConVar("randomat_blind_duration"):GetInt().." seconds!"
EVENT.AltTitle = "Blind Traitors"
EVENT.id = "blind"
EVENT.SingleUse = false

local function RemoveBlind()
    net.Start("blindeventactive")
    net.WriteBool(false)
    net.Broadcast()
end

function EVENT:Begin()
    local duration = GetConVar("randomat_blind_duration"):GetInt()
    EVENT.Title = "All traitors have been blinded for "..duration.." seconds!"

    net.Start("blindeventactive")
    net.WriteBool(true)
    net.Broadcast()

    timer.Create("RandomatBlindTimer", duration, 1, function()
        RemoveBlind()
    end)
end

function EVENT:End()
    RemoveBlind()
end

function EVENT:Condition()
    local x = 0
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_DETRAITOR then
            x = 1
        end
    end

    if x == 1 then
        return true
    else
        return false
    end
end


Randomat:register(EVENT)