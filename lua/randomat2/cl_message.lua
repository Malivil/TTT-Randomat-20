local math = math
local surface = surface
local table = table
local vgui = vgui

local MathMax = math.max
local TableInsert = table.insert
local TableRemove = table.remove

surface.CreateFont("RandomatHeader", {
    font = "Roboto",
    size = 48
})

surface.CreateFont("RandomatSmallMsg", {
    font = "Roboto",
    size = 32
})

local createdFonts = {}

local function BuildFormattedHeaderFont(bold, italic, underline, strikeout, shadow, outline)
    local key = (bold and "B" or "") .. (italic and "I" or "") .. (underline and "U" or "") .. (strikeout and "St" or "") .. (shadow and "Sh" or "") .. (outline and "O" or "")
    local name = "RandomatHeaderFont_" .. (key == "" and "Normal" or key)

    if not createdFonts[name] then
        surface.CreateFont(name, {
            font      = "Roboto",
            size      = 48,
            weight    = bold and 700 or 500,
            italic    = italic or false,
            outline   = outline or false,
        })
        createdFonts[name] = true
    end

    return name
end

local function BuildFormattedHeader(segments)
    local originX = ScrW() / 2
    local originY = ScrH() / 2

    local padding = 4

    local msgW = 0 
    local msgH = 0

    for _, segmentData in ipairs(segments) do
        if segmentData.width then
            msgW = msgW + segmentData.width
        end

        if segmentData.height and segmentData.height > msgH then
            msgH = segmentData.height
        end
    end

    local msgX = originX - msgW / 2
    local msgY = originY - msgH / 2

    local bgW = msgW + 2 + padding
    local bgH = msgH + 2 + padding
    local bgX = originX - bgW / 2
    local bgY = originY - bgH / 2

    local panel = vgui.Create("DNotify")
    local length = 10
    panel:SetLife(length)

    panel:SetSize(msgW, msgH)
    panel:Center()

    local bg = vgui.Create("DPanel", panel)
    bg:SetBackgroundColor(Color(0, 0, 0, 200))
    bg:Dock(FILL)

    local content = vgui.Create("DPanel", bg)
    content:SetSize(msgW, msgH)
    content:SetBackgroundColor(Color(0, 0, 0, 200))
    content:Dock(FILL)

    function content:Paint(w, h)
        local segX = 0

        for _, seg in ipairs(segments) do
            surface.SetFont(seg.font)
            surface.SetTextColor(Color(255, 200, 0))
            surface.SetTextPos(segX, 0)
            surface.DrawText(seg.text)

            if string.find(seg.font, "St") then
                surface.SetDrawColor(255, 200, 0)

                local startSpace = nil
                local endSpace = nil
                local bothSpace = nil
                local startOffset = 0

                if string.sub(seg.text, 1, 1) == " " then startSpace = true end
                if string.sub(seg.text, -1) == " " then endSpace = true end
                if startSpace and endSpace then bothSpace = true end

                local spaceW, _ = surface.GetTextSize(" ")

                local blankLength = 0
                if bothSpace then 
                    blankLength = 2 * spaceW
                elseif startSpace or endSpace then 
                    blankLength = spaceW 
                end

                local lineY = 0 + (0.55 * seg.height)
                local lineWidth = seg.width - blankLength

                if startSpace then startOffset = spaceW end

                surface.DrawRect(segX + startOffset, lineY, lineWidth, 3)
            end

            if string.find(seg.font, "U") then
                surface.SetDrawColor(255, 200, 0)

                local startSpace = nil
                local endSpace = nil
                local bothSpace = nil
                local startOffset = 0

                if string.sub(seg.text, 1, 1) == " " then startSpace = true end
                if string.sub(seg.text, -1) == " " then endSpace = true end
                if startSpace and endSpace then bothSpace = true end

                local spaceW, _ = surface.GetTextSize(" ")

                local blankLength = 0
                if bothSpace then 
                    blankLength = 2 * spaceW
                elseif startSpace or endSpace then 
                    blankLength = spaceW 
                end

                local lineY = 0 + (0.87 * seg.height)
                local lineWidth = seg.width - blankLength

                if startSpace then startOffset = spaceW end

                surface.DrawRect(segX + startOffset, lineY, lineWidth, 3)
            end

            segX = segX + seg.width
        end
    end

    panel:AddItem(bg)
end

local function ProcessSegments(messageSegments)
    local segments = {}

    for _, seg in ipairs(messageSegments) do
        local bold = seg.bold or false
        local italic = seg.italic or false
        local underline = seg.underline or false
        local strikeout = seg.strikeout or false
        local rotary = seg.rotary or false
        local shadow = seg.shadow or false
        local outline = seg.outline or false

        local segW = nil 
        local segH = nil

        local fontName = BuildFormattedHeaderFont(bold, italic, underline, strikeout, rotary, shadow, outline)

        if seg.text and seg.text ~= "" then
            surface.SetFont(fontName)
            segW, segH = surface.GetTextSize(seg.text)

            local segmentData = {text = seg.text, font = fontName, width = segW, height = segH}

            table.insert(segments, segmentData)
        end
    end

    BuildFormattedHeader(segments)
