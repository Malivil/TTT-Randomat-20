net.Receive("RdmtOurSecretHaloStart", function()
    local target = net.ReadPlayer()

    hook.Add("PreDrawHalos", "RdmtOurSecretHighlight", function()
        if not IsValid(target) or not target:Alive() or target:IsSpec() then return end
        local color = Randomat:GetRoleColor(target:GetRole())

        halo.Add({target}, color, 2, 2, 1, true, false)
    end)
end)

net.Receive("RdmtOurSecretHaloEnd", function()
    hook.Remove("PreDrawHalos", "RdmtOurSecretHighlight")
end)