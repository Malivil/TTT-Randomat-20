local EVENT = {}

util.AddNetworkString("UpgradeEventBegin")
util.AddNetworkString("RdmtCloseUpgradeFrame")
util.AddNetworkString("RdmtPlayerChoseMercenary")
util.AddNetworkString("RdmtPlayerChoseKiller")

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
    local target = nil
    for _, ply in pairs(self:GetAlivePlayers(true)) do
        if ply:GetRole() == ROLE_INNOCENT then
            if choose then
                -- Wait for the notification to go away first
                timer.Create("UpgradeBegin", 5, 1, function()
                    net.Start("UpgradeEventBegin")
                    net.Send(ply)
                end)
            else
                Randomat:SetRole(ply, ROLE_MERCENARY)
                ply:SetCredits(GetConVar("ttt_mer_credits_starting"):GetInt())
                SendFullStateUpdate()
            end
            target = ply
            break
        end
    end

    self:AddHook("PlayerDeath", function(ply)
        if not IsValid(ply) or target ~= ply then return end
        timer.Remove("UpgradeBegin")
        net.Start("RdmtCloseUpgradeFrame")
        net.Send(ply)
    end)
end

function EVENT:End()
    timer.Remove("UpgradeBegin")
    net.Start("RdmtCloseUpgradeFrame")
    net.Broadcast()
end

function EVENT:Condition()
    -- Don't allow this if Mercenary is disabled
    if ConVarExists("ttt_mercenary_enabled") and not GetConVar("ttt_mercenary_enabled"):GetBool() then
        return false
    end

    local choose = GetConVar("randomat_upgrade_chooserole"):GetBool()
    local has_merc = false
    local has_inno = false
    local has_kil = false
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_MERCENARY then
            has_merc = true
        elseif v:GetRole() == ROLE_KILLER then
            has_kil = true
        elseif v:GetRole() == ROLE_INNOCENT then
            has_inno = true
        end
    end

    -- Only run this event if we have Innocents, don't have a Mercenary, and either aren't letting the target choose or don't have a Killer
    return has_inno and not has_merc and (not choose or not has_kil)
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in pairs({"chooserole"}) do
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

net.Receive("RdmtPlayerChoseKiller", function()
    local v = net.ReadEntity()
    Randomat:SetRole(v, ROLE_KILLER)
    SendFullStateUpdate()
    v:SetCredits(GetConVar("ttt_kil_credits_starting"):GetInt())
    v:StripWeapon("weapon_zm_improvised")
    v:Give("weapon_kil_knife")
end)

net.Receive("RdmtPlayerChoseMercenary", function()
    local v = net.ReadEntity()
    Randomat:SetRole(v, ROLE_MERCENARY)
    SendFullStateUpdate()
    v:SetCredits(GetConVar("ttt_mer_credits_starting"):GetInt())
end)

Randomat:register(EVENT)