local EVENT = {}

EVENT.Title = "You can only jump once."
EVENT.id = "jump"

CreateConVar("randomat_jump_jesterspam", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show the message multiple times for a Jester/Swapper")

function EVENT:Begin()
    for _, v in pairs(player.GetAll()) do
        v.rdmtJumps = 0
    end

    self:AddHook("KeyPress", function(ply, key)
        if key == IN_JUMP and ply:Alive() and not ply:IsSpec() then
            if ply.rdmtJumps > 0 then
                if ply.rdmtJumps == 1 or not Randomat:IsJesterTeam(ply) or GetConVar("randomat_jump_jesterspam"):GetBool() then
                    util.BlastDamage(ply, ply, ply:GetPos(), 100, 500)
                    self:SmallNotify(ply:Nick() .. " tried to jump twice.")
                end
            end

            ply.rdmtJumps = ply.rdmtJumps + 1
        end

    end)
end

function EVENT:End()
    for _, v in pairs(player.GetAll()) do
        v.rdmtJumps = nil
    end
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in pairs({"jesterspam"}) do
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