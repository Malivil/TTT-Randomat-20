local EVENT = {}

EVENT.Title = "Flu Season"
EVENT.Description = "Randomly infects a player with the flu, causing them to move more slowly and sneeze occasionally"
EVENT.id = "flu"
EVENT.Categories = {"moderateimpact"}

local sneezecount = 17
local playerthinktime = {}
local playermoveloc = {}
local playerflustatus = {}
local playerhealth = {}

CreateConVar("randomat_flu_timer", 1, FCVAR_NONE, "Time a player must be near someone before it spreads", 1, 600)
CreateConVar("randomat_flu_interval", 5, FCVAR_NONE, "How often effects happen to infected", 1, 600)
CreateConVar("randomat_flu_distance", 100, FCVAR_NONE, "Distance a player must be from another to be considered \"near\"", 1, 1000)
CreateConVar("randomat_flu_chance", 25, FCVAR_NONE, "Spreading chance", 1, 100)
CreateConVar("randomat_flu_speed_factor", 0.8, FCVAR_NONE, "What speed the infected player should be reduced to", 0.5, 1)

for i = 1, sneezecount do
    util.PrecacheSound("sneezes/sneeze" .. i .. ".mp3")
end

local function ClearPlayerData(ply)
    local sid64 = ply:SteamID64()
    timer.Remove(sid64 .. "RdmtFluSneezeTimer")
    if playerthinktime[sid64] ~= nil then
        playerthinktime[sid64] = nil
    end
    if playermoveloc[sid64] ~= nil then
        playermoveloc[sid64] = nil
    end
    if playerhealth[sid64] ~= nil then
        playerhealth[sid64] = nil
    end
    if playerflustatus[sid64] ~= nil then
        playerflustatus[sid64] = false
    end
end

local function SpreadFlu(ply)
    local interval = GetConVar("randomat_flu_interval"):GetInt()
    local sid64 = ply:SteamID64()
    playerflustatus[sid64] = true
    playerhealth[sid64] = ply:Health()

    -- Reduce the player speed on the client
    local speed_factor = GetConVar("randomat_flu_speed_factor"):GetFloat()
    net.Start("RdmtSetSpeedMultiplier")
    net.WriteFloat(speed_factor)
    net.WriteString("RdmtFluSpeed")
    net.Send(ply)

    timer.Create(sid64 .. "RdmtFluSneezeTimer", interval, 0, function()
        local sneeze = math.random(sneezecount)
        ply:EmitSound(Sound("sneezes/sneeze" .. sneeze .. ".mp3"))

        local recoilDirection = 1
        if math.random(2) == 1 then
            recoilDirection = -1
        end

        -- Delay the punch so it kinda lines up with the sound
        timer.Simple(1, function()
            ply:ViewPunch(Angle(math.random(7) * recoilDirection, math.random(7) * recoilDirection, 0))
        end)
    end)
end

function EVENT:Begin()
    self:AddHook("FinishMove", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            playermoveloc[ply:SteamID64()] = ply:GetPos()
        end
    end)

    -- Reduce the player speed on the server
    local speed_factor = GetConVar("randomat_flu_speed_factor"):GetFloat()
    self:AddHook("TTTSpeedMultiplier", function(ply, mults)
        if not ply:Alive() or ply:IsSpec() then return end
        local sid64 = ply:SteamID64()
        if playerflustatus[sid64] then
            table.insert(mults, speed_factor)
        end
    end)

    local plys = {}
    local first = true
    for _, v in ipairs(self:GetAlivePlayers(true)) do
        local sid64 = v:SteamID64()
        plys[sid64] = v

        -- First random player starts with the flu
        if first then
            SpreadFlu(v)
        else
            playerflustatus[sid64] = false
        end
        first = false
    end

    local checktime = GetConVar("randomat_flu_timer"):GetInt()
    local distance = GetConVar("randomat_flu_distance"):GetInt()
    local chance = GetConVar("randomat_flu_chance"):GetInt()
    self:AddHook("Think", function()
        for _, v in pairs(plys) do
            local sid64 = v:SteamID64()
            if v:Alive() and not v:IsSpec() then
                if not playerflustatus[sid64] then
                    local playerloc = v:GetPos()
                    local tooclose = false
                    -- Check if this player is within the configurable distance of any other player with the flu
                    for name, loc in pairs(playermoveloc) do
                        if name ~= sid64 and playerflustatus[name] and math.abs(playerloc:Distance(loc)) < distance then
                            tooclose = true
                            break
                        end
                    end

                    -- If they are
                    if tooclose then
                        -- and they don't have a time recorded yet then record the time
                        if playerthinktime[sid64] == nil then
                            playerthinktime[sid64] = CurTime()
                        end
                        if playerflustatus[sid64] == nil then
                            playerflustatus[sid64] = false
                        end

                        --- If they have been near other players for more than the configurable amount of time and they don't already have the flu, check if they should get it
                        if (CurTime() - playerthinktime[sid64]) > checktime and not playerflustatus[sid64] and math.random(0, 100) <= chance then
                            SpreadFlu(v)
                        end
                    -- Otherwise, reset the timer
                    else
                        if playerthinktime[sid64] ~= nil then
                            playerthinktime[sid64] = nil
                        end
                    end
                -- Cure the player if they are healed
                elseif v:Health() > playerhealth[sid64] then
                    ClearPlayerData(v)
                -- Otherwise track their current health
                else
                    playerhealth[sid64] = v:Health()
                end
            else
                if plys[sid64] ~= nil then
                    plys[sid64] = nil
                end
                ClearPlayerData(v)
            end
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        local sid64 = ply:SteamID64()
        if plys[sid64] == nil then
            plys[sid64] = ply
        end
    end)
end

function EVENT:End()
    for _, v in player.Iterator() do
        ClearPlayerData(v)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "interval", "distance", "chance", "speed_factor"}) do
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