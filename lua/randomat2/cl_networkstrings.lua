local function GetItemName(item, role)
    local id = tonumber(item)
    local info = GetEquipmentItem(role, id)
    return info and LANG.TryTranslation(info.name) or item
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
    local event = net.ReadString()
    local item = net.ReadString()
    local role_string = net.ReadString()
    local is_item = net.ReadInt(8)
    local role = net.ReadInt(16)
    local name
    if is_item == 0 then
        name = GetWeaponName(item)
    else
        name = GetItemName(item, role)
    end

    net.Start("AlertTriggerFinal")
    net.WriteString(event)
    net.WriteString(name)
    net.WriteString(role_string)
    net.SendToServer()
end)
