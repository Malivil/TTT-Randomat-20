local EVENT = {}

CreateConVar("randomat_prophunt_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given prop disguisers")
CreateConVar("randomat_prophunt_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")
CreateConVar("randomat_prophunt_weaponid", "weapon_ttt_prophide", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")

EVENT.Title = "Prop Hunt"
EVENT.Description = "Forces Innocents to use a Prop Disguiser, changing this to play like the popular gamemode Prop Hunt"
EVENT.id = "prophunt"

local cvar_state
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
    -- Disable prop possession
    cvar_state = GetConVar("ttt_spec_prop_control"):GetString()
    RunConsoleCommand("ttt_spec_prop_control", "0")

    for _, v in pairs(self.GetAlivePlayers()) do
        local had_armor = false
        local had_disguise = false
        -- All bad guys are traitors
        if v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_ZOMBIE or v:GetRole() == ROLE_VAMPIRE or v:GetRole() == ROLE_KILLER or v:GetRole() == ROLE_DETRAITOR then
            Randomat:SetRole(v, ROLE_TRAITOR)

            -- Give the player enough credits to compensate for the equipment they can no longer use
            local credits = v:GetCredits()
            if credits == 0 then
                credits = 1
            end
            if v:HasEquipmentItem(EQUIP_RADAR) then
                credits = credits + 1
            end

            had_armor = v:HasEquipmentItem(EQUIP_ARMOR)
            had_disguise = v:HasEquipmentItem(EQUIP_DISGUISE)
            v:SetCredits(credits)
        -- Everyone else is innocent
        else
            Randomat:SetRole(v, ROLE_INNOCENT)
            v:SetCredits(0)
            v:PrintMessage(HUD_PRINTTALK, "Use the Prop Disguiser to hide from the Traitors!")
        end

        self:StripRoleWeapons(v)
        -- Remove all their equipment
        v:ResetEquipment()
        -- Add back the other two (since we only want to remove radar)
        if had_armor then
            v:GiveEquipmentItem(EQUIP_ARMOR)
        end
        if had_disguise then
            v:GiveEquipmentItem(EQUIP_DISGUISE)
        end
    end
    SendFullStateUpdate()

    timer.Create("RandomatPropHuntTimer", GetConVar("randomat_prophunt_timer"):GetInt(), 0, function()
        local weaponid = GetConVar("randomat_prophunt_weaponid"):GetString()
        local updated = false
        for _, ply in pairs(self:GetAlivePlayers()) do
            if ply:GetRole() == ROLE_INNOCENT then
                if GetConVar("randomat_prophunt_strip"):GetBool() then
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
        if not GetConVar("randomat_prophunt_strip"):GetBool() then return end
        -- Invalid, dead, spectator, and traitor players can pickup whatever they want
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:GetRole() == ROLE_TRAITOR then
            return
        end
        -- Everyone else can only pick up the assigned weapon
        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_prophunt_weaponid"):GetString()
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if is_item == EQUIP_RADAR then return false end
    end)
end

function EVENT:End()
    -- Change the prop possession setting back to normal
    RunConsoleCommand("ttt_spec_prop_control", cvar_state)
    timer.Remove("RandomatPropHuntTimer")
end

function EVENT:Condition()
    if Randomat:IsEventActive("slam") or Randomat:IsEventActive("harpoon") or Randomat:IsEventActive("ragdoll") or Randomat:IsEventActive("grave") then return false end

    local weaponid = GetConVar("randomat_prophunt_weaponid"):GetString()
    if util.WeaponForClass(weaponid) == nil then return false end

    -- Only run if there is at least one innocent or jester/swapper living
    for _, v in pairs(player.GetAll()) do
        if (v:GetRole() == ROLE_SWAPPER or v:GetRole() == ROLE_JESTER or
            v:GetRole() == ROLE_DETECTIVE or v:GetRole() == ROLE_INNOCENT or
            v:GetRole() == ROLE_PHANTOM or v:GetRole() == ROLE_MERCENARY or
            v:GetRole() == ROLE_GLITCH) and v:Alive() and not v:IsSpec() then
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