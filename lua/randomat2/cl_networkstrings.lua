local function GetItemName(item, role)
    local id = tonumber(item)
    local info = GetEquipmentItem(role, id)
    return info and LANG.TryTranslation(info.name) or item
end

local function GetWeaponName(item)
    for _, v in ipairs(weapons.GetList()) do
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

local current_mults = {}
local current_mults_withweapon = {}
net.Receive("RdmtSetSpeedMultiplier", function()
    local mult = net.ReadFloat()
    local key = net.ReadString()
    current_mults[key] = mult
end)

net.Receive("RdmtSetSpeedMultiplier_WithWeapon", function()
    local mult = net.ReadFloat()
    local key = net.ReadString()
    local wep_class = net.ReadString()
    current_mults_withweapon[key] = {
        wep_class = wep_class,
        mult = mult
    }
end)

net.Receive("RdmtRemoveSpeedMultiplier", function()
    local key = net.ReadString()
    current_mults[key] = nil
    current_mults_withweapon[key] = nil
end)

hook.Add("TTTSpeedMultiplier", "RdmtSpeedModifier", function(ply, mults)
    if ply ~= LocalPlayer() or not ply:Alive() or ply:IsSpec() then return end

    -- Apply all of these that are valid
    for _, m in pairs(current_mults) do
        if m ~= nil then
            table.insert(mults, m)
        end
    end

    -- Apply all of these that are valid and have a weapon that matches the specific class
    local wep = ply:GetActiveWeapon()
    if wep and IsValid(wep) then
        local wep_class = wep:GetClass()
        for _, m in pairs(current_mults_withweapon) do
            if m ~= nil and wep_class == m.wep_class then
                table.insert(mults, m.mult)
            end
        end
    end
end)