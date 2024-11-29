local EVENT = {}
EVENT.id = "gaseous"

function EVENT:Begin()
    local client = LocalPlayer()
    hook.Add("Think", "RdmtGaseousThink", function()
        Randomat:HandlePlayerSmoke(client, function(v)
            return v:Alive() and not v:IsSpec()
        end)
    end)
end

function EVENT:End()
    hook.Remove("Think", "RdmtGaseousThink")
end

Randomat:register(EVENT)