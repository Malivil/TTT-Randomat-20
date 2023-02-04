net.Receive("RdmtSpecBeesBegin", function()
    hook.Add("PlayerBindPress", "RdmtSpecBeesPlayerBindPress", function(ply, bind, pressed)
        if not IsValid(ply) then return end
        -- Override these buttons so the bees can mess themselves up
        if (bind == "+use" or bind == "+duck") and pressed and ply:IsSpec() then return true end
    end)

    hook.Add("Think", "RdmtSpecBeesThink", function()
        for _, e in ipairs(ents.GetAll()) do
            if e:GetNWBool("RdmtSpecBee", false) then
                e:SetNotSolid(true)
            end
        end
    end)
end)

net.Receive("RdmtSpecBeesEnd", function()
    hook.Remove("PlayerBindPress", "RdmtSpecBeesPlayerBindPress")
    hook.Remove("Think", "RdmtSpecBeesThink")
end)