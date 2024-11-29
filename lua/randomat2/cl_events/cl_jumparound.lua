local EVENT = {}
EVENT.id = "jumparound"

function EVENT:Begin()
    self:AddHook("StartCommand", function(ply, cmd)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:IsOnGround() then
            cmd:SetForwardMove(0)
            cmd:SetSideMove(0)
        end
    end)
end

Randomat:register(EVENT)