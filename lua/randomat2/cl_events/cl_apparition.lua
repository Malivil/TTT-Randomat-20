local EVENT = {}
EVENT.id = "apparition"

function EVENT:Begin()
    local client = LocalPlayer()
    self:AddHook("Think", function()
        Randomat:HandleEntitySmoke(ents.GetAll(), client, function(v)
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