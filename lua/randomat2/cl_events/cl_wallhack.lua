local function IsTargetHighlighted(ply, target)
    return ply.IsTargetHighlighted and ply:IsTargetHighlighted(target)
end

net.Receive("haloeventtrigger", function()
    local client = LocalPlayer()
    hook.Add("PreDrawHalos", "RandomatHalos", function()
        local alivePlys = {}
        for k, v in ipairs(player.GetAll()) do
            if v:Alive() and not v:IsSpec() and not IsTargetHighlighted(client, v) then
                alivePlys[k] = v
            end
        end

        halo.Add(alivePlys, Color(0,255,0), 0, 0, 1, true, true)
    end)
end)

net.Receive("haloeventend", function()
    hook.Remove("PreDrawHalos", "RandomatHalos")
end)