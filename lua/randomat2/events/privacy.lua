AddCSLuaFile()

local EVENT = {}

EVENT.Title = "We've updated our privacy policy."
EVENT.Description = "Alerts all players when an item is bought from a shop"
EVENT.id = "privacy"

local function TriggerAlert(item, role, is_item, ply)
    --Event handler located in cl_networkstrings
    net.Start("alerteventtrigger")
    net.WriteString(EVENT.id)
    net.WriteString(item)
    net.WriteString(role)
    net.WriteInt(is_item ~= nil and is_item or 0, 8)
    net.WriteInt(ply:GetRole(), 16)
    net.Send(ply)
end

function EVENT:Begin()
    self:AddHook("TTTOrderedEquipment", function(ply, item, is_item)
        TriggerAlert(item, self:GetRoleName(ply, true), is_item, ply)
    end)

    --Event started in cl_networkstrings
    net.Receive("AlertTriggerFinal", function()
        local event = net.ReadString()
        if event ~= EVENT.id then return end

        local name = self:RenameWeps(net.ReadString())
        local role = net.ReadString()

        self:SmallNotify(role .. " has bought a " .. name)
    end)
end

Randomat:register(EVENT)