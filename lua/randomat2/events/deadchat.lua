local EVENT = {}

EVENT.Title = "Dead Men Tell ALL Tales"
EVENT.Description = "Allows dead players to text chat with the living"
EVENT.id = "deadchat"
EVENT.Categories = {"spectator", "largeimpact"}

local limitConvar = nil
function EVENT:Begin()
    limitConvar = GetConVar("ttt_limit_spectator_chat") or GetConVar("ttt_spectators_chat_globally")
    limitConvar:SetBool(false)
end

function EVENT:End()
    if not limitConvar then return end

    limitConvar:SetBool(true)
    limitConvar = nil
end

function EVENT:Condition()
    return cvars.Bool("ttt_limit_spectator_chat", false) or cvars.Bool("ttt_spectators_chat_globally", false)
end

Randomat:register(EVENT)