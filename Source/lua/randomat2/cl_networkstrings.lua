net.Receive("RandomatRandomWeapons",function()
  local is_item = net.ReadBit() == 1
  local id = is_item and net.ReadUInt(16) or net.ReadString()
  hook.Run("TTTBoughtItem", is_item, id)
end)
