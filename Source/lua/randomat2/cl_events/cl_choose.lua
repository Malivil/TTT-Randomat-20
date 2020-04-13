
local Frame
local lst
local chooseTables = {}
local frames = 0

local function closeChooseFrame()
	local x = 0
	local y = 0
	for k, v in pairs(chooseTables) do
		y = k
	end
	for k, v in pairs(chooseTables) do
		if k == y then
			v:Close()
			chooseTables[k] = nil
		end
	end
end

local function closeAllChooseFrame()
	for k, v in pairs(chooseTables) do
		v:Close()
		chooseTables[k] = nil
		x = 1
	end
end

net.Receive("ChooseEventTrigger", function()
	frames = frames+1
	--Frame Setup
	local x = net.ReadInt(32)
	local tbl = net.ReadTable()
	Frame = vgui.Create( "DFrame" )
	Frame:SetPos( 10, ScrH()-800 )
	Frame:SetSize( 200, 17*x + 51 )
	Frame:SetTitle( "Open Scoreboard to Interact" )
	Frame:SetDraggable( false )
	Frame:ShowCloseButton( false )
	Frame:SetVisible(true)
	Frame:SetDeleteOnClose(true)

	--Player List
	lst = vgui.Create("DListView", Frame)
	lst:Dock(FILL)
	lst:SetMultiSelect(false)
	lst:AddColumn("Events")

	for k, v in pairs(tbl) do
		lst:AddLine(v)
	end
	chooseTables[frames] = Frame

	lst.OnRowSelected = function(lst, index, pnl)
		net.Start("PlayerChoseEvent")
		net.WriteString(pnl:GetColumnText(1))
		net.SendToServer()
		closeChooseFrame()
	end

	net.Receive("ChooseEventEnd", function()
		if Frame ~= nil then
			closeAllChooseFrame()
		end
	end)
end)

net.Receive("ChooseVoteTrigger", function()
	frames = frames+1
	--Frame Setup
	local x = net.ReadInt(32)
	local tbl = net.ReadTable()
	Frame = vgui.Create( "DFrame" )
	Frame:SetPos( 10, ScrH()-800 )
	Frame:SetSize( 200, 17*x + 51 )
	Frame:SetTitle( "Open Scoreboard to Interact" )
	Frame:SetDraggable( false )
	Frame:ShowCloseButton( false )
	Frame:SetVisible(true)
	Frame:SetDeleteOnClose(true)

	--Event List
	lst = vgui.Create("DListView", Frame)
	lst:Dock(FILL)
	lst:SetMultiSelect(false)
	lst:AddColumn("Events")
	lst:AddColumn("Votes")

	for k, v in pairs(tbl) do
		lst:AddLine(v, 0)
	end
	chooseTables[frames] = Frame

	lst.OnRowSelected = function(lst, index, pnl)
		net.Start("ChoosePlayerVoted")
		net.WriteString(pnl:GetColumnText(1))
		net.SendToServer()
	end

	net.Receive("ChooseEventEnd", function()
		if Frame ~= nil then
			closeAllChooseFrame()
		end
	end)

	net.Receive("ChoosePlayerVoted", function()
		local votee = net.ReadString()
		for k, v in pairs(lst:GetLines()) do
			if v:GetColumnText(1) == votee then
				v:SetColumnText(2, v:GetColumnText(2)+1)
			end
		end
	end)

	net.Receive("ChooseVoteEnd", function()
		closeAllChooseFrame()
	end)	
end)