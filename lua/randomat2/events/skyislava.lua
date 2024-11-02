local EVENT = {}

CreateConVar("randomat_skyislava_interval", 0.25, FCVAR_ARCHIVE, "How often damage is done", 0.1, 1)
CreateConVar("randomat_skyislava_damage", 1, FCVAR_ARCHIVE, "Damage done to each player", 1, 100)

EVENT.Title = "The Sky is Lava"
EVENT.Description = "Players take damage while they are in the air"
EVENT.id = "skyislava"
EVENT.Categories = {"moderateimpact"}

local jumptimers = {}

function EVENT:Begin()
    local interval = GetConVar("randomat_skyislava_interval"):GetFloat()
    local damage = GetConVar("randomat_skyislava_damage"):GetInt()
    self:AddHook("FinishMove", function(ply, mv)
        if not ply:Alive() or ply:IsSpec() then return end

        local sid = ply:SteamID64()
        if ply:IsOnGround() or ply:WaterLevel() >= 2 then
            -- If the player is on the ground (or in the water), remove their timer if they have one
            if jumptimers[sid] then
                timer.Remove(jumptimers[sid])
                jumptimers[sid] = nil
            end
        -- Otherwise create a timer for the user if they don't have one
        elseif not jumptimers[sid] then
            local timerId = "RdmtSkyIsLava_JumpTimer_" .. sid
            jumptimers[sid] = timerId

            timer.Create(timerId, interval, 0, function()
                local hp = ply:Health()
                if hp <= damage then
                    Randomat:PrintMessage(ply, MSG_PRINTBOTH, "You've flown close to the sun for too long and have burnt to a crisp.")
                    ply:Kill()
                else
                    ply:SetHealth(hp - damage)
                end
            end)
        end
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end

        local sid = victim:SteamID64()
        if not jumptimers[sid] then return end
        timer.Remove(jumptimers[sid])
        jumptimers[sid] = nil
    end)
end

function EVENT:End()
    for _, t in pairs(jumptimers) do
        if t then
            timer.Remove(t)
        end
    end
    table.Empty(jumptimers)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"interval", "damage"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "damage" and 0 or 2
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)