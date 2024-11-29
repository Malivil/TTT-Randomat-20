local EVENT = {}
EVENT.id = "olympicsprint"

function EVENT:Begin()
    self:AddHook("TTTSprintStaminaPost",  function()
        -- Infinite sprint through fixed infinite stamina
        return 100
    end)
end

Randomat:register(EVENT)