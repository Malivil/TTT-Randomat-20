net.Receive("RandomatRandomWeapons",function()
  local is_item = net.ReadBit() == 1
  local id = is_item and net.ReadUInt(16) or net.ReadString()
  hook.Run("TTTBoughtItem", is_item, id)
end)

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
