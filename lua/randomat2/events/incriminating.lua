local EVENT = {}

CreateConVar("randomat_incriminating_timer_min", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The minimum time before the message is sent", 1, 120)
CreateConVar("randomat_incriminating_timer_max", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum time before the message is sent", 1, 120)

EVENT.Title = "Incriminating Evidence"
EVENT.Description = "Forces a random player to say something incriminating without their knowledge"
EVENT.id = "incriminating"
EVENT.StartSecret = true

util.AddNetworkString("RdmtIncriminatingMessage")

local messages = {}
table.insert(messages, "hey, gimme a credit")
table.insert(messages, "come here so we can double kill")
table.insert(messages, "just kill the detective already")
table.insert(messages, "quick, kill {PLAYER}")
table.insert(messages, "how is {PLAYER} still alive?")
table.insert(messages, "watch out, gonna use a thing")
table.insert(messages, "have you killed anyone yet?")
table.insert(messages, "why haven't we won yet?")
table.insert(messages, "where can i put this body?")
table.insert(messages, "hey, this body has credits on it")
table.insert(messages, "i'm out of credits")

function EVENT:Begin()
    -- Only include these if they target roles are enabled
    if ConVarExists("ttt_swapper_enabled") and GetConVar("ttt_swapper_enabled"):GetBool() then
        table.insert(messages, "i think {PLAYER} is a swapper")
    end
    if ConVarExists("ttt_deputy_enabled") and GetConVar("ttt_deputy_enabled"):GetBool() then
        table.insert(messages, "i think {PLAYER} is the deputy, kill them before they are promoted")
    end

    -- Get a random living player
    local target = self:GetAlivePlayers(true)[1]
    local delay = math.random(GetConVar("randomat_incriminating_timer_min"):GetInt(), GetConVar("randomat_incriminating_timer_max"):GetInt())
    timer.Create("IncriminatingDelay", delay, 1, function()
        local message = messages[math.random(1, #messages)]
        -- Replace the "{PLAYER}" placeholder
        if string.find(message, "{PLAYER}") then
            local players = self:GetAlivePlayers(true)
            local found = nil
            for _, p in ipairs(players) do
                if p ~= target then
                    found = p
                    break
                end
            end
            message = string.Replace(message, "{PLAYER}", found:Nick())
        end

        net.Start("RdmtIncriminatingMessage")
        net.WriteString(message)
        net.WriteEntity(target)
        net.Send(GetPlayerFilter(function(p) return p ~= target end))
    end)
end

function EVENT:End()
    timer.Remove("IncriminatingDelay")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer_min", "timer_max"}) do
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