local math = math
local net = net
local surface = surface
local string = string
local table = table
local vgui = vgui

local MathAbs = math.abs
local MathMax = math.max
local StringReplace = string.Replace
local StringSplit = string.Split
local StringSub = string.sub
local StartsWith = string.StartsWith
local EndsWith = string.EndsWith
local SurfaceCreateFont = surface.CreateFont
local SurfaceDrawText = surface.DrawText
local SurfaceDrawRect = surface.DrawRect
local SurfacePlaySound = surface.PlaySound
local SurfaceSetDrawColor = surface.SetDrawColor
local SurfaceSetFont = surface.SetFont
local SurfaceGetTextSize = surface.GetTextSize
local SurfaceSetTextColor = surface.SetTextColor
local SurfaceSetTextPos = surface.SetTextPos
local TableInsert = table.insert
local TableRemove = table.remove
local VguiCreate = vgui.Create

SurfaceCreateFont("RandomatHeader", {
    font = "Roboto",
    size = 48
})

SurfaceCreateFont("RandomatSmallMsg", {
    font = "Roboto",
    size = 32
})

local COLOR_DEFAULT = Color(255, 200, 0)
local COLOR_BACKGROUND = Color(0, 0, 0, 200)
local STACK_GAP = 4

-- Ordered list of all active panels (newest last) with their default Y position (because Notify and SmallNotify have different starting points)
local messageStack = {}
-- Cached list of created fonts for formatted text
local createdFonts = {}

-- Make and cache fonts on-demand
local function BuildFormattedFont(bold, italic, underline, strikethrough, shadow, outline, big)
    local key = (bold and "B" or "") .. (italic and "I" or "") .. (underline and "U" or "") .. (strikethrough and "St" or "") .. (shadow and "Sh" or "") .. (outline and "O" or "") .. (big and "Big" or "Small")
    local name = "RandomatFont_" .. (key == "" and "Normal" or key)

    if not createdFonts[name] then
        SurfaceCreateFont(name, {
            font = "Roboto",
            size = big and 48 or 32,
            weight = bold and 700 or 500,
            italic = italic or false,
            outline = outline or false,
        })
        createdFonts[name] = true
    end

    return name
end

-- Make a nice table with data for all the segments
local function ProcessFormattedSegments(messageSegments, big)
    local segments = {}

    for _, seg in ipairs(messageSegments) do
        if not seg.text then continue end

        seg.text = StringReplace(seg.text, "\n", "")
        if seg.text == "" then continue end

        local underline     = seg.underline     or false
        local strikethrough = seg.strikethrough or false
        local outline       = seg.outline       or false
        local newline       = seg.newline       or false

        local layoutShape
        if seg.descend then
            layoutShape = "descend"
        elseif seg.ascend then
            layoutShape = "ascend"
        elseif seg.vertical then
            layoutShape = "vertical"
        elseif seg.verticalup then
            layoutShape = "verticalup"
        end

        local fontName = BuildFormattedFont(seg.bold, seg.italic, underline, strikethrough, seg.shadow, outline, big)
        SurfaceSetFont(fontName)

        if layoutShape then
            local parts = StringSplit(seg.text, "")

            local columnWidth = 0
            for _, part in ipairs(parts) do
                local partW = SurfaceGetTextSize(part)
                if partW > columnWidth then columnWidth = partW end
            end

            for i, part in ipairs(parts) do
                local segW, segH = SurfaceGetTextSize(part)
                local newSeg = {
                    text          = part,
                    font          = fontName,
                    width         = segW,
                    columnWidth   = columnWidth,
                    height        = segH,
                    underline     = underline,
                    strikethrough = strikethrough,
                    outline       = outline,
                    newline       = newline,
                }

                newSeg[layoutShape] = i ~= 1 and true or nil
                TableInsert(segments, newSeg)
            end
        else
            local segW, segH = SurfaceGetTextSize(seg.text)
            TableInsert(segments, {
                text          = seg.text,
                font          = fontName,
                width         = segW,
                height        = segH,
                underline     = underline,
                strikethrough = strikethrough,
                outline       = outline,
                newline       = newline,
            })
        end
    end

    return segments
end

local function IsBreak(seg)
    return seg.newline or seg.vertical or seg.verticalup
end

