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
        for _, ply in ipairs(self:GetAlivePlayers()) do
            ply.pocketweptries = 0
            self:GiveWep(ply)
        end
    end)
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
            Randomat:CallShopHooks(isequip, id, ply)
        end)
end

function EVENT:GetConVars()
    local textboxes = {}
    for _, v in ipairs({"blocklist"}) do
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