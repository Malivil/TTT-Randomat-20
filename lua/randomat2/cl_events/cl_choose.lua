local chooseTables = {}
local frames = 0

local function closeFrame(frame, idx)
    if frame ~= nil then
        frame:Close()
        chooseTables[idx] = nil
    end
end

local function closeChooseFrame()
    local lastidx = nil
    -- Frames not not necessarily stored in order when multiple are shown at once
    -- Find that last index since that will be the frame on top (visually)
    for i, f in pairs(chooseTables) do
        if f then
            lastidx = i
        end
    end

    if lastidx then
        local frame = chooseTables[lastidx]
        closeFrame(frame, lastidx)
    end
end

local function closeAllChooseFrames()
    for k, v in pairs(chooseTables) do
        closeFrame(v, k)
    end
end

local function openFrame(x, vote)
    frames = frames + 1
    local frame = vgui.Create("DFrame")
    frame:SetPos(10, ScrH() - 500)

    local width = 250
    if vote then width = 325 end
    frame:SetSize(width, 17 * x + 51)
    frame:SetTitle("Choose an Event (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetVisible(true)
    frame:SetDeleteOnClose(true)
    return frame
end

net.Receive("ChooseEventTrigger", function()
    local x = net.ReadInt(32)
    local tbl = net.ReadTable(true)
    local frame = openFrame(x)

    --Event List
    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Events")

    for _, v in pairs(tbl) do
        list:AddLine(v.title, v.id)
    end
    chooseTables[frames] = frame

    list.OnRowSelected = function(lst, index, pnl)
        net.Start("ChoosePlayerChose")
        net.WriteString(pnl:GetColumnText(2))
        net.SendToServer()
        closeChooseFrame()
    end
end)

net.Receive("ChooseVoteTrigger", function()
    local x = net.ReadInt(32)
    local tbl = net.ReadTable(true)
    local frame = openFrame(x, true)

    --Event List
    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    local eventColumn = list:AddColumn("Events")
    list:AddColumn("Votes")

    for _, v in pairs(tbl) do
        list:AddLine(v.title, 0, v.id)
    end

    list:OnRequestResize(eventColumn, 250)

    chooseTables[frames] = frame

    list.OnRowSelected = function(lst, index, pnl)
        net.Start("ChoosePlayerVoted")
        net.WriteString(pnl:GetColumnText(3))
        net.SendToServer()
    end

    net.Receive("ChoosePlayerVoted", function()
        local votee = net.ReadString()
        for _, v in ipairs(list:GetLines()) do
            if v:GetColumnText(3) == votee then
                v:SetColumnText(2, v:GetColumnText(2) + 1)
            end
        end
    end)
end)

net.Receive("ChooseEventEnd", function()
    closeAllChooseFrames()
end)