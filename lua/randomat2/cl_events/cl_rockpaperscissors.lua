local EVENT = {}
EVENT.id = "rockpaperscissors"

local rockPaperScissorsFrame = nil
local function CloseFrame()
    if rockPaperScissorsFrame ~= nil then
        rockPaperScissorsFrame:Close()
        rockPaperScissorsFrame = nil
    end
end

EVENT.End = CloseFrame

Randomat:register(EVENT)

net.Receive("RockPaperScissorsEventBegin", function()
    --Frame Setup
    rockPaperScissorsFrame = vgui.Create("DFrame")
    local height = 72
    local width = 200
    local margin = 10
    local title_height = 15
    local side_margin = 20
    rockPaperScissorsFrame:SetSize(width, height)
    rockPaperScissorsFrame:Center()
    rockPaperScissorsFrame:SetTitle("Rock, Paper, or Scissors? (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    rockPaperScissorsFrame:SetDraggable(false)
    rockPaperScissorsFrame:ShowCloseButton(false)
    rockPaperScissorsFrame:SetVisible(true)
    rockPaperScissorsFrame:SetDeleteOnClose(true)
    rockPaperScissorsFrame:SetZPos(32767)
    rockPaperScissorsFrame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 10, 200))
    end

    -- Rock
    local button_pos = side_margin + margin
    local button_height = 36
    local button_width = 40
    local rockButton = vgui.Create("DButton", rockPaperScissorsFrame)
    rockButton:SetPos(button_pos, margin + title_height)
    rockButton:SetSize(button_width, button_height)
    rockButton:SetImage("icon32/stones.png")
    rockButton:SetText("")
    rockButton.DoClick = function()
        net.Start("RdmtPlayerChoseRock")
        net.WriteUInt64(LocalPlayer():SteamID64())
        net.SendToServer()
        CloseFrame()
    end

    -- Paper
    button_pos = button_pos + margin + button_width
    local paperButton = vgui.Create("DButton", rockPaperScissorsFrame)
    paperButton:SetPos(button_pos, margin + title_height)
    paperButton:SetSize(button_width, button_height)
    paperButton:SetImage("icon32/copy.png")
    paperButton:SetText("")
    paperButton.DoClick = function()
        net.Start("RdmtPlayerChosePaper")
        net.WriteUInt64(LocalPlayer():SteamID64())
        net.SendToServer()
        CloseFrame()
    end

    -- Scissors
    button_pos = button_pos + margin + button_width
    local scissorsButton = vgui.Create("DButton", rockPaperScissorsFrame)
    scissorsButton:SetPos(button_pos, margin + title_height)
    scissorsButton:SetSize(button_width, button_height)
    scissorsButton:SetImage("icon32/cut.png")
    scissorsButton:SetText("")
    scissorsButton.DoClick = function()
        net.Start("RdmtPlayerChoseScissors")
        net.WriteUInt64(LocalPlayer():SteamID64())
        net.SendToServer()
        CloseFrame()
    end
end)