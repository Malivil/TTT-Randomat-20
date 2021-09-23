net.Receive("RdmtSpecBeesBegin", function()
    hook.Add("Think", "RdmtSpecBeesThink", function()
        for _, e in ipairs(ents.GetAll()) do
            if e:GetNWBool("RdmtSpecBee", false) then
                e:SetNotSolid(true)
            end
        end
    end)
end)

net.Receive("RdmtSpecBeesEnd", function()
    hook.Remove("Think", "RdmtSpecBeesThink")
end)