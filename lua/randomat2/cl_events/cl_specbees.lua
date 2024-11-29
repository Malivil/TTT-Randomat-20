local EVENT = {}
EVENT.id = "specbees"

function EVENT:Begin()
    hook.Add("PlayerBindPress", "RdmtSpecBeesPlayerBindPress", function(ply, bind, pressed)
        if not IsValid(ply) then return end
        -- Override these buttons so the bees can't mess themselves up
        if (bind == "+use" or bind == "+duck") and pressed and ply:IsSpec() then return true end
    end)

    hook.Add("Think", "RdmtSpecBeesThink", function()
        for _, e in ents.Iterator() do
            if IsValid(e) and e:GetNWBool("RdmtSpecBee", false) then
                e:SetNotSolid(true)
            end
        end
    end)
end

function EVENT:End()
    hook.Remove("PlayerBindPress", "RdmtSpecBeesPlayerBindPress")
    hook.Remove("Think", "RdmtSpecBeesThink")
end

Randomat:register(EVENT)