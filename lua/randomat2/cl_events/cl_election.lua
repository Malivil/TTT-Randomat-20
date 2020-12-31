net.Receive("ElectionNominateBegin", function()
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 800)
    frame:SetSize(200, 300)
    frame:SetTitle("Nominate Presidents (Hold " .. string.lower(Key("+showscores", "tab")) .. ")")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetVisible(true)
    frame:SetDeleteOnClose(true)

    --Player List
    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Players")
    list:AddColumn("Votes")

    for _, v in pairs(player.GetAll()) do
        -- Don't allow dead people, spectators, detectives, and detraitors to get nominated
        if v:Alive() and not v:IsSpec() and v:GetRole() ~= ROLE_DETECTIVE and v:GetRole() ~= ROLE_DETRAITOR then
            list:AddLine(v:Nick(), 0)
        end
    end

    list.OnRowSelected = function(lst, index, pnl)
        local ply = LocalPlayer()
        if ply:Alive() and not ply:IsSpec() then
            net.Start("ElectionNominateVoted")
            net.WriteString(pnl:GetColumnText(1))
            net.SendToServer()
        else
            ply:PrintMessage(HUD_PRINTTALK, "Dead people can't vote")
        end
    end

    net.Receive("ElectionNominateVoted", function()
        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in pairs(list:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("ElectionNominateReset", function()
        for _, v in pairs(list:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)

    net.Receive("ElectionNominateEnd", function()
        if frame ~= nil and IsValid(frame) then
            frame:Close()
        end
    end)
end)

net.Receive("ElectionVoteBegin", function()
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 800)
    frame:SetSize(200, 300)
    frame:SetTitle("Vote for President (Hold " .. string.lower(Key("+showscores", "tab")) .. ")")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetVisible(true)
    frame:SetDeleteOnClose(true)

    --Player List
    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Players")
    list:AddColumn("Votes")

    --Add the two options
    list:AddLine(net.ReadString(), 0)
    list:AddLine(net.ReadString(), 0)

    list.OnRowSelected = function(lst, index, pnl)
        local ply = LocalPlayer()
        if ply:Alive() and not ply:IsSpec() then
            net.Start("ElectionVoteVoted")
            net.WriteString(pnl:GetColumnText(1))
            net.SendToServer()
        else
            ply:PrintMessage(HUD_PRINTTALK, "Dead people can't vote")
        end
    end

    net.Receive("ElectionVoteVoted", function()
        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in pairs(list:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("ElectionVoteReset", function()
        for _, v in pairs(list:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)

    net.Receive("ElectionVoteEnd", function()
        if frame ~= nil and IsValid(frame) then
            frame:Close()
        end
    end)
end)