-- Weapon/Item Names
net.Receive("alerteventtrigger", function()
    local event = net.ReadString()
    local item = net.ReadString()
    local role_string = net.ReadString()
    local is_item = net.ReadUInt(32)
    local role = net.ReadInt(16)
    local name
    if is_item == 0 then
        name = Randomat:GetWeaponName(item)
    else
        name = Randomat:GetItemName(item, role)
    end

    net.Start("AlertTriggerFinal")
    net.WriteString(event)
    net.WriteString(name)
    net.WriteString(role_string)
    net.SendToServer()
end)

-- Player Speed
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

net.Receive("RdmtRemoveSpeedMultipliers", function()
    local key = net.ReadString()
    for k, _ in pairs(current_mults) do
        if string.StartWith(k, key) then
            current_mults[k] = nil
        end
    end
    for k, _ in pairs(current_mults_withweapon) do
        if string.StartWith(k, key) then
            current_mults_withweapon[k] = nil
        end
    end
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
    if IsValid(wep) then
        local wep_class = wep:GetClass()
        for _, m in pairs(current_mults_withweapon) do
            if m ~= nil and wep_class == m.wep_class then
                table.insert(mults, m.mult)
            end
        end
    end
end)