local EVENT = {}

CreateConVar("randomat_harpoon_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given harpoons")
CreateConVar("randomat_harpoon_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")
CreateConVar("randomat_harpoon_weaponid", "ttt_m9k_harpoon", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")

EVENT.Title = "Harpooooooooooooooooooooon!!"
EVENT.id = "harpoon"

function EVENT:HandleRoleWeapons(ply)
    local updated = false
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and not ply:GetRole() == ROLE_TRAITOR) or Randomat:IsMonsterTeam(ply) or ply:GetRole() == ROLE_KILLER then
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
    return updated
end

function EVENT:Begin()
    for _, v in pairs(self.GetAlivePlayers()) do
        self:HandleRoleWeapons(v)
    end
    SendFullStateUpdate()

    timer.Create("RandomatPoonTimer", GetConVar("randomat_harpoon_timer"):GetInt(), 0, function()
        local weaponid = GetConVar("randomat_harpoon_weaponid"):GetString()
        local updated = false
        for _, ply in pairs(self:GetAlivePlayers()) do
            if GetConVar("randomat_harpoon_strip"):GetBool() then
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
        if not GetConVar("randomat_harpoon_strip"):GetBool() then return end
        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_harpoon_weaponid"):GetString()
    end)
end

function EVENT:End()
    timer.Remove("RandomatPoonTimer")
end

function EVENT:Condition()
    if Randomat:IsEventActive("slam") or Randomat:IsEventActive("prophunt") or Randomat:IsEventActive("grave") then return false end

    local weaponid = GetConVar("randomat_harpoon_weaponid"):GetString()
    return util.WeaponForClass(weaponid) ~= nil
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