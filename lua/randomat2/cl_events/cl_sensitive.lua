local EVENT = {}
EVENT.id = "sensitive"

local sensitivity = nil
function EVENT:Begin()
    self:AddHook("AdjustMouseSensitivity", function(default_sensitivity)
        if sensitivity ~= nil then
            return sensitivity
        end
    end)
end

Randomat:register(EVENT)

net.Receive("RdmtSetSensitivityValue", function()
    local value = net.ReadFloat()
    if value > 0 then
        sensitivity = value
    else
        sensitivity = nil
    end
end)