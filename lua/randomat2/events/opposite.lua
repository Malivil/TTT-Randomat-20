local EVENT = {}

util.AddNetworkString("OppositeDayBegin")
util.AddNetworkString("OppositeDayEnd")

CreateConVar("randomat_opposite_hardmode", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to enable hard mode and switch Jump/Crouch")

EVENT.Title = "Opposite Day"
EVENT.id = "opposite"
EVENT.Categories = {"fun", "largeimpact"}

function EVENT:Begin()
    local hardmode = GetConVar("randomat_opposite_hardmode"):GetBool()
    local description = "Swaps movement keys to their opposites (e.g. Left is Right, Forward is Backward) and swaps the Fire and Reload keys."
    if hardmode then
        description = description .. "\nHard Mode is enabled so Jump and Crouch buttons have also been swapped!"
    end
    self.Description = description

    for _, p in ipairs(self:GetAlivePlayers()) do
        p:SetLadderClimbSpeed(-200)
        net.Start("OppositeDayBegin")
        net.WriteBool(hardmode)
        net.Send(p)
    end

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        victim:SetLadderClimbSpeed(200)
        net.Start("OppositeDayEnd")
        net.Send(victim)
    end)

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        ply:SetLadderClimbSpeed(-200)
        net.Start("OppositeDayBegin")
        net.WriteBool(hardmode)
        net.Send(ply)
    end)
end

function EVENT:End()
    for _, p in ipairs(player.GetAll()) do
        p:SetLadderClimbSpeed(200)
    end
    net.Start("OppositeDayEnd")
    net.Broadcast()
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"hardmode"}) do
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