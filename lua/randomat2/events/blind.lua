local EVENT = {}

CreateConVar("randomat_blind_duration", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "The duration the players should be blinded for", 5, 60)

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

function EVENT:Begin(...)
    local params = ...
    local duration = GetConVar("randomat_blind_duration"):GetInt()
    -- Default to the duration passed as a paramter, if there is one
    if params ~= nil and params[1] ~= nil then
        duration = params[1]
    end
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
    for _, v in pairs(self:GetAlivePlayers()) do
        if Randomat:IsTraitorTeam(v) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"duration"}) do
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