-- Calculate how big the message is
local function MeasureSegments(segments)
    local msgW = 0
    local currentY = 0
    local maxY = 0
    local minY = 0
    local baseH = 0
    local baseW = 0

    for i, seg in ipairs(segments) do

        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print("seg.text = " .. seg.text)
        print("seg.vertical = " .. tostring(seg.vertical))
        print("seg.verticalup = " .. tostring(seg.verticalup))
        print("seg.width = " .. seg.width)
        print("seg.columnWidth = " .. tostring(seg.columnWidth))

        local effectiveW = seg.columnWidth or seg.width

        if effectiveW > baseW then
            baseW = effectiveW
        end

        if baseH == 0 then
            baseH = seg.height
        end

        if seg.vertical or seg.verticalup then
            -- don't need to add more width for these
        elseif seg.newline then
            -- no width for a new line
        elseif seg.descend or seg.ascend then
            msgW = msgW + seg.width
        else
            msgW = msgW + (seg.columnWidth or seg.width)
        end

        if seg.descend or seg.newline or seg.vertical then
            currentY = currentY + seg.height
            if currentY > maxY then maxY = currentY end
        end

        if seg.ascend or seg.verticalup then
            currentY = currentY - seg.height
            if currentY < minY then minY = currentY end
        end
    end

    local msgH = maxY - minY + baseH
    return MathMax(msgW, baseW), msgH, MathAbs(minY)
end

local function CalculateMessageGap(first, second)
    -- If messages are in the same group, stick them together
    if second and first.group == second.group then
        return 0
    end
    return STACK_GAP
end

local function RepositionStack()
    local count = #messageStack
    if count == 0 then return end

    local newest = messageStack[count]
    if not IsValid(newest.panel) then return end

    -- Do a little test run to check whether we're going to overflow
    local stacksFit = true
    local testY = newest.baseY
    for i = count - 1, 1, -1 do
        local entry = messageStack[i]
        local below = messageStack[i + 1]
        if not IsValid(entry.panel) then continue end

        testY = testY - entry.panel:GetTall() - CalculateMessageGap(entry, below)
        if testY < 0 then
            stacksFit = false
            break
        end
    end

    -- If we're not going to overflow then move older messages upwards to make space for the new one
    if stacksFit then
        newest.panel:SetY(newest.baseY)
        for i = count - 1, 1, -1 do
            local entry = messageStack[i]
            local below = messageStack[i + 1]
            if not IsValid(entry.panel) or not IsValid(below.panel) then continue end

            entry.panel:SetY(MathMax(below.panel:GetY() - entry.panel:GetTall() - CalculateMessageGap(entry, below), 0))
        end
    -- If we ARE going to overflow then start putting new messages under the older ones
    else
        messageStack[1].panel:SetY(0)
        for i = 2, count do
            local entry = messageStack[i]
            local above = messageStack[i - 1]
            if not IsValid(entry.panel) or not IsValid(above.panel) then continue end

            entry.panel:SetY(above.panel:GetY() + above.panel:GetTall() + CalculateMessageGap(entry, above))
        end

        -- Safety net so that if a new message would go off the BOTTOM of the screen, the whole stack moves upwards instead
        local newestPanel = messageStack[count].panel
        if IsValid(newestPanel) then
            local overshoot = (newestPanel:GetY() + newestPanel:GetTall()) - ScrH()
            if overshoot > 0 then
                for i = 1, count do
                    local entry = messageStack[i]
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

local function DrawFormattingLine(seg, segX, segY, font_color, offset)
    local startOffset = 0
    local blankLength = 0
    local spaceW = SurfaceGetTextSize(" ")

    if StartsWith(seg.text, " ") then
        startOffset = spaceW
        blankLength = blankLength + spaceW
    end
    if EndsWith(seg.text, " ") then
        blankLength = blankLength + spaceW
    end

    local lineY = segY + offset * seg.height
    local lineWidth = seg.width - blankLength

    if seg.outline then
        SurfaceSetDrawColor(COLOR_BLACK)
        SurfaceDrawRect(segX + startOffset - 1, lineY - 1, lineWidth + 2, 5)
    end

    SurfaceSetDrawColor(font_color)
    SurfaceDrawRect(segX + startOffset, lineY, lineWidth, 3)
end

