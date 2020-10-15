local EVENT = {}

CreateConVar("randomat_slam_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given slams")
CreateConVar("randomat_slam_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")
CreateConVar("randomat_slam_weaponid", "weapon_ttt_slam", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")


EVENT.Title = "Come on and SLAM!"
EVENT.id = "slam"

function EVENT:HandleRoleWeapons(ply)
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if ply:GetRole() == ROLE_ASSASSIN or ply:GetRole() == ROLE_HYPNOTIST or ply:GetRole() == ROLE_ZOMBIE or ply:GetRole() == ROLE_VAMPIRE or ply:GetRole() == ROLE_KILLER or ply:GetRole() == ROLE_DETRAITOR then
        Randomat:SetRole(ply, ROLE_TRAITOR)
        self:StripRoleWeapons(ply)
        return true
    end
    return false
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

    hook.Add("PlayerCanPickupWeapon", "RdmtSlamPickupHook", function(ply, wep)
        if not GetConVar("randomat_slam_strip"):GetBool() then return end
        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_slam_weaponid"):GetString()
    end)
end

function EVENT:End()
    timer.Remove("RandomatSlamTimer")
    hook.Remove("PlayerCanPickupWeapon", "RdmtSlamPickupHook")
end

function EVENT:Condition()
    if Randomat:IsEventActive("prophunt") or Randomat:IsEventActive("harpoon") then return false end

    local weaponid = GetConVar("randomat_slam_weaponid"):GetString()
    if util.WeaponForClass(weaponid) == nil then return false end

    for _, v in pairs(player.GetAll()) do
        if (v:GetRole() == ROLE_SWAPPER or v:GetRole() == ROLE_JESTER) and v:Alive() and not v:IsSpec() then
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