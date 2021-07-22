net.Receive("RdmtBooBegin", function()
    local client = LocalPlayer()
    hook.Add("HUDPaint", "RdmtBooUI", function()
        local width, height, margin = 200, 25, 20
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - (margin / 2 + height)

        local progress = client:GetNWInt("RdmtBooPower", 0)
        local progress_percentage = progress / 100

        local colors = {
            border = COLOR_WHITE,
            background = Color(17, 115, 135, 222),
            fill = Color(82, 226, 255, 255)
        };

        Randomat:PaintBar(8, x, y, width, height, colors, progress_percentage)

        draw.SimpleText("SCARE POWER", "HealthAmmo", ScrW() / 2, y,  Color(0, 0, 10, 200), TEXT_ALIGN_CENTER)
        draw.SimpleText("Press JUMP to scare your target (must be spectating a player)", "TabLarge", ScrW() / 2, y - margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
    end)
end)

net.Receive("RdmtBooEnd", function()
    hook.Remove("HUDPaint", "RdmtBooUI")
end)