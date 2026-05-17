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