net.Receive("RandomatRandomWeapons",function()
  local is_item = net.ReadBit() == 1
  local id = is_item and net.ReadUInt(16) or net.ReadString()
  hook.Run("TTTBoughtItem", is_item, id)
end)

local function GetItemName(item)
    if CLIENT then
        local id = tonumber(item)
        if id == EQUIP_ARMOR then
            return LANG.GetTranslation("item_armor")
        elseif id == EQUIP_RADAR then
            return LANG.GetTranslation("item_radar")
        elseif id == EQUIP_REGEN then
            return LANG.GetTranslation("item_regen")
        elseif id == EQUIP_DISGUISE then
            return LANG.GetTranslation("item_disg")
        elseif id == EQUIP_SPEED then
            return LANG.GetTranslation("item_speed")
        end
    end

    return item
end

local function GetWeaponName(item)
    for _, v in pairs(weapons.GetList()) do
        if item == v.ClassName then
            return v.PrintName
        end
    end

    return item
end

net.Receive("alerteventtrigger", function()
    local item = net.ReadString()
    local role = net.ReadString()
    local is_item = net.ReadInt(8)
    local name
    if is_item == 0 then
        name = GetWeaponName(item)
    else
        name = GetItemName(item)
    end

    net.Start("AlertTriggerFinal")
    net.WriteString(name)
    net.WriteString(role)
    net.SendToServer()
end)