end

net.Receive("TestFormattedRandomatHeader", function()
    createdFonts = {}
    messageSegments = net.ReadTable()
    ProcessSegments(messageSegments)
end)

local COLOR_DEFAULT = Color(255, 200, 0)
local COLOR_BACKGROUND = Color(0, 0, 0, 200)
local STACK_GAP = 4

-- Ordered list of all active panels (newest last) with their default Y position (because Notify and SmallNotify have different starting points)
local message_stack = {}

local function RepositionStack()
    local count = #message_stack
    if count == 0 then return end

    local newest = message_stack[count]
    if not IsValid(newest.panel) then return end

    -- Do a little test run to check whether we're going to overflow
    local stacksFit = true
    local testY = newest.baseY
    for i = count - 1, 1, -1 do
        local entry = message_stack[i]
        if not IsValid(entry.panel) then continue end
        testY = testY - entry.panel:GetTall() - STACK_GAP
        if testY < 0 then
            stacksFit = false
            break
        end
    end

    -- If we're not going to overflow then move older messages upwards to make space for the new one
    if stacksFit then
        newest.panel:SetY(newest.baseY)
        for i = count - 1, 1, -1 do
            local entry = message_stack[i]
            local below = message_stack[i + 1].panel
            if not IsValid(entry.panel) or not IsValid(below) then continue end
            entry.panel:SetY(MathMax(below:GetY() - entry.panel:GetTall() - STACK_GAP, 0))
        end
    -- If we ARE going to overflow then start putting new messages under the older ones
    else
        message_stack[1].panel:SetY(0)
        for i = 2, count do
            local entry = message_stack[i]
            local above = message_stack[i - 1].panel
            if not IsValid(entry.panel) or not IsValid(above) then continue end
            entry.panel:SetY(above:GetY() + above:GetTall() + STACK_GAP)
        end

        -- Safety net so that if a new message would go off the BOTTOM of the screen, the whole stack moves upwards instead
        local newestPanel = message_stack[count].panel
        if IsValid(newestPanel) then
            local overshoot = (newestPanel:GetY() + newestPanel:GetTall()) - ScrH()
            if overshoot > 0 then
                for i = 1, count do
                    local entry = message_stack[i]
                    if IsValid(entry.panel) then
                        local newY = entry.panel:GetY() - overshoot
                        -- Just let the oldest messages overlap rather than pushing them off the screen (seems like the lesser of two evils)
                        if newY < 0 then
                            newY = 0
                        end
                        entry.panel:SetY(newY)
                    end
                end
            end
        end
    end
end

local function ShowMessage()
    local big = net.ReadBool()
    local msg = net.ReadString()
    local length = net.ReadUInt(8)
    if length == 0 then length = 5 end

    local font_color = net.ReadColor()
    if not font_color or font_color.a == 0 then font_color = COLOR_DEFAULT end

    local tag = net.ReadString()
    if tag == "" then tag = "default" end

    local panel = vgui.Create("DNotify")
    panel.tag = tag
    panel.big = big
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
    local baseY = panel:GetY()

    local bg = vgui.Create("DPanel", panel)
    function bg:OnRemove()
        local parent = bg:GetParent()
        if not IsValid(parent) then return end

        -- Remove from the ordered stack table
        for i = #message_stack, 1, -1 do
            if message_stack[i].panel == parent then
                TableRemove(message_stack, i)
                break
            end
        end

        -- Reposition remaining messages now that one has gone
        RepositionStack()

        -- And remove the now-unused parent too
        parent:Remove()
    end
    bg:SetBackgroundColor(COLOR_BACKGROUND)
    bg:Dock(FILL)

    local lbl = vgui.Create("DLabel", bg)
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

    -- If this is a big message and the only message in the stack is small, put this in front of the small one so it shows on top
    if big and #message_stack == 1 and not message_stack[1].panel.big then
        TableInsert(message_stack, 1, { panel = panel, baseY = baseY, tag = tag })
    else
        TableInsert(message_stack, { panel = panel, baseY = baseY, tag = tag })
    end

    -- Reposition all messages now that we've added a new one
    RepositionStack()
end

local function ClearMessages(all, tag)
    if all then
        for _, entry in ipairs(message_stack) do
            if IsValid(entry.panel) then
                entry.panel:Remove()
            end
        end
        message_stack = {}
    elseif tag then
        for i = #message_stack, 1, -1 do
            local entry = message_stack[i]
            if IsValid(entry.panel) and entry.tag == tag then
                TableRemove(message_stack, i)
                entry.panel:Remove()
            end
        end

        RepositionStack()
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