local EVENT = {}

CreateConVar("randomat_slam_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given slams")
CreateConVar("randomat_slam_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")
CreateConVar("randomat_slam_weaponid", "weapon_ttt_slam", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")

EVENT.Title = "Come on and SLAM!"
EVENT.Description = "Gives everyone an M4 SLAM and only allows players to use the M4 SLAM for the duration of the event"
EVENT.id = "slam"

function EVENT:HandleRoleWeapons(ply)
    local updated = false
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and not ply:GetRole() == ROLE_TRAITOR) or Randomat:IsMonsterTeam(ply) or ply:GetRole() == ROLE_KILLER then
        Randomat:SetRole(ply, ROLE_TRAITOR)
        updated = true
    end

    -- Remove role weapons from anyone on the traitor team now
    if Randomat:IsTraitorTeam(ply) then
        self:StripRoleWeapons(ply)
    end
    return updated
end

function EVENT:Begin()
    for _, v in pairs(self.GetAlivePlayers()) do
        self:HandleRoleWeapons(v)
    end
    SendFullStateUpdate()

    timer.Create("RandomatSlamTimer", GetConVar("randomat_slam_timer"):GetInt(), 0, function()
        local weaponid = GetConVar("randomat_slam_weaponid"):GetString()
        local updated = false
        for _, ply in pairs(self:GetAlivePlayers()) do
            if GetConVar("randomat_slam_strip"):GetBool() then
                for _, wep in pairs(ply:GetWeapons()) do
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
        if not GetConVar("randomat_slam_strip"):GetBool() then return end
        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_slam_weaponid"):GetString()
    end)
end

function EVENT:End()
    timer.Remove("RandomatSlamTimer")
end

function EVENT:Condition()
    if Randomat:IsEventActive("prophunt") or Randomat:IsEventActive("harpoon") or Randomat:IsEventActive("grave") then return false end

    local weaponid = GetConVar("randomat_slam_weaponid"):GetString()
    if util.WeaponForClass(weaponid) == nil then return false end

    for _, v in pairs(player.GetAll()) do
        if Randomat:IsJesterTeam(v) and v:Alive() and not v:IsSpec() then
            return false
        end
    end

    return true
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer"}) do
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
    for _, v in pairs({"strip"}) do
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
    for _, v in pairs({"weaponid"}) do
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