local function ShowMessage()
    local big = net.ReadBool()
    local formatted = net.ReadBool()

    local msg
    if formatted then
        msg = net.ReadTable()
    else
        msg = net.ReadString()
    end

    local length = net.ReadUInt(8)
    if length == 0 then length = 5 end

    local font_color = net.ReadColor()
    if not font_color or font_color.a == 0 then font_color = COLOR_DEFAULT end

    local tag = net.ReadString()
    if tag == "" then tag = "default" end

    local group = net.ReadUInt(32)

    local padding = big and 10 or 8
    local yOffset
    local msgW, msgH
    local segments

    if formatted then
        createdFonts = {}
        segments = ProcessFormattedSegments(msg, big)
        msgW, msgH, yOffset = MeasureSegments(segments)
    else
        SurfaceSetFont(big and "RandomatHeader" or "RandomatSmallMsg")
        msgW, msgH = SurfaceGetTextSize(msg)
    end

    if formatted then
        -- Find the highest-indexed segment that isn't vertical/verticalup
        local highestNonVerticalSegIndex = nil

        for i = #segments, 1, -1 do
            local seg = segments[i]
            if not seg.vertical and not seg.verticalup then
                highestNonVerticalSegIndex = i
                break
            end
        end

        -- Only do a thing if there's a non-first-entry-, non-vertical segment
        if not highestNonVerticalSegIndex or (highestNonVerticalSegIndex and highestNonVerticalSegIndex > 1) then
            local finalSeg = segments[#segments]
            if finalSeg.vertical or finalSeg.verticalup then
                msgW = msgW - finalSeg.columnWidth / 2
            end
        end
    end

    local panel = VguiCreate("DNotify")
    panel.tag = tag
    panel.big = big
    panel:SetLife(length)
    panel:SetSize(msgW + padding, msgH)
    panel:Center()
    if not big then
        panel:CenterVertical(0.55)
    end

    local baseY = panel:GetY()
    local bg = VguiCreate("DPanel", panel)
    bg:SetBackgroundColor(COLOR_BACKGROUND)
    bg:Dock(FILL)
    function bg:OnRemove()
        local parent = bg:GetParent()
        if not IsValid(parent) then return end

        -- Remove from the ordered stack table
        for i = #messageStack, 1, -1 do
            if messageStack[i].panel == parent then
                TableRemove(messageStack, i)
                break
            end
        end

        -- Reposition remaining messages now that one has gone
        RepositionStack()

        -- And remove the now-unused parent too
        parent:Remove()
    end

    if formatted then
        local content = VguiCreate("DPanel", bg)
        content:Dock(FILL)

        local paintSegments = segments

        function content:Paint(w, h)
            local segX = padding / 2
            local segY = yOffset

            for i, seg in ipairs(paintSegments) do
                local nextSeg -- = paintSegments[i + 1]
                if i ~= #paintSegments then
                    nextSeg = paintSegments[i + 1]
                end

                SurfaceSetFont(seg.font)

                local colW = seg.columnWidth

                if seg.descend or seg.newline then
                    segY = segY + seg.height
                end

                if seg.ascend then
                    segY = segY - seg.height
                end

                if seg.vertical then
                    segY = segY + seg.height
                end

                if seg.verticalup then
                    segY = segY - seg.height
                end

                if seg.newline then segX = padding / 2 end

                local drawX
                if colW and i == 1 then
                    drawX = segX + (colW - seg.width) / 2
                elseif colW and (seg.vertical or seg.verticalup) and segX ~= padding / 2 then
                    drawX = segX - colW / 2
                else
                    drawX = segX
                end

                SurfaceSetTextColor(font_color)
                SurfaceSetTextPos(drawX, segY)
                SurfaceDrawText(seg.text)

                if seg.strikethrough then
                    DrawFormattingLine(seg, drawX, segY, font_color, 0.55)
                end

                if seg.underline then
                    DrawFormattingLine(seg, drawX, segY, font_color, 0.87)
                end

                if not colW or (colW and (not nextSeg or not nextSeg.columnWidth)) then
                    segX = segX + seg.width
                end
            end
        end
    else
        local lbl = VguiCreate("DLabel", bg)
        if big then
            lbl:SetFont("RandomatHeader")
        else
            lbl:SetFont("RandomatSmallMsg")
        end
        lbl:SetTextColor(font_color)
        lbl:SetWrap(true)
        lbl:DockMargin(padding / 2, 0, padding / 2, 0)
        lbl:Dock(FILL)
        lbl:SetText(msg)
    end

    panel:AddItem(bg)

    -- If this is a big message and the only message in the stack is small, put this in front of the small one so it shows on top
    if big and #messageStack == 1 and not messageStack[1].panel.big then
        TableInsert(messageStack, 1, { panel = panel, baseY = baseY, tag = tag, group = group })
    else
        TableInsert(messageStack, { panel = panel, baseY = baseY, tag = tag, group = group })
    end

    -- Reposition all messages now that we've added a new one
    RepositionStack()
end

local function ClearMessages(all, tag)
    if all then
        for _, entry in ipairs(messageStack) do
            if IsValid(entry.panel) then
                entry.panel:Remove()
            end
        end
        messageStack = {}
    elseif tag then
        for i = #messageStack, 1, -1 do
            local entry = messageStack[i]
            if IsValid(entry.panel) and entry.tag == tag then
                TableRemove(messageStack, i)
                entry.panel:Remove()
            end
        end

        RepositionStack()
    end
end

net.Receive("randomat_message", function()
    ShowMessage()
    SurfacePlaySound("weapons/c4_initiate.mp3")
end)

net.Receive("randomat_message_silent", function()
    ShowMessage()
end)

net.Receive("randomat_message_clear", function()
    local all = net.ReadBool()
    local tag = net.ReadString()
    ClearMessages(all, tag)
end)