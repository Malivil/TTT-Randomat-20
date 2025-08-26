local EVENT = {}

CreateConVar("randomat_slam_timer", 3, FCVAR_NONE, "Time between being given slams")
CreateConVar("randomat_slam_strip", 1, FCVAR_NONE, "The event strips your other weapons")
CreateConVar("randomat_slam_weaponid", "weapon_ttt_slam", FCVAR_NONE, "Id of the weapon given")

EVENT.Title = "Come on and SLAM!"
EVENT.Description = "Gives everyone an M4 SLAM and only allows players to use the M4 SLAM for the duration of the event"
EVENT.id = "slam"
if GetConVar("randomat_slam_strip"):GetBool() then
    EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
end
EVENT.Categories = {"item", "rolechange", "largeimpact"}

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

    -- Remove role weapons from anyone whose role was changed
    if updated then
        self:StripRoleWeapons(ply)
    end
    return updated, changing_teams
end

function EVENT:Begin()
    local new_traitors = {}
    for _, v in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(v)
        Randomat:RemovePhdFlopper(v)

        if new_traitor then
            table.insert(new_traitors, v)
        end
    end
    SendFullStateUpdate()

    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    local strip = GetConVar("randomat_slam_strip"):GetBool()
    timer.Create("RandomatSlamTimer", GetConVar("randomat_slam_timer"):GetInt(), 0, function()
        local weaponid = GetConVar("randomat_slam_weaponid"):GetString()
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
        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_slam_weaponid"):GetString()
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if id == "hoff_perk_phd" or (is_item and is_item == EQUIP_PHD) then
            ply:ChatPrint("PHD Floppers are disabled while '" .. Randomat:GetEventTitle(EVENT) .. "' is active!\nYour purchase has been refunded.")
            return false
        elseif not is_item then
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'!\nYour purchase has been refunded.")
            return false
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatSlamTimer")
end

function EVENT:Condition()
    -- Don't run this when there is a sapper
    if ROLE_SAPPER and ROLE_SAPPER ~= -1 then
        for _, p in ipairs(self:GetAlivePlayers()) do
            if p:IsSapper() then
                return false
            end
        end
    end

    -- Or an enhanced paladin with explosion immunity
    if cvars.Bool("ttt_paladin_explosion_immune", false) then
        for _, p in ipairs(self:GetAlivePlayers()) do
            if p:IsPaladin() then
                return false
            end
        end
    end

    local weaponid = GetConVar("randomat_slam_weaponid"):GetString()
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