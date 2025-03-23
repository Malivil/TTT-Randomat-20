local EVENT = {}

CreateConVar("randomat_delayedreaction_time", 5, FCVAR_NONE, "The time in seconds that damage should be delayed", 1, 100)

EVENT.Title = "Delayed Reaction"
EVENT.Description = "Delays damage done to players for " .. GetConVar("randomat_delayedreaction_time"):GetInt() .. " seconds"
EVENT.id = "delayedreaction"
EVENT.Categories = {"largeimpact"}

local pending_damage = {}

function EVENT:BeforeEventTrigger(ply, options, ...)
    self.Description = "Delays damage done to players for " .. GetConVar("randomat_delayedreaction_time"):GetInt() .. " seconds"
end

function EVENT:Begin()
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not IsPlayer(ent) then return end

        local custom_damage = dmginfo:GetDamageCustom()
        -- If this is set, assume that we're the ones that set it and don't check this damage info
        if custom_damage == DMG_DIRECT then return end

        local sid64 = ent:SteamID64()
        -- Keep track of the number of pending timers we have for this player so they each get unique IDs
        if not pending_damage[sid64] then
            pending_damage[sid64] = 0
        end
        local index = pending_damage[sid64] + 1
        pending_damage[sid64] = index

        -- Store this info now because by the time we need it after the delay it's been cleared out
        local info = {
            dmg = dmginfo:GetDamage(),
            typ = dmginfo:GetDamageType(),
            atk = dmginfo:GetAttacker(),
            inf = dmginfo:GetInflictor(),
            foc = dmginfo:GetDamageForce(),
            pos = dmginfo:GetDamagePosition(),
            rpo = dmginfo:GetReportedPosition()
        }

        local delay = GetConVar("randomat_delayedreaction_time"):GetInt()
        timer.Create("RdmtDelayedReaction_" .. sid64 .. "_" .. index, delay, 1, function()
            -- Make sure they still exist and are alive
            if not IsPlayer(ent) or not ent:Alive() or ent:IsSpec() then return end

            local dmg = DamageInfo()
            -- Set this so that we can check for it since it is not normally used in GMod
            dmg:SetDamageCustom(DMG_DIRECT)
            dmg:SetDamage(info.dmg)
            dmg:SetDamageType(info.typ)
            dmg:SetAttacker(IsValid(info.atk) and info.atk or game.GetWorld())
            dmg:SetInflictor(IsValid(info.inf) and info.inf or game.GetWorld())
            dmg:SetDamageForce(info.foc)
            dmg:SetDamagePosition(info.pos)
            dmg:SetReportedPosition(info.rpo)
            ent:TakeDamageInfo(dmg)
        end)

        -- Stop damage from actually happening
        dmginfo:ScaleDamage(0)
        dmginfo:SetDamage(0)
    end)
end

function EVENT:End()
    for sid64, last_index in pairs(pending_damage) do
        for i = 1, last_index do
            timer.Remove("RdmtDelayedReaction_" .. sid64 .. "_" .. i)
        end
    end
    table.Empty(pending_damage)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"time"}) do
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