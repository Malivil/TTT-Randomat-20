local EVENT = {}

CreateConVar("randomat_harpoon_timer", 3, FCVAR_ARCHIVE, "Time between being given harpoons")
CreateConVar("randomat_harpoon_strip", 1, FCVAR_ARCHIVE, "The event strips your other weapons")
CreateConVar("randomat_harpoon_weaponid", "ttt_m9k_harpoon", FCVAR_ARCHIVE, "Id of the weapon given")

EVENT.Title = "Harpooooooooooooooooooooon!!"
EVENT.ExtDescription = "Forces everyone to use harpoons"
EVENT.id = "harpoon"
if GetConVar("randomat_harpoon_strip"):GetBool() then
    EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
end
EVENT.Categories = {"item", "rolechange", "largeimpact"}

local default_weaponids = {"ttt_m9k_harpoon", "weapon_ttt_hwapoon"}
local weaponid = nil

local function PopulateWeaponId()
    if weaponid ~= nil then return end

    local config_weapon = GetConVar("randomat_harpoon_weaponid"):GetString()
    local weapon_options = table.Add({}, default_weaponids)
    -- Insert this ID at the start of the table if it's not already there
    if not table.HasValue(weapon_options, config_weapon) then
        table.insert(weapon_options, 0, config_weapon)
    end

    -- Find the first weapon in the list (which has the config value first) that exists
    for _, v in pairs(weapon_options) do
        if util.WeaponForClass(v) ~= nil then
            weaponid = v
            return
        end
    end
end

function EVENT:HandleRoleWeapons(ply)
    local updated = false
    local changing_teams = Randomat:IsMonsterTeam(ply) or Randomat:IsIndependentTeam(ply)
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and ply:GetRole() ~= ROLE_TRAITOR) or changing_teams then
        Randomat:SetRole(ply, ROLE_TRAITOR)
        updated = true
    elseif Randomat:IsJesterTeam(ply) then
        Randomat:SetRole(ply, ROLE_INNOCENT)
        updated = true
    end

    -- Remove role weapons from anyone on the traitor team now
    if Randomat:IsTraitorTeam(ply) then
        self:StripRoleWeapons(ply)
    end
    return updated, changing_teams
end

function EVENT:Begin()
    PopulateWeaponId()

    local new_traitors = {}
    for _, v in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(v)

        if new_traitor then
            table.insert(new_traitors, v)
        end
    end
    SendFullStateUpdate()

    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    local strip = GetConVar("randomat_harpoon_strip"):GetBool()
    timer.Create("RandomatPoonTimer", GetConVar("randomat_harpoon_timer"):GetInt(), 0, function()
        local updated = false
        for _, ply in ipairs(self:GetAlivePlayers()) do
            if strip then
                for _, wep in ipairs(ply:GetWeapons()) do
                    local weaponclass = WEPS.GetClass(wep)
                    if weaponclass ~= weaponid then
                        ply:StripWeapon(weaponclass)
                    end
                end

                -- Reset FOV to unscope
                ply:SetFOV(0, 0.2)
            end

            if not ply:HasWeapon(weaponid) then
                ply:Give(weaponid)
            end

            -- Workaround the case where people can respawn as Zombies while this is running
            updated = updated or self:HandleRoleWeapons(ply)
        end

        -- If anyone's role changed, send the update
        if updated then
            SendFullStateUpdate()
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not strip then return end
        return IsValid(wep) and WEPS.GetClass(wep) == weaponid
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if not is_item then
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'!\nYour purchase has been refunded.")
            return false
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatPoonTimer")
end

function EVENT:Condition()
    PopulateWeaponId()
    return util.WeaponForClass(weaponid) ~= nil
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer"}) do
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
    for _, v in ipairs({"strip"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    local textboxes = {}
    for _, v in ipairs({"weaponid"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(textboxes, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks, textboxes
end

Randomat:register(EVENT)