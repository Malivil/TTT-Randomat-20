local EVENT = {}

CreateConVar("randomat_pocket_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")

EVENT.Title = "What did I find in my pocket?"
EVENT.id = "pocket"

local blocklist = {}

function EVENT:Begin()
    for blocked_id in string.gmatch(GetConVar("randomat_pocket_blocklist"):GetString(), '([^,]+)') do
        table.insert(blocklist, blocked_id:Trim())
    end

    timer.Simple(0.1, function()
        for _, ply in pairs(self:GetAlivePlayers(true)) do
            ply.pocketweptries = 0
            self:GiveWep(ply)
        end
    end)
end

function EVENT:CallHooks(isequip, id, ply)
    hook.Call("TTTOrderedEquipment", GAMEMODE, ply, id, isequip)
    net.Start("RandomatRandomWeapons")
    net.WriteBit(isequip)
    if isequip then
        net.WriteInt(id, 16)
    else
        net.WriteString(id)
    end
    net.Send(ply)
end

function EVENT:GiveWep(ply)
    if ply.pocketweptries >= 100 then ply.pocketweptries = nil return end
    ply.pocketweptries = ply.pocketweptries + 1

    local item, item_id, swep_table = self:FindWep()
    if item_id then
        if ply:HasEquipmentItem(item_id) then
            self:GiveWep(ply)
        else
            ply:GiveEquipmentItem(item_id)
            self:CallHooks(true, item_id, ply)
            ply.pocketweptries = 0
        end
    elseif swep_table then
        if ply:CanCarryWeapon(swep_table) then
            ply:Give(item.ClassName)
            self:CallHooks(false, item.ClassName, ply)
            if swep_table.WasBought then
                swep_table:WasBought(ply)
            end
            ply.pocketweptries = 0
        else
            self:GiveWep(ply)
        end
    end
end

function EVENT:FindWep()
    local roleswithshop = {ROLE_TRAITOR,ROLE_ASSASSIN,ROLE_HYPNOTIST,ROLE_DETECTIVE,ROLE_MERCENARY}
    local selected = math.random(1,#roleswithshop)
    local tbl = table.Copy(EquipmentItems[roleswithshop[selected]])
    for _, v in pairs(weapons.GetList()) do
        if v and v.CanBuy and not table.HasValue(blocklist, v.ClassName) then
            table.insert(tbl, v)
        end
    end
    table.Shuffle(tbl)

    local item = table.Random(tbl)
    local item_id = tonumber(item.id)
    local swep_table = (not item_id) and weapons.GetStored(item.ClassName) or nil
    return item, item_id, swep_table
end

function EVENT:GetConVars()
    local textboxes = {}
    for _, v in pairs({"blocklist"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(textboxes, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return {}, {}, textboxes
end

Randomat:register(EVENT)