local EVENT = {}
EVENT.id = "ragdoll"

local function BlockTargetID(ent, client, text, color)
    if not IsValid(ent) then return end

    if ent:GetNWBool("RdmtRagdollRagdoll", false) then
        return false
    end
end

function EVENT:Begin()
    hook.Add("TTTTargetIDRagdollName", "RdmtRagdollTTTTargetIDRagdollName", BlockTargetID)
    hook.Add("TTTTargetIDEntityHintLabel", "RdmtRagdollTTTTargetIDEntityHintLabel", BlockTargetID)
    hook.Add("TTTTargetIDPlayerHintText", "RdmtRagdollTTTTargetIDPlayerHintText", BlockTargetID)
end

function EVENT:End()
    hook.Remove("TTTTargetIDRagdollName", "RdmtRagdollTTTTargetIDRagdollName")
    hook.Remove("TTTTargetIDEntityHintLabel", "RdmtRagdollTTTTargetIDEntityHintLabel")
    hook.Remove("TTTTargetIDPlayerHintText", "RdmtRagdollTTTTargetIDPlayerHintText")
end

Randomat:register(EVENT)