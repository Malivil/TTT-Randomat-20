local EVENT = {}

EVENT.Title = "Dead Men Tell No Tales"
EVENT.Description = "Prevents corpses from being searched"
EVENT.id = "search"

function EVENT:Begin()
    self:AddHook("TTTCanSearchCorpse", function(ply, rag, covert, long_range, was_traitor)
        if not ply:IsSpec() and ply:Alive() then
            ply:ChatPrint("This body refuses to tell you anything -- dead men tell no tales.")
        end
        return false
    end)
end

Randomat:register(EVENT)