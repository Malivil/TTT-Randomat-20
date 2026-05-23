local math = math
local net = net
local surface = surface
local string = string
local table = table
local vgui = vgui

local MathMax = math.max
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
local StringReplace = string.Replace
local StringSplit = string.Split
local MathAbs = math.abs

SurfaceCreateFont("RandomatHeader", {
    font = "Roboto",
    size = 48
})

SurfaceCreateFont("RandomatSmallMsg", {
    font = "Roboto",
    size = 32
})

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

        local bold = seg.bold or false
        local italic = seg.italic or false
        local underline = seg.underline or false
        local strikethrough = seg.strikethrough or false
        local shadow = seg.shadow or false
        local outline = seg.outline or false
        local newline = seg.newline or false
        local descend = seg.descend or false
        local ascend = seg.ascend or false
        local vertical = (not seg.descend) and seg.vertical or false

        local fontName = BuildFormattedFont(bold, italic, underline, strikethrough, shadow, outline, big)
        SurfaceSetFont(fontName)

        local exploded = {}

        if descend then
            exploded = StringSplit(seg.text, "")

            for i, splitString in ipairs(exploded) do
                local segW, segH = SurfaceGetTextSize(splitString)

                local descend = i ~= 1

                TableInsert(segments, {
                    text = splitString,
                    font = fontName,
                    width = segW,
                    height = segH,
                    underline = underline,
                    strikethrough = strikethrough,
                    outline = outline,
                    newline = newline,
                    descend = descend,
                })
            end
        elseif ascend then

            print("Exploding ascend")
            exploded = StringSplit(seg.text, "")

            for i, splitString in ipairs(exploded) do
                local segW, segH = SurfaceGetTextSize(splitString)

                local ascend = i ~= 1

                TableInsert(segments, {
                    text = splitString,
                    font = fontName,
                    width = segW,
                    height = segH,
                    underline = underline,
                    strikethrough = strikethrough,
                    outline = outline,
                    newline = newline,
                    ascend = ascend,
                })
            end
        elseif vertical then
            exploded = StringSplit(seg.text, "")

            for i, splitString in ipairs(exploded) do
                local segW, segH = SurfaceGetTextSize(splitString)

                local vertical = i ~= 1

                TableInsert(segments, {
                    text = splitString,
                    font = fontName,
                    width = segW,
                    height = segH,
                    underline = underline,
                    strikethrough = strikethrough,
                    outline = outline,
                    newline = newline,
                    vertical = vertical,
                })
            end
        else
            local segW, segH = SurfaceGetTextSize(seg.text)

            TableInsert(segments, {
                text = seg.text,
                font = fontName,
                width = segW,
                height = segH,
                underline = underline,
                strikethrough = strikethrough,
                outline = outline,
                newline = newline,
            })
        end
    end

    return segments
end

-- Calculate how big the message is
local function MeasureSegments(segments)
    local baseW = 0
    local msgW = 0
    -- no need to measure maxH for segments as it's always the same
    local currentY = 0
    local maxY = 0
    local minY = 0
    local baseH = 0

    for _, seg in ipairs(segments) do
        if seg.width > baseW then
            baseW = seg.width
        end

        if not (seg.newline or seg.vertical) then
            msgW = msgW + seg.width
        end

        if baseH == 0 then
            baseH = seg.height
        end

        if seg.descend or seg.newline or seg.vertical then
            currentY = currentY + seg.height
            if currentY > maxY then maxY = currentY end
        end

        if seg.ascend then
            currentY = currentY - seg.height
            if currentY < minY then minY = currentY end
        end
    end

    msgW = MathMax(msgW, baseW)
    local msgH = maxY - minY + baseH
    local yOffset = MathAbs(minY)

    return msgW, msgH, yOffset
end

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

local function DrawFormattingLine(seg, segX, segY, font_color, offset)
    local startOffset = 0
    local blankLength = 0
    local spaceW = SurfaceGetTextSize(" ")

    local hasLeadSpace = StartsWith(seg.text, " ")
    local hasTrailSpace = EndsWith(seg.text, " ")

    if hasLeadSpace then
        startOffset = spaceW
        blankLength = blankLength + spaceW
    end
    if hasTrailSpace then
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

    local yOffset = nil
    local msgW, msgH
    local padding = big and 10 or 8
    local segments

    if formatted then
        local totalDown
        local totalUp
        local baseH
        
        createdFonts = {}
        segments = ProcessFormattedSegments(msg, big)
        msgW, msgH, yOffset = MeasureSegments(segments)
    else
        SurfaceSetFont(big and "RandomatHeader" or "RandomatSmallMsg")
        msgW, msgH = SurfaceGetTextSize(msg)
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


    if formatted then
        local content = VguiCreate("DPanel", bg)
        content:Dock(FILL)

        local paintSegments = segments

        function content:Paint(w, h)
            local segX = 0 + (padding / 2)
            local segY = 0 + yOffset
            local preceedingCharacterW = 0
            local lastChar = ""

            for _, seg in ipairs(paintSegments) do
                SurfaceSetFont(seg.font)

                preceedingCharacterW, _ = SurfaceGetTextSize(lastChar)

                if seg.descend or seg.newline then
                    segY = segY + seg.height
                end

                if seg.ascend then
                    segY = segY - seg.height
                end

                if seg.vertical then
                    segY = segY + seg.height
                    segX = segX - preceedingCharacterW + ((preceedingCharacterW - seg.width)/2)
                end

                if seg.newline then segX = 0 + (padding / 2) end

                SurfaceSetTextColor(font_color)
                SurfaceSetTextPos(segX, segY)
                SurfaceDrawText(seg.text)

                -- Strike-through line
                if seg.strikethrough then
                    DrawFormattingLine(seg, segX, segY, font_color, 0.55)
                end

                -- Underline
                if seg.underline then
                    DrawFormattingLine(seg, segX, segY, font_color, 0.87)
                end

                segX = segX + seg.width

                lastChar = string.sub(seg.text, -1)
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