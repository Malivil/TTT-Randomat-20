net.Receive("ElectionNominateBegin", function()
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 800)
    frame:SetSize(200, 300)
    frame:SetTitle("Nominate Presidents (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetVisible(true)
    frame:SetDeleteOnClose(true)

    --Player List
    local listView = vgui.Create("DListView", frame)
    listView:Dock(FILL)
    listView:SetMultiSelect(false)
    local playerColumn = listView:AddColumn("Players")
    listView:AddColumn("Votes")

    for _, v in ipairs(player.GetAll()) do
        -- Don't allow dead people, spectators, and detective-like players to get nominated
        if v:Alive() and not v:IsSpec() and not Randomat:IsDetectiveLike(v) then
            listView:AddLine(v:Nick(), 0)
        end
    end

    listView:OnRequestResize(playerColumn, 125)

    listView.OnRowSelected = function(lst, index, pnl)
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
        if not IsValid(listView) then return end

        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in ipairs(listView:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("ElectionNominateReset", function()
        if not IsValid(listView) then return end

        for _, v in ipairs(listView:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)

    net.Receive("ElectionNominateEnd", function()
        if IsValid(frame) then
            frame:Close()
        end
    end)
end)

net.Receive("ElectionVoteBegin", function()
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 800)
    frame:SetSize(200, 300)
    frame:SetTitle("Vote for President (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetVisible(true)
    frame:SetDeleteOnClose(true)

    --Player List
    local listView = vgui.Create("DListView", frame)
    listView:Dock(FILL)
    listView:SetMultiSelect(false)
    listView:AddColumn("Players")
    listView:AddColumn("Votes")

    --Add the two options
    listView:AddLine(net.ReadString(), 0)
    listView:AddLine(net.ReadString(), 0)

    listView.OnRowSelected = function(lst, index, pnl)
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
        if not IsValid(listView) then return end

        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in ipairs(listView:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("ElectionVoteReset", function()
        if not IsValid(listView) then return end

        for _, v in ipairs(listView:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)

    net.Receive("ElectionVoteEnd", function()
        if IsValid(frame) then
            frame:Close()
        end
    end)
end)