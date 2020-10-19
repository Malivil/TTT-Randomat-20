local EVENT = {}

EVENT.Title = "Social Distancing"
EVENT.id = "distancing"

local playerthinktime = {}
local playermoveloc = {}

CreateConVar("randomat_distancing_timer", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time a player must be near someone before damage starts", 1, 600)
CreateConVar("randomat_distancing_interval", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often damage is done when players are too close", 1, 600)
CreateConVar("randomat_distancing_distance", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Distance a player must be from another to be considered \"near\"", 1, 1000)
CreateConVar("randomat_distancing_damage", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Damage done to each player who is too close", 1, 100)

local function ClearPlayerData(uid)
    timer.Remove(uid .. "RdmtDistanceDamageTimer")
    if playerthinktime[uid] ~= nil then
        playerthinktime[uid] = nil
    end
    if playermoveloc[uid] ~= nil then
        playermoveloc[uid] = nil
    end
end

function EVENT:Begin()
    self:AddHook("SetupMove", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            playermoveloc[ply:UniqueID()] = ply:GetPos()
        end
    end);

    local plys = {}
    for _, v in pairs(player.GetAll()) do
        plys[v:UniqueID()] = v
    end

    local damagetime = GetConVar("randomat_distancing_timer"):GetInt()
    local interval = GetConVar("randomat_distancing_interval"):GetInt()
    local distance = GetConVar("randomat_distancing_distance"):GetInt()
    local damage = GetConVar("randomat_distancing_damage"):GetInt()
    self:AddHook("Think", function()
        for _, v in pairs(plys) do
            local playeruid = v:UniqueID()
            if v:Alive() and not v:IsSpec() then
                local playerloc = v:GetPos()
                local closeplayer = nil
                -- Check if this player is within the configurable distance of any other player
                for uid, loc in pairs(playermoveloc) do
                    if uid ~= playeruid and math.abs(playerloc:Distance(loc)) < distance then
                        closeplayer = player.GetByUniqueID(uid)
                        break
                    end
                end

                -- If they are
                if closeplayer ~= nil then
                    -- and they don't have a time recorded yet then record the time
                    if playerthinktime[playeruid] == nil then
                        playerthinktime[playeruid] = CurTime()
                    end

                    --- If they have been near other players for more than the configurable amount of time and they aren't already taking damage, start damage
                    if (CurTime() - playerthinktime[playeruid]) > damagetime and not timer.Exists(playeruid .. "RdmtDistanceDamageTimer") then
                        timer.Create(playeruid .. "RdmtDistanceDamageTimer", interval, 0, function()
                            v:TakeDamage(damage, closeplayer, nil)
                        end)
                    end

                -- Otherwise, stop doing damage
                else
                    timer.Remove(playeruid .. "RdmtDistanceDamageTimer")
                    if playerthinktime[playeruid] ~= nil then
                        playerthinktime[playeruid] = nil
                    end
                end
            else
                if plys[playeruid] ~= nil then
                    plys[playeruid] = nil
                end
                ClearPlayerData(playeruid)
            end
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        local uid = ply:UniqueID()
        if plys[uid] ~= nil then
            plys[uid] = nil
        end
        ClearPlayerData(uid)
    end)
end

function EVENT:End()
    for _, v in pairs(player.GetAll()) do
        ClearPlayerData(v:UniqueID())
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