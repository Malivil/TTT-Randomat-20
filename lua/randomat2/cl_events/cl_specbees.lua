local EVENT = {}
EVENT.id = "specbees"

function EVENT:Begin()
    self:AddHook("PlayerBindPress", function(ply, bind, pressed)
        if not IsValid(ply) then return end
        -- Override these buttons so the bees can't mess themselves up
        if (bind == "+use" or bind == "+duck") and pressed and ply:IsSpec() then return true end
    end)

    self:AddHook("Think", function()
        for _, e in ents.Iterator() do
            if IsValid(e) and e:GetNWBool("RdmtSpecBee", false) then
                e:SetNotSolid(true)
            end
        end
    end)
end

Randomat:register(EVENT)