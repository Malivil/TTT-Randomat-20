local EVENT = {}
EVENT.id = "jumparound"

function EVENT:Begin()
    hook.Add("StartCommand", "RdmtJumpAroundCommandHook", function(ply, cmd)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:IsOnGround() then
            cmd:SetForwardMove(0)
            cmd:SetSideMove(0)
        end
    end)
end

function EVENT:End()
    hook.Remove("StartCommand", "RdmtJumpAroundCommandHook")
end

Randomat:register(EVENT)