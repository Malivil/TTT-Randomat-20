local EVENT = {}
EVENT.id = "gaseous"

function EVENT:Begin()
    self:AddHook("Think", function()
        Randomat:HandlePlayerSmoke(Randomat.Client, function(v)
            return v:Alive() and not v:IsSpec()
        end)
    end)
end

Randomat:register(EVENT)