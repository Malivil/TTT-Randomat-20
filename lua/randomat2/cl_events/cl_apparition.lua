net.Receive("RdmtApparitionBegin", function()
    local client = LocalPlayer()
    hook.Add("Think", "RdmtApparitionThink", function()
        Randomat:HandleEntitySmoke(ents.GetAll(), client, function(v)
            if v:GetNWBool("RdmtApparition", false) then
                v:SetNoDraw(true)
                v:SetRenderMode(RENDERMODE_NONE)
                v:SetNotSolid(true)
                return true
            end
            return false
        end)
    end)
end)

net.Receive("RdmtApparitionEnd", function()
    hook.Remove("Think", "RdmtApparitionThink")
end)