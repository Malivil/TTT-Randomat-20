local EVENT = {}

CreateConVar("randomat_communist_show_roles", 1, FCVAR_NONE, "Whether to show the role of the purchasing player")

EVENT.Title = "Communism! Time to learn how to share..."
EVENT.Description = "Whenever anyone buys something from a shop, all other players get that thing too"
EVENT.id = "communist"
EVENT.Categories = {"moderateimpact"}

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

        -- Try to find this item by its ID
        if is_item and GetEquipmentItemById then
            local item_info = GetEquipmentItemById(item)
            -- If we found it and it's marked as "From Randoman" then this is a Randoman buying an event
            -- We can't "give" an event to other players, so just don't try
            if item_info and item_info.randomanItem then
                return
            end
        end

        local role_name = self:GetRoleName(ply, true)
        if not GetConVar("randomat_communist_show_roles"):GetBool() then
            role_name = "Someone"
        end
        TriggerAlert(item, role_name, is_item, ply)

        for _, p in player.Iterator() do
            if p ~= ply then
                if is_item then
                    p:GiveEquipmentItem(tonumber(item))
                else
                    p:Give(item)
                    if item.WasBought then
                        item:WasBought(p)
                    end
                end

                Randomat:CallShopHooks(is_item, item, p)
            end
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

function EVENT:Condition()
    return not Randomat:IsEventActive("privacy")
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"show_roles"}) do
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