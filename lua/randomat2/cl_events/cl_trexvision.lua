local function IsPlayerValid(p)
    return IsPlayer(p) and p:Alive() and not p:IsSpec()
end

net.Receive("RdmtTRexVisionBegin", function()
    hook.Add("TTTTargetIDPlayerBlockIcon", "RdmtTRexVisionBlockTargetIcon", function(ply, cli)
        if not IsPlayerValid(cli) or not IsPlayerValid(ply) then return end

        if ply:GetNWBool("RdmtInvisible") then
            return true
        end
    end)

    hook.Add("TTTTargetIDPlayerBlockInfo", "RdmtTRexVisionBlockTargetInfo", function(ply, cli)
        if not IsPlayerValid(cli) or not IsPlayerValid(ply) then return end

        if ply:GetNWBool("RdmtInvisible") then
            return true
        end
    end)
end)

net.Receive("RdmtTRexVisionEnd", function()
    hook.Remove("TTTTargetIDPlayerBlockIcon", "RdmtTRexVisionBlockTargetIcon")
    hook.Remove("TTTTargetIDPlayerBlockInfo", "RdmtTRexVisionBlockTargetInfo")
end)