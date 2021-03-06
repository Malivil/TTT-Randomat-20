local EVENT = {}

CreateConVar("randomat_communist_show_roles", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to show the role of the purchasing player")

EVENT.Title = "Communism! Time to learn how to share..."
EVENT.Description = "Whenever anyone buys something from a shop, all other players get that thing too"
EVENT.id = "communist"

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

local function CallHooks(ply, item, is_item)
    net.Start("TTT_BoughtItem")
    net.WriteBit(is_item)
    if is_item then
        net.WriteInt(item, 16)
    else
        net.WriteString(item)
    end
    net.Send(ply)
end

function EVENT:Begin()
    self:AddHook("TTTOrderedEquipment", function(ply, item, is_item)
        local role_name = self:GetRoleName(ply, true)
        if not GetConVar("randomat_communist_show_roles"):GetBool() then
            role_name = "Someone"
        end
        TriggerAlert(item, role_name, is_item, ply)

        for _, p in pairs(player.GetAll()) do
            if is_item then
                p:GiveEquipmentItem(tonumber(item))
            else
                p:Give(item)
            end

            CallHooks(p, item, is_item)
        end
    end)

    --Event started in cl_networkstrings
    net.Receive("AlertTriggerFinal", function()
        local event = net.ReadString()
        if event ~= EVENT.id then return end

        local name = self:RenameWeps(net.ReadString())
        local role = net.ReadString()

        self:SmallNotify(role .. " gave everyone a " .. name)
    end)
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in pairs({"show_roles"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return {}, checks
end

Randomat:register(EVENT)