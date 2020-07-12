net.Receive("DemocracyEventBegin", function()
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 800)
    frame:SetSize(200, 300)
    frame:SetTitle("Open Scoreboard to Interact")
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
        if (v:Alive() and not v:IsSpec()) or not v:Alive() then
            list:AddLine(v:Nick(), 0)
        end
    end

    list.OnRowSelected = function(lst, index, pnl)
        local ply = LocalPlayer()
        if ply:Alive() and not ply:IsSpec() then
            net.Start("DemocracyPlayerVoted")
            net.WriteString(pnl:GetColumnText(1))
            net.SendToServer()
        else
            ply:PrintMessage(HUD_PRINTTALK, "Dead people can't vote")
        end
    end

    net.Receive("DemocracyPlayerVoted", function()
        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in pairs(list:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("DemocracyReset", function()
        for _, v in pairs(list:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)

    net.Receive("DemocracyEventEnd", function()
        frame:Close()
    end)
end)