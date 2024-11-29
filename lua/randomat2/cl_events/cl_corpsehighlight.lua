local halo = halo
local hook = hook

local EntsFindByClass = ents.FindByClass

local EVENT = {}
EVENT.id = "corpsehighlight"

function EVENT:Begin()
    hook.Add("PreDrawHalos", "RdmtCorpseHighlightHalos", function()
        local corpses = {}
        for k, v in ipairs(EntsFindByClass("prop_ragdoll")) do
            if IsValid(CORPSE.GetPlayer(v)) then
                corpses[k] = v
            end
        end

        halo.Add(corpses, Color(0, 255, 0), 0, 0, 1, true, true)
    end)
end

function EVENT:End()
    hook.Remove("PreDrawHalos", "RdmtCorpseHighlightHalos")
end

Randomat:register(EVENT)