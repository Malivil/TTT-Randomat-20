local EVENT = {}

EVENT.Title = "Dead Men Tell no Tales"
EVENT.Description = "Prevents corpses from being searched"
EVENT.id = "search"

function EVENT:Begin()
    self:AddHook("TTTCanSearchCorpse", function()
        return false
    end)
end

Randomat:register(EVENT)