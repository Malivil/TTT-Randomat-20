local chooseTables = {}
local frames = 0

local function closeChooseFrame()
    local lastidx
    -- Frames not not necessarily stored in order when multiple are shown at once
    -- Find that last index since that will be the frame on top (visually)
    for i, _ in pairs(chooseTables) do
        lastidx = i
    end

    chooseTables[lastidx]:Close()
    chooseTables[lastidx] = nil
end

local function closeAllChooseFrames()
    for k, v in pairs(chooseTables) do
        v:Close()
        chooseTables[k] = nil
    end
end

local function openFrame(x)
    frames = frames + 1
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 500)
    frame:SetSize(200, 17 * x + 51)
    frame:SetTitle("Open Scoreboard to Interact")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetVisible(true)
    frame:SetDeleteOnClose(true)
    return frame
end

net.Receive("ChooseEventTrigger", function()
    local x = net.ReadInt(32)
    local tbl = net.ReadTable()
    local frame = openFrame(x)

    --Event List
    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Events")

    for _, v in pairs(tbl) do
        list:AddLine(v)
    end
    chooseTables[frames] = frame

    list.OnRowSelected = function(lst, index, pnl)
        net.Start("PlayerChoseEvent")
        net.WriteString(pnl:GetColumnText(1))
        net.SendToServer()
        closeChooseFrame()
    end

    net.Receive("ChooseEventEnd", function()
        if frame ~= nil then
            closeAllChooseFrames()
        end
    end)
end)

net.Receive("ChooseVoteTrigger", function()
    local x = net.ReadInt(32)
    local tbl = net.ReadTable()
    local frame = openFrame(x)

    --Event List
    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Events")
    list:AddColumn("Votes")

    for _, v in pairs(tbl) do
        list:AddLine(v, 0)
    end
    chooseTables[frames] = frame

    list.OnRowSelected = function(lst, index, pnl)
        net.Start("ChoosePlayerVoted")
        net.WriteString(pnl:GetColumnText(1))
        net.SendToServer()
    end

    net.Receive("ChooseEventEnd", function()
        closeAllChooseFrames()
    end)

    net.Receive("ChoosePlayerVoted", function()
        local votee = net.ReadString()
        for _, v in pairs(list:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, v:GetColumnText(2)+1)
            end
        end
    end)

    net.Receive("ChooseVoteEnd", function()
        closeAllChooseFrames()
    end)
end)