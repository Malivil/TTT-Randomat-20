local EVENT = {}
EVENT.id = "reversedemocracy"

local voteframe = nil

local function CloseFrame()
    if IsValid(voteframe) then
        voteframe:Close()
    end
end

function EVENT:Begin()
    voteframe = vgui.Create("DFrame")
    voteframe:SetPos(10, ScrH() - 800)
    voteframe:SetSize(200, 300)
    voteframe:SetTitle("Vote to Save (Hold " .. Key("+showscores", "tab"):lower() .. ")")
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
        -- Skip spectators who weren't in this round
        if (not v:Alive() or v:IsSpec()) and v:GetRole() == ROLE_NONE then continue end

        list:AddLine(v:Nick(), 0)
    end

    list:OnRequestResize(playerColumn, 125)

    list.OnRowSelected = function(lst, index, pnl)
        local ply = LocalPlayer()
        if ply:Alive() and not ply:IsSpec() then
            net.Start("ReverseDemocracyPlayerVoted")
            net.WriteString(pnl:GetColumnText(1))
            net.SendToServer()
        else
            ply:PrintMessage(HUD_PRINTTALK, "Dead people can't vote")
        end
    end

    net.Receive("ReverseDemocracyPlayerVoted", function()
        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in ipairs(list:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("ReverseDemocracyReset", function()
        for _, v in ipairs(list:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)
end

EVENT.End = CloseFrame

Randomat:register(EVENT)

net.Receive("ReverseDemocracyEventEnd", CloseFrame)