local EVENT = {}

EVENT.Title = "We've updated our privacy policy."
EVENT.Description = "Alerts all players when an item is bought from a shop"
EVENT.id = "privacy"
EVENT.Type = EVENT_TYPE_TRANSLATED_WEAPONS
EVENT.Categories = {"biased_innocent", "biased", "moderateimpact"}

local function TriggerAlert(item, role, is_item, ply)
    --Event handler located in cl_networkstrings
    net.Start("alerteventtrigger")
    net.WriteString(EVENT.id)
    net.WriteString(item)
    net.WriteString(role)
    net.WriteUInt(is_item ~= nil and is_item or 0, 32)
    net.WriteInt(ply:GetRole(), 16)
    net.Send(ply)
end

function EVENT:Begin()
    self:AddHook("TTTOrderedEquipment", function(ply, item, is_item, fromrdmt)
        if fromrdmt then return end

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

function EVENT:Condition()
    return not Randomat:IsEventActive("communist")
end

Randomat:register(EVENT)