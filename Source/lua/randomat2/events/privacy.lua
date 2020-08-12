AddCSLuaFile()

local EVENT = {}

EVENT.Title = "We've updated our privacy policy."
EVENT.id = "privacy"

local function TriggerAlert(item, role, ply)
    --Event handler located in cl_networkstrings
    net.Start("alerteventtrigger")
    net.WriteString(item)
    net.WriteString(role)
    net.Send(ply)
end

function EVENT:Begin()
    hook.Add("TTTOrderedEquipment", "RandomatAlertHook", function(ply, item, isItem)
        TriggerAlert(item, self:GetRoleName(ply), ply)
    end)

    --Event started in cl_networkstrings
    net.Receive("AlertTriggerFinal", function()
        local name = net.ReadString()
        local role = net.ReadString()
        name = self:RenameWeps(name)

        self:SmallNotify(role.." has bought a "..name)
    end)
end

function EVENT:End()
    hook.Remove("TTTOrderedEquipment", "RandomatAlertHook")
end

Randomat:register(EVENT)