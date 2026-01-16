local EVENT = {}

EVENT.Title = "You can only jump once."
EVENT.ExtDescription = "Explodes players who jump more than once"
EVENT.id = "jump"
EVENT.Type = EVENT_TYPE_JUMPING
EVENT.Categories = {"largeimpact"}

CreateConVar("randomat_jump_spam", 0, FCVAR_NONE, "Whether to show the message again for a player who doesn't die")
CreateConVar("randomat_jump_kill_blast_immune", 1, FCVAR_NONE, "Whether to kill players who are immune to blast damage")

local timerIds = {}

function EVENT:Begin()
    for _, v in player.Iterator() do
        v.rdmtJumps = 0
    end

    local spam = GetConVar("randomat_jump_spam"):GetBool()
    local killBlastImmune = GetConVar("randomat_jump_kill_blast_immune"):GetBool()
    timer.Create("RdmtJumpStartDelay", 1, 1, function()
        self:AddHook("KeyPress", function(ply, key)
            if key ~= IN_JUMP then return end
            if not IsPlayer(ply) then return end
            if not ply:Alive() or ply:IsSpec() then return end

            -- Don't count "jumps" if the player is underwater
            if ply:WaterLevel() >= 3 then return end

            if ply.rdmtJumps > 0 and (ply.rdmtJumps == 1 or spam) then
                util.BlastDamage(ply, ply, ply:GetPos(), 100, 500)
                if not Randomat:ShouldActLikeJester(ply) and killBlastImmune then
                    local timerId = "RdmtJumpKillDelay_" .. ply:SteamID64()
                    table.insert(timerIds, timerId)

                    -- Delay this by a frame so on-death hooks can trigger first
                    timer.Create(timerId, 0, 1, function()
                        if not IsPlayer(ply) then return end
                        if not ply:Alive() or ply:IsSpec() then return end

                        timer.Create(timerId, 0.25, 1, function()
                            ply:Kill()
                        end)
                    end)
                end
                self:SmallNotify(ply:Nick() .. " tried to jump twice.")
            end

            ply.rdmtJumps = ply.rdmtJumps + 1
        end)
    end)
end

function EVENT:End()
    for _, v in player.Iterator() do
        v.rdmtJumps = nil
    end
    for _, timerId in ipairs(timerIds) do
        timer.Remove(timerId)
    end
    table.Empty(timerIds)
    timer.Remove("RdmtJumpStartDelay")
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"spam", "kill_blast_immune"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return {}, checks
end

Randomat:register(EVENT)