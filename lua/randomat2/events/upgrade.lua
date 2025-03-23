local EVENT = {}

util.AddNetworkString("RdmtUpgradeBegin")
util.AddNetworkString("RdmtCloseUpgradeFrame")
util.AddNetworkString("RdmtPlayerChoseMercenary")
util.AddNetworkString("RdmtPlayerChoseKiller")

CreateConVar("randomat_upgrade_chooserole", 1, FCVAR_NONE, "Whether the innocent should choose their new role.")

EVENT.Title = "An innocent has been upgraded!"
EVENT.Description = "A random vanilla innocent is upgraded to a mercenary"
EVENT.id = "upgrade"
EVENT.Categories = {"rolechange", "biased_innocent", "biased", "moderateimpact"}

local function CanChooseRole()
    return Randomat:CanRoleSpawn(ROLE_KILLER) and GetConVar("randomat_upgrade_chooserole"):GetBool()
end

local function GetEventDescription()
    local choose = CanChooseRole()
    local action
    if choose then
        action = "given the choice of becoming " .. Randomat:GetRoleExtendedString(ROLE_MERCENARY):lower() .. " or " .. Randomat:GetRoleExtendedString(ROLE_KILLER):lower()
    else
        action = "upgraded to " .. Randomat:GetRoleExtendedString(ROLE_MERCENARY):lower()
    end
    return "A random vanilla " .. Randomat:GetRoleString(ROLE_INNOCENT):lower() .. " is " .. action
end

local function UpdateToMerc(ply)
    Randomat:SetRole(ply, ROLE_MERCENARY)
    if ply.SetDefaultCredits then
        ply:SetDefaultCredits()
    else
        ply:SetCredits(GetConVar("ttt_mer_credits_starting"):GetInt())
    end
    SendFullStateUpdate()
end

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update these in case the CVar or role names have been changed
    self.Title = Randomat:GetRoleExtendedString(ROLE_INNOCENT) .. " has been upgraded!"
    self.Description = GetEventDescription()
end

function EVENT:Begin()
    local choose = CanChooseRole()
    local target = nil
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        if ply:GetRole() == ROLE_INNOCENT then
            if choose then
                -- Wait for the notification to go away first
                timer.Create("RdmtUpgradeBegin", 5, 1, function()
                    net.Start("RdmtUpgradeBegin")
                    net.Send(ply)
                end)
            else
                UpdateToMerc(ply)
            end
            target = ply
            break
        end
    end

    self:AddHook("PlayerDeath", function(ply)
        if not IsValid(ply) or target ~= ply then return end
        timer.Remove("RdmtUpgradeBegin")
        net.Start("RdmtCloseUpgradeFrame")
        net.Send(ply)
    end)
end

function EVENT:End()
    timer.Remove("RdmtUpgradeBegin")
end

function EVENT:Condition()
    -- Don't allow this if Mercenary is disabled
    if Randomat:CanRoleSpawn(ROLE_MERCENARY) then
        return false
    end

    local choose = CanChooseRole()
    local has_merc = false
    local has_inno = false
    local has_kil = false
    for _, v in ipairs(self:GetAlivePlayers()) do
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
    for _, v in ipairs({"chooserole"}) do
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

net.Receive("RdmtPlayerChoseKiller", function(len, ply)
    Randomat:SetRole(ply, ROLE_KILLER, false)
    SendFullStateUpdate()

    if ply.SetDefaultCredits then
        ply:SetDefaultCredits()
    else
        ply:SetCredits(GetConVar("ttt_kil_credits_starting"):GetInt())
    end

    -- Only run this if the version of Custom Roles with a knife exists and it is enabled
    if ConVarExists("ttt_killer_knife_enabled") and GetConVar("ttt_killer_knife_enabled"):GetBool() then
        -- The newest version of CR doesn't replace the crowbar with the knife
        if not CR_VERSION then
            ply:StripWeapon("weapon_zm_improvised")
        end
        ply:Give("weapon_kil_knife")
    end

    -- In the newest version of CR the killer can get a throwable crowbar as a replacement for the normal one
    if CR_VERSION and ConVarExists("ttt_killer_crowbar_enabled") and GetConVar("ttt_killer_crowbar_enabled"):GetBool() then
        ply:StripWeapon("weapon_zm_improvised")
        ply:Give("weapon_kil_crowbar")
    end

    -- If the killer's max health can be changed and it's different than what they have now, update it
    -- Also heal the player the difference in health
    if ConVarExists("ttt_killer_max_health") then
        local max = GetConVar("ttt_killer_max_health"):GetInt()
        local current_max = ply:GetMaxHealth()
        if max ~= current_max then
            local hp = ply:Health()
            local new_hp = math.min(max, hp + (max - current_max))
            ply:SetMaxHealth(max)
            ply:SetHealth(new_hp)
        end
    end

    -- Make sure they get their loadout weapons
    hook.Call("PlayerLoadout", GAMEMODE, ply)
end)

net.Receive("RdmtPlayerChoseMercenary", function(len, ply)
    UpdateToMerc(ply)
end)

Randomat:register(EVENT)