surface.CreateFont("RandomatHeader", {
    font = "Roboto",
    size = 48
})

surface.CreateFont("RandomatSmallMsg", {
    font = "Roboto",
    size = 32
})

local COLOR_DEFAULT = Color(255, 200, 0)

local function ShowMessage()
    local big = net.ReadBool()
    local msg = net.ReadString()
    local length = net.ReadUInt(8)
    if length == 0 then length = 5 end

    local font_color = net.ReadColor()
    if not font_color or font_color.a == 0 then font_color = COLOR_DEFAULT end

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
end

net.Receive("randomat_message", function()
    ShowMessage()
    surface.PlaySound("weapons/c4_initiate.mp3")
end)

net.Receive("randomat_message_silent", function()
    ShowMessage()
end)