local EVENT = {}
EVENT.id = "olympicsprint"

function EVENT:Begin()
    hook.Add("TTTSprintStaminaPost", "RdmtOlympicSprintPost", function()
        -- Infinite sprint through fixed infinite stamina
        return 100
    end)
end

function EVENT:End()
    hook.Remove("TTTSprintStaminaPost", "RdmtOlympicSprintPost")
end

Randomat:register(EVENT)