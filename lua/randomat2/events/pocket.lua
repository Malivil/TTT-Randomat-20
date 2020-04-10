local EVENT = {}

EVENT.Title = "What did I find in my pocket?"
EVENT.id = "pocket"

function EVENT:Begin()
  timer.Simple(0.1, function()
    for _, ply in pairs(self:GetAlivePlayers(true)) do
      ply.randomweptries = 0
      self:GiveWep(ply)
    end
  end)
end

function EVENT:CallHooks(IsEquip, ID, ply)
  hook.Call("TTTOrderedEquipment", GAMEMODE, ply, ID, IsEquip)
  net.Start("RandomatRandomWeapons")
  net.WriteBit(IsEquip)
  if IsEquip then
    net.WriteInt(ID, 16)
  else
    net.WriteString(ID)
  end
  net.Send(ply)
end

function EVENT:GiveWep(ply)
  if ply.randomweptries == 100 then ply.randomweptries = nil return end
  ply.randomweptries = ply.randomweptries + 1

  local item, is_item, swep_table = self:FindWep()

  if is_item then
    if ply:HasEquipmentItem(is_item) then
      self:GiveWep(ply)
    else
      ply:GiveEquipmentItem(is_item)
      self:CallHooks(true, is_item, ply)
      ply.randomweptries = 0
    end
  elseif swep_table then
    if ply:CanCarryWeapon(swep_table) then
      ply:Give(item.ClassName)
      self:CallHooks(false, item.ClassName, ply)
      if swep_table.WasBought then
         swep_table:WasBought(ply)
      end
      ply.randomweptries = 0
    else
      self:GiveWep(ply)
    end
  end
end

function EVENT:FindWep()
  local tbl = math.random(1,2) == 1 and table.Copy(EquipmentItems[ROLE_TRAITOR]) or table.Copy(EquipmentItems[ROLE_DETECTIVE])
  for k, v in pairs(weapons.GetList()) do
      if v and v.CanBuy then
        table.insert(tbl, v)
      end
  end
  table.Shuffle(tbl)
  local item = table.Random(tbl)
  local is_item = tonumber(item.id)
  local swep_table = (!is_item) and weapons.GetStored(item.ClassName) or nil

  return item, is_item, swep_table
end

Randomat:register(EVENT)