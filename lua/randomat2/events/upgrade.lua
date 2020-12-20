local EVENT = {}

util.AddNetworkString("UpgradeEventBegin")
util.AddNetworkString("RdmtCloseUpgradeFrame")
util.AddNetworkString("rdmtPlayerChoseSur")
util.AddNetworkString("rdmtPlayerChoseSk")

CreateConVar("randomat_upgrade_chooserole", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the innocent should choose their new role.")

EVENT.Title = "An innocent has been upgraded!"
EVENT.id = "upgrade"

local function GetEventDescription()
    local choose = GetConVar("randomat_upgrade_chooserole"):GetBool()
    local action
    if choose then
        action = "given the choice of becoming a Mercenary or a Killer"
    else
        action = "upgraded to a Mercenary"
    end
    return "A random vanilla Innocent is " .. action
end

EVENT.Description = GetEventDescription()

function EVENT:Begin()
    local choose = GetConVar("randomat_upgrade_chooserole"):GetBool()
    for _, ply in pairs(self:GetAlivePlayers(true)) do
        if ply:GetRole() == ROLE_INNOCENT then
            if choose then
                -- Wait for the notification to go away first
                timer.Simple(5, function()
                    net.Start("UpgradeEventBegin")
                    net.Send(ply)
                end)
            else
                Randomat:SetRole(ply, ROLE_MERCENARY)
                ply:SetCredits(GetConVar("ttt_mer_credits_starting"):GetInt())
                SendFullStateUpdate()
            end
            return
        end
    end
end

function EVENT:End()
    net.Start("RdmtCloseUpgradeFrame")
    net.Broadcast()
end

function EVENT:Condition()
    -- Don't allow this if Mercenary is disabled
    if ConVarExists("ttt_mercenary_enabled") and not GetConVar("ttt_mercenary_enabled"):GetBool() then
        return false
    end

    local merc = 0
    local inno = 0
    local kil = 0
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_MERCENARY then
            merc = 1
        elseif v:GetRole() == ROLE_KILLER then
            kil = 1
        elseif v:GetRole() == ROLE_INNOCENT then
            inno = 1
        end
    end
    if merc == 0 and kil == 0 and inno == 1 then
        return true
    else
        return false
    end
end

net.Receive("rdmtPlayerChoseSk", function()
    local v = net.ReadEntity()
    Randomat:SetRole(v, ROLE_KILLER)
    SendFullStateUpdate()
    v:SetCredits(GetConVar("ttt_kil_credits_starting"):GetInt())
    v:StripWeapon("weapon_zm_improvised")
    v:Give("weapon_kil_knife")
end)

net.Receive("rdmtPlayerChoseSur", function()
    local v = net.ReadEntity()
    Randomat:SetRole(v, ROLE_MERCENARY)
    SendFullStateUpdate()
    v:SetCredits(GetConVar("ttt_mer_credits_starting"):GetInt())
end)

Randomat:register(EVENT)