
local Frame
local lst

net.Receive("DemocracyEventBegin", function()
	--Frame Setup
	Frame = vgui.Create( "DFrame" )
	Frame:SetPos( 10, ScrH()-800 )
	Frame:SetSize( 200, 300 )
	Frame:SetTitle( "Open Scoreboard to Interact" )
	Frame:SetDraggable( false )
	Frame:ShowCloseButton( false )
	Frame:SetVisible(true)
	Frame:SetDeleteOnClose(true)

	--Player List
	lst = vgui.Create("DListView", Frame)
	lst:Dock(FILL)
	lst:SetMultiSelect(false)
	lst:AddColumn("Players")
	lst:AddColumn("Votes")

	for k, v in pairs(player.GetAll()) do
		if (v:Alive() and not v:IsSpec()) or not v:Alive() then
			lst:AddLine(v:Nick(), 0)
		end
	end

	lst.OnRowSelected = function(lst, index, pnl)
		if LocalPlayer():Alive() and not LocalPlayer():IsSpec() then
			net.Start("DemocracyPlayerVoted")
			net.WriteString(pnl:GetColumnText(1))
			net.SendToServer()
		else
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "Dead people can't vote")
		end
	end

	net.Receive("DemocracyPlayerVoted", function()
		local votee = net.ReadString()
		local num = net.ReadInt(32)
		for k, v in pairs(lst:GetLines()) do
			if v:GetColumnText(1) == votee then
				v:SetColumnText(2, num)
			end
		end
	end)

	net.Receive("DemocracyReset", function()
		for k, v in pairs(lst:GetLines()) do
			v:SetColumnText(2, 0)
		end
	end)
end)

net.Receive("DemocracyEventEnd", function()
	Frame:Close()
end)