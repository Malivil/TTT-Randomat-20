local chooseTables = {}
local frames = 0

local function closeFrame(frame, idx)
    if frame ~= nil then
        frame:Close()
        chooseTables[idx] = nil
    end
end

local function closeChooseFrame()
    if #chooseTables == 0 then return end

    local lastidx
    -- Frames not not necessarily stored in order when multiple are shown at once
    -- Find that last index since that will be the frame on top (visually)
    for i, _ in pairs(chooseTables) do
        lastidx = i
    end

    local frame = chooseTables[lastidx]
    closeFrame(frame, lastidx)
end

local function closeAllChooseFrames()
    for k, v in pairs(chooseTables) do
        closeFrame(v, k)
    end
end

local function openFrame(x)
    frames = frames + 1
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 500)
    frame:SetSize(200, 17 * x + 51)
    frame:SetTitle("Choose an Event (Hold " .. string.lower(Key("+showscores", "tab")) .. ")")
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
        closeAllChooseFrames()
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