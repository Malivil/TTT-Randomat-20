local EVENT = {}
EVENT.id = "flu"

function EVENT:End()
    Randomat:RemoveSpeedMultiplier("RdmtFluSpeed")
end

Randomat:register(EVENT)