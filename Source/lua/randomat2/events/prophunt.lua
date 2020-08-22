local EVENT = {}

CreateConVar("randomat_prophunt_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given prop disguisers")
CreateConVar("randomat_prophunt_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")
CreateConVar("randomat_prophunt_weaponid", "weapon_ttt_prophide", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")


EVENT.Title = "Prop Hunt"
EVENT.id = "prophunt"

function EVENT:Begin()
    for _, v in pairs(self.GetAlivePlayers(true)) do
        -- All bad guys are traitors
        if v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_ZOMBIE or v:GetRole() == ROLE_VAMPIRE or v:GetRole() == ROLE_KILLER then
            Randomat:SetRole(v, ROLE_TRAITOR)
            if v:GetCredits() == 0 then
                v:SetCredits(1)
            end
        -- Everyone else is innocent
        else
            Randomat:SetRole(v, ROLE_INNOCENT)
            v:SetCredits(0)
            v:PrintMessage(HUD_PRINTTALK, "Use the Prop Disguiser to hide from the Traitors!")
        end
    end
    SendFullStateUpdate()

    timer.Create("RandomatPropHuntTimer", GetConVar("randomat_prophunt_timer"):GetInt(), 0, function()
        local weaponid = GetConVar("randomat_prophunt_weaponid"):GetString()
        for _, ply in pairs(self:GetAlivePlayers(true)) do
            if ply:GetRole() == ROLE_INNOCENT then
                if GetConVar("randomat_prophunt_strip"):GetBool() then
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
            end
        end
    end)

    hook.Add("PlayerCanPickupWeapon", "RdmtPropHuntPickupHook", function(ply, wep)
        if not GetConVar("randomat_prophunt_strip"):GetBool() then return true end
        -- Invalid, dead, spectator, and traitor players can pickup whatever they want
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:GetRole() == ROLE_TRAITOR then
            return true
        end
        -- Everyone else can only pick up the assigned weapon
        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_prophunt_weaponid"):GetString()
    end)
end

function EVENT:End()
    timer.Remove("RandomatPropHuntTimer")
    hook.Remove("PlayerCanPickupWeapon", "RdmtPropHuntPickupHook")
end

function EVENT:Condition()
    if Randomat:IsEventActive("slam") or Randomat:IsEventActive("harpoon") then return false end

    local weaponid = GetConVar("randomat_prophunt_weaponid"):GetString()
    if util.WeaponForClass(weaponid) == nil then return false end

    -- Only run if there is at least one innocent or jester/swapper living
    for _, v in pairs(player.GetAll()) do
        if (v:GetRole() == ROLE_SWAPPER or v:GetRole() == ROLE_JESTER or
        v:GetRole() == ROLE_DETECTIVE or v:GetRole() == ROLE_INNOCENT or v:GetRole() == ROLE_PHANTOM or v:GetRole() == ROLE_MERCENARY or v:GetRole() == ROLE_GLITCH) and
        v:Alive() and not v:IsSpec() then
            return true
        end
    end

    return false
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