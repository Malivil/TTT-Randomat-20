net.Receive("UpgradeEventBegin", function()
	--Frame Setup
	upgradeFrame = vgui.Create( "DFrame" )
	local ht = 190
	local wt = 300
	local gap = 20
	upgradeFrame:SetSize( 300, 190 )
	upgradeFrame:Center()
	upgradeFrame:SetTitle( "Open Scoreboard to Interact" )
	upgradeFrame:SetDraggable( false )
	upgradeFrame:ShowCloseButton( false )
	upgradeFrame:SetVisible(true)
	upgradeFrame:SetDeleteOnClose(true)
	upgradeFrame.Paint = function( self, w, h ) 
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 10, 200 ) )
	end

	--Player List
	local bht = (ht-((gap*3)+25))/2
	local bwt = wt - (gap*2)
	local btn1 = vgui.Create("DButton", upgradeFrame)
	btn1:SetFont("TraitorState")
	btn1:SetTextColor(Color(255,255,255))
	btn1:SetPos(gap, gap+25)
	btn1:SetSize(bwt,bht)
	btn1:SetText("Survivalist")
	btn1.Paint = function(self, w, h)
		draw.RoundedBox(8,0,0,w,h,Color(255, 102, 51))
	end
	btn1.DoClick = function()
		net.Start("rdmtPlayerChoseSur")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		upgradeFrame:Close()
	end

	local btn2 = vgui.Create("DButton", upgradeFrame)
	btn2:SetTextColor(Color(255,255,255))
	btn2:SetFont("TraitorState")
	btn2:SetText("Serial Killer")
	btn2:SetPos(gap, gap*2 + bht + 25)
	btn2:SetSize(bwt,bht)
	btn2.Paint = function(self, w, h)
		draw.RoundedBox(8,0,0,w,h,Color(85, 26, 139))
	end
	btn2.DoClick = function()
		net.Start("rdmtPlayerChoseSk")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		upgradeFrame:Close()
	end
end)

net.Receive("RdmtCloseUpgradeFrame", function()
	if upgradeFrame ~= nil then 
		if upgradeFrame:IsActive() then
			upgradeFrame:Close()
		end
	end
end)	