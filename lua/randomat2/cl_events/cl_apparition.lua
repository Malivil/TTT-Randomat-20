local EVENT = {}
EVENT.id = "apparition"

function EVENT:Begin()
    self:AddHook("Think", function()
        Randomat:HandleEntitySmoke(ents.GetAll(), Randomat.Client, function(v)
            if v:GetNWBool("RdmtApparition", false) then
                v:SetNoDraw(true)
                v:SetRenderMode(RENDERMODE_NONE)
                v:SetNotSolid(true)
                return true
            end
            return false
        end)
    end)
end

Randomat:register(EVENT)