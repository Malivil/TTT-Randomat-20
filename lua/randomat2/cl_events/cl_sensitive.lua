local sensitivity = nil

net.Receive("RdmtSetSensitivityValue", function()
    local value = net.ReadFloat()
    if value > 0 then
        sensitivity = value
    else
        sensitivity = nil
    end
end)

hook.Add("AdjustMouseSensitivity", "RdmtSensitiveChangeHook", function(default_sensitivity)
    return sensitivity
end)