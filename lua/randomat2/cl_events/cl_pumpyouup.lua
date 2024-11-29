local EVENT = {}
EVENT.id = "pumpyouup"

local voteframe = nil
function EVENT:End()
    if IsValid(voteframe) then
        voteframe:Close()
    end
    hook.Remove("TTTSpeedMultiplier", "PumpYouUp_TTTSpeedMultiplier")
end

Randomat:register(EVENT)

net.Receive("PumpYouUpEventBegin", function()
    local buff = net.ReadUInt(4)
    local speed_factor = net.ReadFloat()
    voteframe = vgui.Create("DFrame")
    voteframe:SetPos(10, ScrH() - 800)
    voteframe:SetSize(200, 300)
    voteframe:SetTitle("Vote to Buff (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    voteframe:SetDraggable(false)
    voteframe:ShowCloseButton(false)
    voteframe:SetVisible(true)
    voteframe:SetDeleteOnClose(true)

    --Player List
    local list = vgui.Create("DListView", voteframe)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    local playerColumn = list:AddColumn("Players")
    list:AddColumn("Votes")

    for _, v in player.Iterator() do
        list:AddLine(v:Nick(), 0)
    end

    list:OnRequestResize(playerColumn, 125)

    list.OnRowSelected = function(lst, index, pnl)
        local ply = LocalPlayer()
        if ply:Alive() and not ply:IsSpec() then
            net.Start("PumpYouUpPlayerVoted")
            net.WriteString(pnl:GetColumnText(1))
            net.SendToServer()
        else
            ply:PrintMessage(HUD_PRINTTALK, "Dead people can't vote")
        end
    end

    net.Receive("PumpYouUpPlayerVoted", function()
        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in ipairs(list:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("PumpYouUpReset", function()
        for _, v in ipairs(list:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)

    local target
    net.Receive("PumpYouUpSetTarget", function()
        if net.ReadBool() then
            target = nil
        else
            target = net.ReadPlayer()
        end
    end)

    -- BUFF_SPEED
    if buff == 1 then
        hook.Add("TTTSpeedMultiplier", "PumpYouUp_TTTSpeedMultiplier", function(ply, mults)
            if ply ~= target then return end
            if not IsPlayer(target) or not target:Alive() or target:IsSpec() then return end
            table.insert(mults, speed_factor)
        end)
    end
end)