local EVENT = {}

CreateConVar("randomat_stickwithme_warning_timer", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time a player has to find their partner at the start of the event", 1, 600)
CreateConVar("randomat_stickwithme_damage_timer", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time a player must be away from their partner before damage starts", 1, 600)
CreateConVar("randomat_stickwithme_damage_interval", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often damage is done when partners are too far", 1, 600)
CreateConVar("randomat_stickwithme_damage_distance", 200, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Maximum partner distance before damage", 1, 1000)
CreateConVar("randomat_stickwithme_damage_amount", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Damage done to each player who is too far", 1, 100)
CreateConVar("randomat_stickwithme_highlight", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to highlight player partners")

EVENT.Title = "Stick With Me"
EVENT.Description = "Pairs players together, forcing them to stay close to eachother or take damage"
EVENT.id = "stickwithme"
EVENT.Categories = {"biased_innocent", "biased", "moderateimpact"}

util.AddNetworkString("RdmtStickWithMeHighlightAdd")
util.AddNetworkString("RdmtStickWithMeHighlightRemove")

local pairthinktime = {}

local function ClearPlayerData(sid)
    timer.Remove(sid .. "RdmtStickWithMeDamageTimer")
    if pairthinktime[sid] ~= nil then
        pairthinktime[sid] = nil
    end
end

local function SendPartnerMessage(ply, partner, warningtime)
    local message = "Your partner is " .. partner .. ". You have " .. warningtime .. " seconds to find them!"
    -- Delay this so it appears after the message in chat
    timer.Simple(0.1, function()
        ply:PrintMessage(HUD_PRINTTALK, message)
    end)
    -- Delay this so it appears after the description on screen
    timer.Create("RandomatStickWithMePairTimer_" .. ply:SteamID64(), 1, 5, function()
        Randomat:PrintMessage(ply, MSG_PRINTCENTER, message)
    end)
end

function EVENT:Begin()
    local ply1 = {}
    local ply2 = {}
    local ply_pairs = {}
    local x = 0
    for _, v in ipairs(self:GetAlivePlayers(true)) do
        if x % 2 == 0 then
            table.insert(ply1, v)
        else
            table.insert(ply2, v)
        end
        x = x+1
    end

    local warningtime = GetConVar("randomat_stickwithme_warning_timer"):GetInt()
    local highlight = GetConVar("randomat_stickwithme_highlight"):GetBool()

    local size = #ply2
    for i = 1, size do
        SendPartnerMessage(ply1[i], ply2[i]:Nick(), warningtime)
        SendPartnerMessage(ply2[i], ply1[i]:Nick(), warningtime)
        Randomat:LogEvent("[RANDOMAT] " .. ply1[i]:Nick() .. " and " .. ply2[i]:Nick() .. " are now partners.")

        ply_pairs[ply1[i]:SteamID64()] = ply2[i]
        ply_pairs[ply2[i]:SteamID64()] = ply1[i]

        if highlight then
            net.Start("RdmtStickWithMeHighlightAdd")
            net.WritePlayer(ply2[i])
            net.Send(ply1[i])

            net.Start("RdmtStickWithMeHighlightAdd")
            net.WritePlayer(ply1[i])
            net.Send(ply2[i])
        end
    end

    -- Bypass culling so you can always see your partner through walls
    self:AddCullingBypass(nil, function(ply, tgt)
        local sid64 = ply:SteamID64()
        if not ply_pairs[sid64] then return false end

        return ply_pairs[sid64] == tgt
    end)

    timer.Create("RdmtStickWithMeDelay", warningtime, 1, function()
        local damagetime = GetConVar("randomat_stickwithme_damage_timer"):GetInt()
        local interval = GetConVar("randomat_stickwithme_damage_interval"):GetInt()
        local distance = GetConVar("randomat_stickwithme_damage_distance"):GetInt()
        local damage = GetConVar("randomat_stickwithme_damage_amount"):GetInt()
        self:AddHook("Think", function()
            for i = 1, size do
                local first = ply1[i]
                local first_sid = first:SteamID64()
                local first_loc = first:GetPos()

                local second = ply2[i]
                local second_sid = second:SteamID64()
                local second_loc = second:GetPos()

                local pair_sid = first_sid .. "_" .. second_sid

                -- Do damage if either player is dead or they are both alive but too far away
                local do_damage = (not IsValid(first) or not first:Alive() or first:IsSpec()) or
                                    (not IsValid(second) or not second:Alive() or second:IsSpec()) or
                                    math.abs(first_loc:Distance(second_loc)) > distance
                if do_damage then
                    -- and they don't have a time recorded yet then record the time
                    if pairthinktime[pair_sid] == nil then
                        pairthinktime[pair_sid] = CurTime()
                    end

                    -- If they have been near other players for more than the configurable amount of time and they aren't already taking damage, start damage
                    if (CurTime() - pairthinktime[pair_sid]) > damagetime and not timer.Exists(pair_sid .. "RdmtStickWithMeDamageTimer") then
                        timer.Create(pair_sid .. "RdmtStickWithMeDamageTimer", interval, 0, function()
                            if IsValid(first) and first:Alive() and not first:IsSpec() then
                                first:TakeDamage(damage)
                            end
                            if IsValid(second) and second:Alive() and not second:IsSpec() then
                                second:TakeDamage(damage)
                            end
                        end)
                    end
                -- Otherwise, stop doing damage
                else
                    ClearPlayerData(pair_sid)
                end
            end
        end)
    end)
end

function EVENT:End()
    timer.Remove("RdmtStickWithMeDelay")
    net.Start("RdmtStickWithMeHighlightRemove")
    net.Broadcast()
    for k, _ in pairs(pairthinktime) do
        ClearPlayerData(k)
    end

    for _, v in ipairs(player.GetAll()) do
        timer.Remove("RandomatStickWithMePairTimer_" .. v:SteamID64())
    end
end

function EVENT:Condition()
    -- Only run this if there is an even number of players
    return #self:GetAlivePlayers() % 2 == 0
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"warning_timer", "damage_timer", "damage_interval", "damage_distance", "damage_amount"}) do
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

    local checks = {}
    for _, v in ipairs({"highlight"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return sliders, checks
end

Randomat:register(EVENT)