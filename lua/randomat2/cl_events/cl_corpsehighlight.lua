local halo = halo
local hook = hook
local net = net

local EntsFindByClass = ents.FindByClass

net.Receive("RdmtCorpseHighlightStart", function()
    hook.Add("PreDrawHalos", "RdmtCorpseHighlightHalos", function()
        local corpses = {}
        for k, v in ipairs(EntsFindByClass("prop_ragdoll")) do
            if IsValid(CORPSE.GetPlayer(v)) then
                corpses[k] = v
            end
        end

        halo.Add(corpses, Color(0, 255, 0), 0, 0, 1, true, true)
    end)
end)

net.Receive("RdmtCorpseHighlightEnd", function()
    hook.Remove("PreDrawHalos", "RdmtCorpseHighlightHalos")
end)