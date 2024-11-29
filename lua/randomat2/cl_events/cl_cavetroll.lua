local EVENT = {}
EVENT.id = "cavetroll"

function EVENT:End()
    hook.Remove("TTTSprintStaminaPost", "RdmtCaveTrollSprintPost")
end

Randomat:register(EVENT)

net.Receive("RdmtCaveTrollBegin", function()
    hook.Add("TTTSprintStaminaPost", "RdmtCaveTrollSprintPost", function()
        -- Infinite sprint through fixed infinite stamina
        return 100
    end)
end)