local EVENT = {}

EVENT.Title = "Honey, I shrunk the terrorists"
EVENT.id = "shrink"

CreateConVar("randomat_shrink_scale", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The shrinking scale factor")

function EVENT:Begin()
    local sc = GetConVar("randomat_shrink_scale"):GetFloat() --scale factor
    for _, ply in pairs(self:GetAlivePlayers()) do
        ply:SetStepSize(ply:GetStepSize()*sc)
        ply:SetModelScale(ply:GetModelScale()*sc, 1)
        ply:SetViewOffset(ply:GetViewOffset()*sc)
        ply:SetViewOffsetDucked(ply:GetViewOffsetDucked()*sc)

        local a, b = ply:GetHull()
        ply:SetHull(a*sc, b*sc)

        a, b = ply:GetHullDuck()
        ply:SetHullDuck(a*sc, b*sc)

        ply:SetNWFloat("RmdtSpeedModifier", math.Clamp(ply:GetStepSize()/9, 0.25, 1) * ply:GetNWFloat("RmdtSpeedModifier", 1))
    end

    timer.Create("RdmtTimerShrinkHp", 1, 0, function()
        for _, ply in pairs(self:GetAlivePlayers()) do
            local rat = ply:GetStepSize()/18
            if ply:Health() > math.floor(rat*100) then
                ply:SetHealth(math.floor(rat*100))
            end
            ply:SetMaxHealth(math.floor(rat*100))
        end
    end)
end

function EVENT:End()
    for _, ply in pairs(player.GetAll()) do
        ply:SetModelScale(1, 1)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0, 0, 32))
        ply:ResetHull()
        ply:SetStepSize(18)
        ply:SetNWFloat("RmdtSpeedModifier", 1)
    end
    timer.Remove("RdmtTimerShrinkHp")
end

Randomat:register(EVENT)