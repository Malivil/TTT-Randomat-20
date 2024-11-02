local EVENT = {}

CreateConVar("randomat_distancing_timer", 10, FCVAR_ARCHIVE, "Time a player must be near someone before damage starts", 1, 600)
CreateConVar("randomat_distancing_interval", 2, FCVAR_ARCHIVE, "How often damage is done when players are too close", 1, 600)
CreateConVar("randomat_distancing_distance", 100, FCVAR_ARCHIVE, "Distance a player must be from another to be considered \"near\"", 1, 1000)
CreateConVar("randomat_distancing_damage", 1, FCVAR_ARCHIVE, "Damage done to each player who is too close", 1, 100)

EVENT.Title = "Social Distancing"
EVENT.Description = "Does a small amount of damage over time to players who spend too much time close to eachother"
EVENT.id = "distancing"
EVENT.Categories = {"moderateimpact"}

local playerthinktime = {}
local playermoveloc = {}

local function ClearPlayerData(sid)
    timer.Remove(sid .. "RdmtDistanceDamageTimer")
    if playerthinktime[sid] ~= nil then
        playerthinktime[sid] = nil
    end
    if playermoveloc[sid] ~= nil then
        playermoveloc[sid] = nil
    end
end

function EVENT:Begin()
    self:AddHook("FinishMove", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            playermoveloc[ply:SteamID64()] = ply:GetPos()
        end
    end)

    local plys = {}
    for _, v in player.Iterator() do
        plys[v:SteamID64()] = v
    end

    local damagetime = GetConVar("randomat_distancing_timer"):GetInt()
    local interval = GetConVar("randomat_distancing_interval"):GetInt()
    local distance = GetConVar("randomat_distancing_distance"):GetInt()
    local damage = GetConVar("randomat_distancing_damage"):GetInt()
    self:AddHook("Think", function()
        for _, v in pairs(plys) do
            local playersid = v:SteamID64()
            if v:Alive() and not v:IsSpec() then
                local playerloc = v:GetPos()
                local closeplayer = nil
                -- Check if this player is within the configurable distance of any other player
                for sid, loc in pairs(playermoveloc) do
                    if sid ~= playersid and math.abs(playerloc:Distance(loc)) < distance then
                        closeplayer = player.GetBySteamID64(sid)
                        break
                    end
                end

                -- If they are
                if closeplayer ~= nil then
                    -- and they don't have a time recorded yet then record the time
                    if playerthinktime[playersid] == nil then
                        playerthinktime[playersid] = CurTime()
                    end

                    -- If they have been near other players for more than the configurable amount of time and they aren't already taking damage, start damage
                    if (CurTime() - playerthinktime[playersid]) > damagetime and not timer.Exists(playersid .. "RdmtDistanceDamageTimer") then
                        timer.Create(playersid .. "RdmtDistanceDamageTimer", interval, 0, function()
                            v:TakeDamage(damage, closeplayer, nil)
                        end)
                    end

                -- Otherwise, stop doing damage
                else
                    timer.Remove(playersid .. "RdmtDistanceDamageTimer")
                    if playerthinktime[playersid] ~= nil then
                        playerthinktime[playersid] = nil
                    end
                end
            else
                if plys[playersid] ~= nil then
                    plys[playersid] = nil
                end
                ClearPlayerData(playersid)
            end
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        local sid = ply:SteamID64()
        if plys[sid] ~= nil then
            plys[sid] = nil
        end
        ClearPlayerData(sid)
    end)
end

function EVENT:End()
    for _, v in player.Iterator() do
        ClearPlayerData(v:SteamID64())
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "interval", "distance", "damage"}) do
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