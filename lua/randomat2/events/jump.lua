local EVENT = {}

EVENT.Title = "You can only jump once."
EVENT.id = "jump"

CreateConVar("randomat_jump_jesterspam", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show the message multiple times for a Jester/Swapper")
CreateConVar("randomat_jump_quackspam", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show the message multiple times for a Quack")

function EVENT:Begin()
    for _, v in ipairs(player.GetAll()) do
        v.rdmtJumps = 0
    end

    timer.Create("RdmtJumpStartDelay", 1, 1, function()
        self:AddHook("KeyPress", function(ply, key)
            -- Don't count "jumps" if the player is underwater
            if key == IN_JUMP and ply:Alive() and not ply:IsSpec() and (ply:WaterLevel() < 3) then
                if ply.rdmtJumps > 0 then
                    if ply.rdmtJumps == 1 or
                        (Randomat:ShouldActLikeJester(ply) and GetConVar("randomat_jump_jesterspam"):GetBool()) or
                        (ROLE_QUACK ~= -1 and ply:GetRole() == ROLE_QUACK and GetConVar("randomat_jump_quackspam"):GetBool()) then
                        util.BlastDamage(ply, ply, ply:GetPos(), 100, 500)
                        self:SmallNotify(ply:Nick() .. " tried to jump twice.")
                    end
                end

                ply.rdmtJumps = ply.rdmtJumps + 1
            end
        end)
    end)
end

function EVENT:End()
    for _, v in ipairs(player.GetAll()) do
        v.rdmtJumps = nil
    end
    timer.Remove("RdmtJumpStartDelay")
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"jesterspam", "quackspam"}) do
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