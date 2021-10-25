net.Receive("RdmtDeadGiftBegin", function()
    local equip = Randomat:GetWeaponName(net.ReadString())
    local client = LocalPlayer()
    hook.Add("HUDPaint", "RdmtDeadGiftUI", function()
        local width, height, margin = 200, 25, 20
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - (margin / 2 + height)

        local progress = client:GetNWInt("RdmtDeadGiftPower", 0)
        local progress_percentage = progress / 100

        local colors = {
            border = COLOR_WHITE,
            background = Color(17, 115, 135, 222),
            fill = Color(82, 226, 255, 255)
        }

        Randomat:PaintBar(8, x, y, width, height, colors, progress_percentage)

        draw.SimpleText("GIFT POWER", "HealthAmmo", ScrW() / 2, y,  Color(0, 0, 10, 200), TEXT_ALIGN_CENTER)
        local target = client:GetObserverMode() ~= OBS_MODE_ROAMING and client:GetObserverTarget() or nil
        if IsPlayer(target) then
            draw.SimpleText("Press JUMP to give your target the '" .. equip .. "'", "TabLarge", ScrW() / 2, y - margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Press JUMP to drop your '" .. equip .. "' on the ground", "TabLarge", ScrW() / 2, y - margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
        end
    end)
end)

net.Receive("RdmtDeadGiftEnd", function()
    hook.Remove("HUDPaint", "RdmtDeadGiftUI")
end)