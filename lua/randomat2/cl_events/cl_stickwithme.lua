local EVENT = {}
EVENT.id = "stickwithme"

function EVENT:End()
    hook.Remove("PreDrawHalos", "RdmtStickWithMeHighlight")
end

Randomat:register(EVENT)

net.Receive("RdmtStickWithMeHighlightAdd", function()
    local target = net.ReadPlayer()
    hook.Add("PreDrawHalos", "RdmtStickWithMeHighlight", function()
        if not IsValid(target) or not target:Alive() or target:IsSpec() then return end
        halo.Add({target}, Randomat:GetRoleColor(ROLE_INNOCENT), 1, 1, 1, true, true)
    end)
end)