local EVENT = {}

EVENT.Title = "Dead Men Tell ALL Tales"
EVENT.Description = "Allows dead players to text chat with the living"
EVENT.id = "deadchat"

function EVENT:Begin()
    GetConVar("ttt_limit_spectator_chat"):SetBool(false)
end

function EVENT:End()
    GetConVar("ttt_limit_spectator_chat"):SetBool(true)
end

function EVENT:Condition()
    return GetConVar("ttt_limit_spectator_chat"):GetBool()
end

Randomat:register(EVENT)