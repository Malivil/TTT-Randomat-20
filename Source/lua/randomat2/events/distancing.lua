local EVENT = {}

EVENT.Title = "Social Distancing"
EVENT.id = "distancing"

local playerthinktime = {}
local playermoveloc = {}

CreateConVar("randomat_distancing_timer", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time a player must be near someone before damage starts", 1, 600)
CreateConVar("randomat_distancing_interval", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often damage is done when players are too close", 1, 600)
CreateConVar("randomat_distancing_distance", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Distance a player must be from another to be considered \"near\"", 1, 1000)
CreateConVar("randomat_distancing_damage", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Damage done to each player who is too close", 1, 100)

local function ClearPlayerData(playername)
    timer.Remove(playername .. "RdmtDistanceDamageTimer")
    if playerthinktime[playername] ~= nil then
        playerthinktime[playername] = nil
    end
    if playermoveloc[playername] ~= nil then
        playermoveloc[playername] = nil
    end
end

function EVENT:Begin()
    hook.Add("SetupMove", "RdmtDistancingMovementHook", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            playermoveloc[ply:GetName()] = ply:GetPos()
        end
    end);

    local plys = {}
    for _, v in pairs(player.GetAll()) do
        plys[v:GetName()] = v
    end

    local damagetime = GetConVar("randomat_distancing_timer"):GetInt()
    local interval = GetConVar("randomat_distancing_interval"):GetInt()
    local distance = GetConVar("randomat_distancing_distance"):GetInt()
    local damage = GetConVar("randomat_distancing_damage"):GetInt()
    hook.Add("Think", "RdmtDistancingPunishHook", function()
        for _, v in pairs(plys) do
            local playername = v:GetName()
            if v:Alive() and not v:IsSpec() then
                local playerloc = v:GetPos()
                local tooclose = false
                -- Check if this player is within the configurable distance of any other player
                for name, loc in pairs(playermoveloc) do
                    if name ~= playername and math.abs(playerloc:Distance(loc)) < distance then
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

                    --- If they have been near other players for more than the configurable amount of time and they aren't already taking damage, start damage
                    if (CurTime() - playerthinktime[playername]) > damagetime and not timer.Exists(playername .. "RdmtDistanceDamageTimer") then
                        timer.Create(playername .. "RdmtDistanceDamageTimer", interval, 0, function()
                            v:TakeDamage(damage, nil, nil)
                        end)
                    end

                -- Otherwise, stop doing damage
                else
                    timer.Remove(playername .. "RdmtDistanceDamageTimer")
                    if playerthinktime[playername] ~= nil then
                        playerthinktime[playername] = nil
                    end
                end
            else
                if plys[playername] ~= nil then
                    plys[playername] = nil
                end
                ClearPlayerData(playername)
            end
        end
    end)

    hook.Add("PlayerSpawn", "RdmtDistancingSpawnHook", function(ply)
        local playername = ply:GetName()
        if plys[playername] ~= nil then
            plys[playername] = nil
        end
        ClearPlayerData(playername)
    end)
end

function EVENT:End()
    hook.Remove("SetupMove", "RdmtDistancingMovementHook")
    hook.Remove("Think", "RdmtDistancingPunishHook")
    hook.Remove("PlayerSpawn", "RdmtDistancingSpawnHook")

    for _, v in pairs(player.GetAll()) do
        ClearPlayerData(v:GetName())
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer", "interval", "distance", "damage"}) do
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