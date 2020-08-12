AddCSLuaFile()

local EVENT = {}

EVENT.Title = "Communism! Time to learn how to share..."
EVENT.id = "communist"

local function TriggerAlert(item, role, ply)
    --Event handler located in cl_networkstrings
    net.Start("alerteventtrigger")
    net.WriteString(item)
    net.WriteString(role)
    net.Send(ply)
end

function EVENT:Begin()
    hook.Add("TTTOrderedEquipment", "RandomatCommunismHook", function(ply, item, isItem)
        TriggerAlert(item, self:GetRoleName(ply), ply)

        for _, p in pairs(player.GetAll()) do
            p:Give(item)
        end
    end)

    --Event started in cl_networkstrings
    net.Receive("AlertTriggerFinal", function()
        local name = net.ReadString()
        local role = net.ReadString()
        name = self:RenameWeps(name)

        self:SmallNotify(role.." gave everyone a "..name)
    end)
end

function EVENT:End()
    hook.Remove("TTTOrderedEquipment", "RandomatCommunismHook")
end

Randomat:register(EVENT)