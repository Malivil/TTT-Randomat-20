
local betframe = nil

net.Receive("RdmtHedgeBetsBegin", function()
    local ply = LocalPlayer()

    betframe = vgui.Create("DFrame")
    betframe:SetPos(10, ScrH() - 800)
    betframe:SetSize(200, 300)
    betframe:SetTitle("Place Your Bet (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    betframe:SetDraggable(false)
    betframe:ShowCloseButton(false)
    betframe:SetVisible(true)
    betframe:SetDeleteOnClose(true)

    --Player List
    local list = vgui.Create("DListView", betframe)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Players")

    for _, v in player.Iterator() do
        -- Skip spectators who weren't in this round
        if (not v:Alive() or v:IsSpec()) and v:GetRole() == ROLE_NONE then continue end
        -- Skip yourself
        if v == ply then continue end

        list:AddLine(v:Nick(), 0)
    end

    list.OnRowSelected = function(lst, index, pnl)
        if not ply:Alive() or ply:IsSpec() then
            local bet = pnl:GetColumnText(1)
            net.Start("RdmtHedgeBetsPlayerBet")
            net.WriteString(bet)
            net.SendToServer()
            ply:PrintMessage(HUD_PRINTTALK, "You bet on: " .. bet)
        else
            ply:PrintMessage(HUD_PRINTTALK, "Living people can't bet")
        end

        if IsValid(betframe) then
            betframe:Close()
            betframe = nil
        end
    end
end)

net.Receive("RdmtHedgeBetsEnd", function()
    if IsValid(betframe) then
        betframe:Close()
    end
end)