local blindeventactive = 0

net.Receive("blindeventactive", function()
    if net.ReadBool() then
        blindeventactive = 1
    else
        blindeventactive = 0
    end
end)

function BlindPlayer()
    if blindeventactive == 1 and LocalPlayer():Alive() then
        local role = LocalPlayer():GetRole();
        if role == ROLE_TRAITOR or role == ROLE_ASSASSIN or role == ROLE_HYPNOTIST or role == ROLE_DETRAITOR then
            surface.SetDrawColor(0,0,0,255);
            surface.DrawRect(0,0,surface.ScreenWidth(),surface.ScreenHeight());
        end
    end
end

function TriggerBlind()
    net.Start("blindeventactive")
    net.WriteBool(true)
    net.Broadcast()

    local duration = GetConVar("randomat_blind_duration"):GetInt()

    timer.Create("RandomatBlindTimer", duration, 1, function()
        net.Start("blindeventactive")
        net.WriteBool(false)
        net.Broadcast()
    end)
end

function RemoveBlind()
    net.Start("blindeventactive")
    net.WriteBool(false)
    net.Broadcast()
end

hook.Add("HUDPaint", "BlindPlayer", BlindPlayer)