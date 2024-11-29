local EVENT = {}
EVENT.id = "gaseous"

function EVENT:Begin()
    local client = LocalPlayer()
    self:AddHook("Think", function()
        Randomat:HandlePlayerSmoke(client, function(v)
            return v:Alive() and not v:IsSpec()
        end)
    end)
end

Randomat:register(EVENT)