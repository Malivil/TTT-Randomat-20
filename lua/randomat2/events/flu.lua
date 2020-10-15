local EVENT = {}

EVENT.Title = "Flu Season"
EVENT.id = "flu"

util.AddNetworkString("RdmtFluSpeed")

local sneezecount = 17
local playerthinktime = {}
local playermoveloc = {}
local playerflustatus = {}
local playerhealth = {}

CreateConVar("randomat_flu_timer", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time a player must be near someone before it spreads", 1, 600)
CreateConVar("randomat_flu_interval", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often effects happen to infected", 1, 600)
CreateConVar("randomat_flu_distance", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Distance a player must be from another to be considered \"near\"", 1, 1000)
CreateConVar("randomat_flu_chance", 25, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Spreading chance", 1, 100)
CreateConVar("randomat_flu_speed_factor", 0.8, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "What speed the infected player should be reduced to", 0.5, 1)

for i = 1, sneezecount do
    util.PrecacheSound("sneezes/sneeze" .. i .. ".mp3")
end

local function ClearPlayerData(ply)
    local playername = ply:GetName()
    timer.Remove(playername .. "RdmtFluSneezeTimer")
    if playerthinktime[playername] ~= nil then
        playerthinktime[playername] = nil
    end
    if playermoveloc[playername] ~= nil then
        playermoveloc[playername] = nil
    end
    if playerhealth[playername] ~= nil then
        playerhealth[playername] = nil
    end
    if playerflustatus[playername] ~= nil then
        playerflustatus[playername] = false
    end

    ply:SetNWFloat("RmdtSpeedModifier", 1)
end

local function SpreadFlu(ply)
    local interval = GetConVar("randomat_flu_interval"):GetInt()
    local playername = ply:GetName()
    playerflustatus[playername] = true
    playerhealth[playername] = ply:Health()

    -- Reduce the player speed
    local speed = GetConVar("randomat_flu_speed_factor"):GetFloat() * ply:GetNWFloat("RmdtSpeedModifier", 1)
    ply:SetNWFloat("RmdtSpeedModifier", speed)

    timer.Create(playername .. "RdmtFluSneezeTimer", interval, 0, function()
        local sneeze = math.random(1, sneezecount)
        ply:EmitSound(Sound("sneezes/sneeze" .. sneeze .. ".mp3"))

        local recoilDirection = 1
        if math.random(2) == 1 then
            recoilDirection = -1
        end

        -- Delay the punch so it kinda lines up with the sound
        timer.Simple(1, function()
            ply:ViewPunch(Angle(math.random(1, 7) * recoilDirection, math.random(1, 7) * recoilDirection, 0))
        end)
    end)
end

function EVENT:Begin()
    hook.Add("SetupMove", "RdmtFluMovementHook", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            playermoveloc[ply:GetName()] = ply:GetPos()
        end
    end);

    local plys = {}
    local first = true
    for _, v in pairs(self:GetAlivePlayers(true)) do
        local playername = v:GetName()
        plys[playername] = v

        -- First random player starts with the flu
        if first then
            SpreadFlu(v)
        else
            playerflustatus[playername] = false
        end
        first = false
    end

    local checktime = GetConVar("randomat_flu_timer"):GetInt()
    local distance = GetConVar("randomat_flu_distance"):GetInt()
    local chance = GetConVar("randomat_flu_chance"):GetInt()
    hook.Add("Think", "RdmtFluCheckHook", function()
        for _, v in pairs(plys) do
            local playername = v:GetName()
            if v:Alive() and not v:IsSpec() then
                if not playerflustatus[playername] then
                    local playerloc = v:GetPos()
                    local tooclose = false
                    -- Check if this player is within the configurable distance of any other player with the flu
                    for name, loc in pairs(playermoveloc) do
                        if name ~= playername and playerflustatus[name] and math.abs(playerloc:Distance(loc)) < distance then
                            tooclose = true
                            break
                        end
                    end

                    -- If they are
                    if tooclose then
                        -- and they don't have a time recorded yet then record the time
                        if playerthinktime[playername] == nil then
                            playerthinktime[playername] = CurTime()
                        end
                        if playerflustatus[playername] == nil then
                            playerflustatus[playername] = false
                        end

                        --- If they have been near other players for more than the configurable amount of time and they don't already have the flu, check if they should get it
                        if (CurTime() - playerthinktime[playername]) > checktime and not playerflustatus[playername] and math.random(0, 100) <= chance then
                            SpreadFlu(v)
                        end
                    -- Otherwise, reset the timer
                    else
                        if playerthinktime[playername] ~= nil then
                            playerthinktime[playername] = nil
                        end
                    end
                -- Cure the player if they are healed
                elseif v:Health() > playerhealth[playername] then
                    ClearPlayerData(v)
                -- Otherwise track their current health
                else
                    playerhealth[playername] = v:Health()
                end
            else
                if plys[playername] ~= nil then
                    plys[playername] = nil
                end
                ClearPlayerData(v)
            end
        end
    end)

    hook.Add("PlayerSpawn", "RdmtFluSpawnHook", function(ply)
        local playername = ply:GetName()
        if plys[playername] ~= nil then
            plys[playername] = nil
        end
        ClearPlayerData(ply)
    end)
end

function EVENT:End()
    hook.Remove("SetupMove", "RdmtFluMovementHook")
    hook.Remove("Think", "RdmtFluCheckHook")
    hook.Remove("PlayerSpawn", "RdmtFluSpawnHook")

    for _, v in pairs(player.GetAll()) do
        ClearPlayerData(v)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer", "interval", "distance", "chance", "speed_factor"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "speed_factor" and 1 or 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)