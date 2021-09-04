local EVENT = {}

CreateConVar("randomat_breadcrumbs_start_width", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The trail's starting width", 1, 100)
CreateConVar("randomat_breadcrumbs_end_width", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The trail's ending width", 1, 100)
CreateConVar("randomat_breadcrumbs_fade_time", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many seconds the trail should last", 1, 60)

EVENT.Title = "Breadcrumbs"
EVENT.Description = "Follow the colorful trails to find the other players"
EVENT.id = "breadcrumbs"

local player_colors = {}
local player_trails = {}

local function CreateTrail(ply)
    local sid = ply:SteamID64()
    if not player_colors[sid] then
        local colors = {
            COLOR_WHITE,
            COLOR_GREEN,
            COLOR_RED,
            COLOR_YELLOW,
            COLOR_LGRAY,
            COLOR_BLUE,
            COLOR_PINK,
            COLOR_ORANGE
        }
        player_colors[sid] = colors[math.random(1, #colors)]
    end

    local startWidth = GetConVar("randomat_breadcrumbs_start_width"):GetInt()
    local endWidth = GetConVar("randomat_breadcrumbs_end_width"):GetInt()
    local fadeTime = GetConVar("randomat_breadcrumbs_fade_time"):GetInt()
    local trail = util.SpriteTrail(ply, 0, player_colors[sid], false, startWidth, endWidth, fadeTime, 1 / (startWidth + endWidth) * 0.5, "trails/plasma.vmt")
    player_trails[sid] = trail
end

local function RemoveTrail(sid)
    local trail = player_trails[sid]
    if trail and IsValid(trail) then
        trail:Remove()
        player_trails[sid] = nil
    end
end

function EVENT:Begin()
    for _, p in ipairs(self:GetAlivePlayers()) do
        CreateTrail(p)
    end

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        CreateTrail(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        RemoveTrail(victim:SteamID64())
    end)
end

function EVENT:End()
    for sid, _ in pairs(player_trails) do
        RemoveTrail(sid)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"start_width", "end_width", "fade_time"}) do
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