local EVENT = {}

CreateConVar("randomat_pocket_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")

EVENT.Title = "What did I find in my pocket?"
EVENT.Description = "Gives each player a random buyable weapon"
EVENT.id = "pocket"
EVENT.SingleUse = false

local blocklist = {}

function EVENT:Begin()
    for blocked_id in string.gmatch(GetConVar("randomat_pocket_blocklist"):GetString(), '([^,]+)') do
        table.insert(blocklist, blocked_id:Trim())
    end

    timer.Simple(0.1, function()
        for _, ply in pairs(self:GetAlivePlayers()) do
            ply.pocketweptries = 0
            self:GiveWep(ply)
        end
    end)
end

function EVENT:CallHooks(isequip, id, ply)
    hook.Call("TTTOrderedEquipment", GAMEMODE, ply, id, isequip)
    net.Start("TTT_BoughtItem")
    net.WriteBit(isequip)
    if isequip then
        net.WriteInt(id, 16)
    else
        net.WriteString(id)
    end
    net.Send(ply)
end

function EVENT:GiveWep(ply)
    Randomat:GiveRandomShopItem(ply, {ROLE_TRAITOR,ROLE_ASSASSIN,ROLE_HYPNOTIST,ROLE_DETECTIVE,ROLE_MERCENARY}, blocklist, true,
        -- gettrackingvar
        function()
            return ply.pocketweptries
        end,
        -- settrackingvar
        function(value)
            ply.pocketweptries = value
        end,
        -- onitemgiven
        function(isequip, id)
            self:CallHooks(isequip, id, ply)
        end)
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