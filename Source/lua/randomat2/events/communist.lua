AddCSLuaFile()

local EVENT = {}

EVENT.Title = "Communism! Time to learn how to share..."
EVENT.id = "communist"


util.AddNetworkString("AlertTriggerFinal")
util.AddNetworkString("alerteventtrigger")

local function RenameWeps(name)
    if name == "sipistol_name" then
        return "Silenced Pistol"
    elseif name == "knife_name" then
        return "Knife"
    elseif name == "newton_name" then
        return "Newton Launcher"
    elseif name == "tele_name" then
        return "Teleporter"
    elseif name == "hstation_name" then
        return "Health Station"
    elseif name == "flare_name" then
        return "Flare Gun"
    elseif name == "decoy_name" then
        return "Decoy"
    elseif name == "radio_name" then
        return "Radio"
    elseif name == "polter_name" then
        return "Poltergeist"
    elseif name == "vis_name" then
        return "Visualizer"
    elseif name == "defuser_name" then
        return "Defuser"
    elseif name == "stungun_name" then
        return "UMP Prototype"
    elseif name == "binoc_name" then
        return "Binoculars"
    else
        return name
    end
end

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

        for i, p in pairs(player.GetAll()) do
            p:Give(item)
        end
    end)

    net.Receive("AlertTriggerFinal", function()
        local name = net.ReadString()
        local role = net.ReadString()
		name = RenameWeps(name)
        
        self:SmallNotify(role.." gave everyone a "..name)
        
    end)

end


function EVENT:End()
    hook.Remove("TTTOrderedEquipment", "RandomatCommunismHook")
end

Randomat:register(EVENT)