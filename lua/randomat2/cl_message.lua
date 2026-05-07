surface.CreateFont("RandomatHeader", {
    font = "Roboto",
    size = 48
})

surface.CreateFont("RandomatSmallMsg", {
    font = "Roboto",
    size = 32
})

local COLOR_DEFAULT = Color(255, 200, 0)

local active_messages = {}

local function ShowMessage()
    local big = net.ReadBool()
    local msg = net.ReadString()
    local length = net.ReadUInt(8)
    if length == 0 then length = 5 end

    local font_color = net.ReadColor()
    if not font_color or font_color.a == 0 then font_color = COLOR_DEFAULT end

    local tag = net.ReadString()
    if tag == "" then tag = "generic" end

    local panel = vgui.Create("DNotify")
    panel:SetLife(length)

    if big then
        surface.SetFont("RandomatHeader")
    else
        surface.SetFont("RandomatSmallMsg")
    end
    panel:SetSize(surface.GetTextSize(msg))
    panel:Center()
    if not big then
        panel:CenterVertical(0.55)
    end

    local bg = vgui.Create("DPanel", panel)
    bg:SetBackgroundColor(Color(0, 0, 0, 200))
    bg:Dock(FILL)

    local lbl = vgui.Create("DLabel", bg)
    lbl:SetText(msg)
    if big then
        lbl:SetFont("RandomatHeader")
    else
        lbl:SetFont("RandomatSmallMsg")
    end
    lbl:SetTextColor(font_color)
    lbl:SetWrap(true)
    lbl:Dock(FILL)

    lbl:SetText(msg)

    panel:AddItem(bg)

    active_messages[tag] = active_messages[tag] or {}
    table.insert(active_messages[tag], panel)
end

local function ClearMessages(all, tag)
    if all then
        for _, panels in pairs(active_messages) do
            for _, pnl in pairs(panels) do 
                if ValidPanel(pnl) then 
                    pnl:Remove()
                end
            end
        end
        active_messages = {}
    elseif tag and active_messages[tag] then
        for _, pnl in pairs(active_messages[tag]) do
            if ValidPanel(pnl) then
                pnl:Remove()
            end
        end
        active_messages[tag] = nil
    end
end

net.Receive("randomat_message", function()
    ShowMessage()
    surface.PlaySound("weapons/c4_initiate.mp3")
end)

net.Receive("randomat_message_silent", function()
    ShowMessage()
end)

net.Receive("randomat_message_clear", function()
    local all = net.ReadBool()
    local tag = net.ReadString()
    ClearMessages(all, tag)
end)