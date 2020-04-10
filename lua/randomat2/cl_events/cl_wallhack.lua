net.Receive("haloeventtrigger", function()
	
	hook.Add("PreDrawHalos", "RandomatHalos", function()

		local alivePlys = {}

		for k, v in pairs(player.GetAll()) do
			if v:Alive() and not v:IsSpec() then
				alivePlys[k] = v
			end
		end

		halo.Add(alivePlys ,Color(0,255,0), 0, 0, 1, true, true)
	end)
end)

net.Receive("haloeventend", function()
	hook.Remove("PreDrawHalos", "RandomatHalos")
end)