local EVENT = {}

CreateConVar("randomat_pocket_blocklist", "", FCVAR_NONE, "The comma-separated list of weapon IDs to not give out")

EVENT.Title = "What did I find in my pocket?"
EVENT.Description = "Gives each player a random buyable weapon"
EVENT.id = "pocket"
EVENT.SingleUse = false
EVENT.Categories = {"moderateimpact"}

local blocklist = {}

function EVENT:Begin()
    blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_pocket_blocklist"):GetString(), "([^,]+)") do
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
    Randomat:GiveRandomShopItem(ply, Randomat:GetShopRoles(), blocklist, false,
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

Randomat:register(EVENT)