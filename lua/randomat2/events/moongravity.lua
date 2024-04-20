local EVENT = {}

CreateConVar("randomat_moongravity_gravity", 0.1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The gravity scale", 0.1, 0.9)

EVENT.Title = "What? Moon Gravity on Earth?"
EVENT.Description = "Lowers everyone's gravity to a fraction of what it is normally"
EVENT.id = "moongravity"
EVENT.Categories = {"fun", "moderateimpact"}

local function SetGravity(alive_players)
    local gravity = GetConVar("randomat_moongravity_gravity"):GetFloat()
    for _, ply in ipairs(alive_players) do
        ply:SetGravity(gravity)
    end
end

function EVENT:Begin()
    SetGravity(self:GetAlivePlayers())
    self:Timer()
end

function EVENT:Timer()
    timer.Create("RandomatMoonGravityTimer", 1, 0, function()
        SetGravity(self:GetAlivePlayers())
    end)
end

function EVENT:End()
    timer.Remove("RandomatMoonGravityTimer")
    for _, ply in player.Iterator() do
        ply:SetGravity(1)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"gravity"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 1
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)