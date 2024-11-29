local EVENT = {}
EVENT.id = "ragdoll"

local function BlockTargetID(ent, client, text, color)
    if not IsValid(ent) then return end

    if ent:GetNWBool("RdmtRagdollRagdoll", false) then
        return false
    end
end

function EVENT:Begin()
    self:AddHook("TTTTargetIDRagdollName", BlockTargetID)
    self:AddHook("TTTTargetIDEntityHintLabel", BlockTargetID)
    self:AddHook("TTTTargetIDPlayerHintText", BlockTargetID)
end

Randomat:register(EVENT)