net.Receive("blindeventactive", function()
    if net.ReadBool() then
        hook.Add("HUDPaint", "BlindPlayer", function()
            local client = LocalPlayer()
            if IsValid(client) and client:Alive() then
                local role = client:GetRole()
                if role == ROLE_TRAITOR or role == ROLE_ASSASSIN or role == ROLE_HYPNOTIST or role == ROLE_DETRAITOR then
                    surface.SetDrawColor(0,0,0,255);
                    surface.DrawRect(0,0,surface.ScreenWidth(),surface.ScreenHeight());
                end
            end
        end)
    else
        hook.Remove("HUDPaint", "BlindPlayer")
    end
end)