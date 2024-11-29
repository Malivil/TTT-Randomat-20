local EVENT = {}
EVENT.id = "variety"

local damageType = "None"
function EVENT:Begin()
    hook.Add("TTTHUDInfoPaint", "RdmtVarietyTTTHUDInfoPaint", function(client, label_left, label_top, active_labels)
        if not IsPlayer(client) or not client:Alive() or client:IsSpec() then return end

        surface.SetFont("TabLarge")
        surface.SetTextColor(255, 255, 255, 230)

        local text = "Damage Type Disabled: " .. damageType
        local _, h = surface.GetTextSize(text)

        -- Move this up based on how many other labels here are
        if active_labels then
            label_top = label_top + (20 * #active_labels)
        else
            label_top = label_top + 20
        end

        surface.SetTextPos(label_left, ScrH() - label_top - h)
        surface.DrawText(text)

        -- Track that the label was added so others can position accurately
        if active_labels then
            table.insert(active_labels, "rdmtvariety")
        end
    end)
end

function EVENT:End()
    hook.Remove("TTTHUDInfoPaint", "RdmtVarietyTTTHUDInfoPaint")
    damageType = "None"
end

Randomat:register(EVENT)

net.Receive("RdmtVarietyTypeSet", function()
    damageType = net.ReadString()
end)