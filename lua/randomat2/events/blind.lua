local EVENT = {}

CreateConVar("randomat_blind_duration", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "The duration the players should be blinded for", 5, 60)

util.AddNetworkString("blindeventactive")

EVENT.Title = "Blind Traitors"
EVENT.Description = "All traitors have been blinded for " .. GetConVar("randomat_blind_duration"):GetInt() .. " seconds!"
EVENT.id = "blind"
EVENT.SingleUse = false
EVENT.Categories = {"biased_innocent", "biased", "moderateimpact"}

local function RemoveBlind()
    net.Start("blindeventactive")
    net.WriteBool(false)
    net.Broadcast()
end

local function GetDuration(duration)
    -- Default to the duration passed as a paramter, if there is one
    if not duration then
        duration = GetConVar("randomat_blind_duration"):GetInt()
    end
    return duration
end

function EVENT:BeforeEventTrigger(ply, options, duration)
    -- Update these in case the CVar or role names have been changed
    self.Title = "Blind " .. Randomat:GetRolePluralString(ROLE_TRAITOR)
    self.Description = "All " .. Randomat:GetRolePluralString(ROLE_TRAITOR) .. " have been blinded for " .. GetDuration(duration) .. " seconds!"
end

function EVENT:Begin(duration)
    net.Start("blindeventactive")
    net.WriteBool(true)
    net.Broadcast()

    timer.Create("RandomatBlindTimer", GetDuration(duration), 1, function()
        RemoveBlind()
    end)
end

function EVENT:End()
    RemoveBlind()
end

function EVENT:Condition()
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsTraitorTeam(v) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"duration"}) do
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