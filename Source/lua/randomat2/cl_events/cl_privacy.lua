net.Receive("alerteventtrigger", function()

	cl_item = net.ReadString()
	cl_role = net.ReadString()

	for k, v in pairs(weapons.GetList()) do
		
		if cl_item == v.ClassName then


			net.Start("AlertTriggerFinal")
			net.WriteString(v.PrintName)
			net.WriteString(cl_role)
			net.SendToServer()

		end

	end	

end)