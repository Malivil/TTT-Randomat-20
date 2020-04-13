net.Receive("TriggerSosig", function()
	for _, wep in pairs(LocalPlayer():GetWeapons()) do
		wep.Primary.Sound = "weapons/sosig.mp3"
	end
end)