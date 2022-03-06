local EVENT = {}

EVENT.Title = "Dead Men Tell No Tales"
EVENT.Description = "Prevents corpses from being searched"
EVENT.id = "search"
EVENT.Categories = {"biased", "moderateimpact"}

function EVENT:Begin()
    self:AddHook("TTTCanSearchCorpse", function(ply, rag, covert, long_range, was_traitor)
        -- If this player can loot credits and there are credits on the corpse, let the player loot them
        if ply.CanLootCredits and ply:CanLootCredits() then
            local credits = CORPSE.GetCredits(rag, 0)
            if credits > 0 then return end
        end

        if not ply:IsSpec() and ply:Alive() then
            ply:ChatPrint("This body refuses to tell you anything -- dead men tell no tales.")
        end
        return false
    end)
end

Randomat:register(EVENT)