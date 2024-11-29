local EVENT = {}
EVENT.id = "trexvision"

local function IsPlayerValid(p)
    return IsPlayer(p) and p:Alive() and not p:IsSpec()
end

function EVENT:Begin()
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
end

function EVENT:End()
    hook.Remove("TTTTargetIDPlayerBlockIcon", "RdmtTRexVisionBlockTargetIcon")
    hook.Remove("TTTTargetIDPlayerBlockInfo", "RdmtTRexVisionBlockTargetInfo")
end

Randomat:register(EVENT)