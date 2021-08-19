net.Receive("RdmtCaveTrollBegin", function()
    hook.Add("TTTSprintStaminaPost", "RdmtOlympicSprintPost", function()
        -- Infinite sprint through fixed infinite stamina
        return 100
    end)
end)

net.Receive("RdmtCaveTrollEnd", function()
    hook.Remove("TTTSprintStaminaPost", "RdmtOlympicSprintPost")
end)