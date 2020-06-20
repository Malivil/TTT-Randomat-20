net.Receive("RdmtFluSpeed", function()
    LocalPlayer():SetPData("RmdtSpeedModifier", net.ReadFloat())
end)