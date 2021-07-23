local healing = {}

net.Receive("RdmtSpecBuffBegin", function()
    healing = {}
    local heal_power = net.ReadUInt(8)
    local fast_power = net.ReadUInt(8)
    local slow_power = net.ReadUInt(8)
    local slap_power = net.ReadUInt(8)
    local client = LocalPlayer()
    hook.Add("HUDPaint", "RdmtSpecBuffUI", function()
        local max_power = 100
        local width, height, margin = 200, 25, 20
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - (margin / 2 + height)

        local current_power = client:GetNWInt("RdmtSpecBuffPower", 0)
        local progress_percentage = current_power / max_power

        local colors = {
            border = COLOR_WHITE,
            background = Color(17, 115, 135, 222),
            fill = Color(82, 226, 255, 255)
        };

        Randomat:PaintBar(8, x, y, width, height, colors, progress_percentage)

        draw.SimpleText("BUFF POWER", "HealthAmmo", ScrW() / 2, y,  Color(0, 0, 10, 200), TEXT_ALIGN_CENTER)

        local command_count = 0
        if fast_power > 0 then
            command_count = command_count + 1
        end
        if slow_power > 0 then
            command_count = command_count + 1
        end
        if heal_power > 0 then
            command_count = command_count + 1
        end
        if slap_power > 0 then
            command_count = command_count + 1
        end

        local current_command = 1
        -- Make the player faster
        if fast_power > 0 then
            local percentage = math.Round(100 * (fast_power / max_power))
            draw.SimpleText("FORWARD: Move faster (" .. percentage .. "%)", "TabLarge", ScrW() / 4 + ((ScrW() / (2 * (command_count + 1))) * current_command), y - margin, current_power >= fast_power and COLOR_GREEN or COLOR_RED, TEXT_ALIGN_CENTER)
            current_command = current_command + 1
        end

        -- Make the player slower
        if slow_power > 0 then
            local percentage = math.Round(100 * (slow_power / max_power))
            draw.SimpleText("BACKWARD: Move slower (" .. percentage .. "%)", "TabLarge", ScrW() / 4 + ((ScrW() / (2 * (command_count + 1))) * current_command), y - margin, current_power >= slow_power and COLOR_GREEN or COLOR_RED, TEXT_ALIGN_CENTER)
            current_command = current_command + 1
        end

        -- Heal
        if heal_power > 0 then
            local percentage = math.Round(100 * (heal_power / max_power))
            draw.SimpleText("LEFT: Heal target (" .. percentage .. "%)", "TabLarge", ScrW() / 4 + ((ScrW() / (2 * (command_count + 1))) * current_command), y - margin, current_power >= heal_power and COLOR_GREEN or COLOR_RED, TEXT_ALIGN_CENTER)
            current_command = current_command + 1
        end

        -- Slap
        if slap_power > 0 then
            local percentage = math.Round(100 * (slap_power / max_power))
            draw.SimpleText("RIGHT: Slap target (" .. percentage .. "%)", "TabLarge", ScrW() / 4 + ((ScrW() / (2 * (command_count + 1))) * current_command), y - margin, current_power >= slap_power and COLOR_GREEN or COLOR_RED, TEXT_ALIGN_CENTER)
            current_command = current_command + 1
        end
    end)

    hook.Add("Think", "RdmtSpecBuffThink", function()
        Randomat:HandlePlayerSmoke(client, function(v)
            return healing[v:SteamID64()]
        end, COLOR_GREEN)
    end)
end)

net.Receive("RdmtSpecBuffHealStart", function()
    healing[net.ReadString()] = true
end)

net.Receive("RdmtSpecBuffHealEnd", function()
    healing[net.ReadString()] = false
end)

net.Receive("RdmtSpecBuffEnd", function()
    healing = {}
    hook.Remove("HUDPaint", "RdmtSpecBuffUI")
    hook.Remove("Think", "RdmtSpecBuffThink")
end)