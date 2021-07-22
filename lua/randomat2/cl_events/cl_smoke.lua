local smokers = {}

net.Receive("RdmtSmokeSignalsBegin", function()
    local client = LocalPlayer()
    hook.Add("HUDPaint", "RdmtSmokeSignalsUI", function()
        local width, height, margin = 200, 25, 20
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - (margin / 2 + height)

        local progress = client:GetNWInt("RdmtSmokeSignalsPower", 0)
        local progress_percentage = progress / 100

        local colors = {
            border = COLOR_WHITE,
            background = Color(17, 115, 135, 222),
            fill = Color(82, 226, 255, 255)
        };

        Randomat:PaintBar(8, x, y, width, height, colors, progress_percentage)

        draw.SimpleText("SMOKE POWER", "HealthAmmo", ScrW() / 2, y,  Color(0, 0, 10, 200), TEXT_ALIGN_CENTER)
        draw.SimpleText("Press JUMP to envelope your target in smoke (must be spectating a player)", "TabLarge", ScrW() / 2, y - margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
    end)

    hook.Add("Think", "RdmtSmokeSignalsThink", function()
        Randomat:HandlePlayerSmoke(client, function(v)
            return smokers[v:SteamID64()]
        end)
    end)
end)

net.Receive("RdmtSmokeSignalsAdd", function()
    smokers[net.ReadString()] = true
end)

net.Receive("RdmtSmokeSignalsRemove", function()
    smokers[net.ReadString()] = false
end)

net.Receive("RdmtSmokeSignalsEnd", function()
    smokers = {}
    hook.Remove("HUDPaint", "RdmtSmokeSignalsUI")
    hook.Remove("Think", "RdmtSmokeSignalsThink")
end)