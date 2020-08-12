AddCSLuaFile()

local EVENT = {}

EVENT.Title = "Communism! Time to learn how to share..."
EVENT.id = "communist"


util.AddNetworkString("AlertTriggerFinal")
util.AddNetworkString("alerteventtrigger")

function TriggerAlert(item, role, ply)
    net.Start("alerteventtrigger")
    net.WriteString(item)
    net.WriteString(role)
    net.Send(ply)
end

function EVENT:Begin()

    hook.Add("TTTOrderedEquipment", "RandomatCommunismHook", function(ply, item, isItem)

        local role = 0

        if ply:GetRole() == ROLE_TRAITOR then
            role = "A traitor"
        elseif ply:GetRole() == ROLE_HYPNOTIST then
            role = "A hypnotist"
        elseif ply:GetRole() == ROLE_ASSASSIN then
            role = "An assassin"
        elseif ply:GetRole() == ROLE_DETECTIVE then
            role = "A detective"
        elseif ply:GetRole() == ROLE_MERCENARY then
            role = "A mercenary"
        elseif ply:GetRole() == ROLE_ZOMBIE then
            role = "A zombie"
        elseif ply:GetRole() == ROLE_VAMPIRE then
            role = "A vampire"
        elseif ply:GetRole() == ROLE_KILLER then
            role = "A killer"
        end
    
        TriggerAlert(item, role, ply)

        for i, ply in pairs(player.GetAll()) do
            ply:Give(item)
        end
    end)

    net.Receive("AlertTriggerFinal", function()
        local name = net.ReadString()
        local role = net.ReadString()
        
        self:SmallNotify("Sharing gave everyone a "..name)
        
    end)

end


function EVENT:End()
    hook.Remove("TTTOrderedEquipment", "RandomatCommunismHook")
end

Randomat:register(EVENT)