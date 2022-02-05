local plymeta = FindMetaTable("Player")
if not plymeta then return end

local EVENT = {}

CreateConVar("randomat_blackmarket_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")
CreateConVar("randomat_blackmarket_timer_traitor", 25, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often traitors should get items", 1, 60)
CreateConVar("randomat_blackmarket_timer_detective", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often detectives should get items", 1, 60)

EVENT.Title = "Black Market Buyout"
EVENT.Description = "Disables Traitor and Detective shops, but periodically gives out free items from both"
EVENT.id = "blackmarket"

local blocklist = {}
local oldSetCredits = nil

function EVENT:Begin()
    -- Update this in case the role names have been changed
    EVENT.Description = "Disables " .. Randomat:GetRoleString(ROLE_TRAITOR) .. " and " .. Randomat:GetRoleString(ROLE_DETECTIVE) .. " shops, but periodically gives out free items from both"
    blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_blackmarket_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    -- Reset all target players to 0 credits
    for _, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsTraitorTeam(ply) or Randomat:IsGoodDetectiveLike(ply) then
            ply:SetCredits(0)
        end
    end

    -- Overwrite SetCredits to disable awarding credits during this event
    if oldSetCredits == nil then
        oldSetCredits = plymeta.SetCredits
        plymeta.SetCredits = function(ply, amy) end
    end

    timer.Create("RdmtBlackMarketTraitor", GetConVar("randomat_blackmarket_timer_traitor"):GetInt(), 0, function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            if Randomat:IsTraitorTeam(ply) then
                ply.blackmarketweptries = 0
                self:GiveWep(ply)
            end
        end
    end)

    timer.Create("RdmtBlackMarketDetective", GetConVar("randomat_blackmarket_timer_detective"):GetInt(), 0, function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            if Randomat:IsGoodDetectiveLike(ply) then
                ply.blackmarketweptries = 0
                self:GiveWep(ply)
            end
        end
    end)
end

function EVENT:GiveWep(ply)
    Randomat:GiveRandomShopItem(ply, Randomat:GetShopRoles(), blocklist, false,
        -- gettrackingvar
        function()
            return ply.blackmarketweptries
        end,
        -- settrackingvar
        function(value)
            ply.blackmarketweptries = value
        end,
        -- onitemgiven
        function(isequip, id)
            Randomat:CallShopHooks(isequip, id, ply)
        end)
end

function EVENT:End()
    if oldSetCredits then
        plymeta.SetCredits = oldSetCredits
        oldSetCredits = nil
    end

    timer.Remove("RdmtBlackMarketTraitor")
    timer.Remove("RdmtBlackMarketDetective")
end

function EVENT:Condition()
    -- Only run if there is at least one detective-like player living, but not the santa
    for _, v in ipairs(self:GetAlivePlayers()) do
        if ROLE_SANTA and v:GetRole() == ROLE_SANTA then
            return false
        elseif Randomat:IsGoodDetectiveLike(v) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer_traitor", "timer_detective"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)