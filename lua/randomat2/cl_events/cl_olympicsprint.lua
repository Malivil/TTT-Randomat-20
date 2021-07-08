net.Receive("RdmtOlympicSprintBegin", function()
    hook.Add("TTTSprintStaminaPost", "RdmtOlympicSprintPost", function()
        -- Infinite sprint through fixed infinite stamina
        return 100
    end)
end)

net.Receive("RdmtOlympicSprintEnd", function()
    hook.Remove("TTTSprintStaminaPost", "RdmtOlympicSprintPost")
end)