local EVENT = {}

CreateConVar("randomat_lonelyyogs_distance", 200, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The minimum distance allowed between players", 25, 1000)
CreateConVar("randomat_lonelyyogs_interval", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The number of seconds between discombob blasts", 1, 600)

EVENT.Title = "Lonely Yogs"
EVENT.Description = "Drops a discombob between two players who get too close"
EVENT.id = "lonelyyogs"

local playerlastbombtime = {}
local playermoveloc = {}

local function ClearPlayerData(sid)
    if playerlastbombtime[sid] ~= nil then
        playerlastbombtime[sid] = nil
    end
    if playermoveloc[sid] ~= nil then
        playermoveloc[sid] = nil
    end
end

function EVENT:Begin()
    self:AddHook("SetupMove", function(ply, mv)
        if ply:Alive() and not ply:IsSpec() then
            playermoveloc[ply:SteamID64()] = ply:GetPos()
        end
    end);

    local plys = {}
    for _, v in pairs(player.GetAll()) do
        plys[v:SteamID64()] = v
    end

    local interval = GetConVar("randomat_lonelyyogs_interval"):GetInt()
    local distance = GetConVar("randomat_lonelyyogs_distance"):GetInt()
    self:AddHook("Think", function()
        for _, v in pairs(plys) do
            local playersid = v:SteamID64()
            if v:Alive() and not v:IsSpec() then
                local playerloc = v:GetPos()
                local closesid = nil
                -- Check if this player is within the configurable distance of any other player
                for sid, loc in pairs(playermoveloc) do
                    if sid ~= playersid and math.abs(playerloc:Distance(loc)) < distance then
                        closesid = sid
                        break
                    end
                end

                -- If they are, mark the current time for both players
                if closesid ~= nil and (playerlastbombtime[playersid] == nil or (CurTime() - playerlastbombtime[playersid]) > interval) then
                    playerlastbombtime[playersid] = CurTime()
                    playerlastbombtime[closesid] = CurTime()

                    local ent = ents.Create("ttt_confgrenade_proj")
                    if not IsValid(ent) then return end
                    ent:SetPos((playerloc + playermoveloc[closesid]) / 2)
                    ent:Spawn()
                    ent:SetThrower(v)
                    ent:SetDetonateExact(CurTime())

                    local phys = ent:GetPhysicsObject()
                    if not IsValid(phys) then ent:Remove() return end
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
    for _, v in pairs(player.GetAll()) do
        ClearPlayerData(v:SteamID64())
    end
end

function EVENT:Condition()
    -- Don't run this if there is a Vampire because they won't be able to use their fangs
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_VAMPIRE then
            return false
        end
    end

    return true
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"interval", "distance"}) do
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