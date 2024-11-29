local EVENT = {}
EVENT.id = "election"

local nominateframe = nil
local voteframe = nil

local function CloseNominateFrame()
    if IsValid(nominateframe) then
        nominateframe:Close()
    end
end
local function CloseVoteFrame()
    if IsValid(voteframe) then
        voteframe:Close()
    end
end

function EVENT:End()
    CloseNominateFrame()
    CloseVoteFrame()
end

Randomat:register(EVENT)

net.Receive("ElectionNominateBegin", function()
    nominateframe = vgui.Create("DFrame")
    nominateframe:SetPos(10, ScrH() - 800)
    nominateframe:SetSize(200, 300)
    nominateframe:SetTitle("Nominate Presidents (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    nominateframe:SetDraggable(false)
    nominateframe:ShowCloseButton(false)
    nominateframe:SetVisible(true)
    nominateframe:SetDeleteOnClose(true)

    -- Player List
    local listView = vgui.Create("DListView", nominateframe)
    listView:Dock(FILL)
    listView:SetMultiSelect(false)
    local playerColumn = listView:AddColumn("Players")
    listView:AddColumn("Votes")

    for _, v in player.Iterator() do
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

    net.Receive("ElectionNominateEnd", CloseNominateFrame)
end)

net.Receive("ElectionVoteBegin", function()
    voteframe = vgui.Create("DFrame")
    voteframe:SetPos(10, ScrH() - 800)
    voteframe:SetSize(200, 300)
    voteframe:SetTitle("Vote for President (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    voteframe:SetDraggable(false)
    voteframe:ShowCloseButton(false)
    voteframe:SetVisible(true)
    voteframe:SetDeleteOnClose(true)

    -- Player List
    local listView = vgui.Create("DListView", voteframe)
    listView:Dock(FILL)
    listView:SetMultiSelect(false)
    listView:AddColumn("Players")
    listView:AddColumn("Votes")

    -- Add the two options
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

    net.Receive("ElectionVoteEnd", CloseVoteFrame)
end)