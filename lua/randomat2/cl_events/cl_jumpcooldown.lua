surface.CreateFont("Cooldown", {
    font = "Trebuchet24",
    size = 22,
    weight = 600
})

net.Receive("JumpCooldownBegin", function()
    local cooldown = net.ReadUInt(8)
    local nextJump = 0
    hook.Add("StartCommand", "RdmtJumpCooldownCommandHook", function(ply, cmd)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        if cmd:KeyDown(IN_JUMP) then
            local now = CurTime()
            if nextJump > now then
                cmd:RemoveKey(IN_JUMP)
            -- Wait a short delay to allow the player to jump if they are just holding down the spacebar
            elseif nextJump + 0.25 < now then
                nextJump = now + cooldown
            end
        end
    end)

    if CRHUD and CRHUD.PaintBar then
        local margin = 10
        local width, height = 200, 25
        local x = ScrW() / 2 - width / 2
        local y = margin / 2 + height
        local colors = {
            background = Color(30, 60, 100, 222),
            fill = Color(75, 150, 255, 255)
        }
        hook.Add("HUDPaint", "RdmtJumpCooldownHUDPaintHook", function()
            local diff = nextJump - CurTime()
            if diff > 0 then
                CRHUD:PaintBar(8, x, y, width, height, colors, 1 - (diff / cooldown))
                draw.SimpleText("JUMP COOLDOWN", "Cooldown", ScrW() / 2, y + 1, COLOR_WHITE, TEXT_ALIGN_CENTER)
            end
        end)
    end
end)

net.Receive("JumpCooldownEnd", function()
    hook.Remove("StartCommand", "RdmtJumpCooldownCommandHook")
    hook.Remove("HUDPaint", "RdmtJumpCooldownHUDPaintHook")
end)