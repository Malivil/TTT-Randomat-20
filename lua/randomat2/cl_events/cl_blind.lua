net.Receive("blindeventactive", function()
    if net.ReadBool() then
        hook.Add("HUDPaint", "BlindPlayer", function()
            local client = LocalPlayer()
            if IsValid(client) and client:Alive() and Randomat:IsTraitorTeam(client) then
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, 0, surface.ScreenWidth(), surface.ScreenHeight())
            end
        end)
    else
        hook.Remove("HUDPaint", "BlindPlayer")
    end
end)