local EVENT = {}

EVENT.Title = "What gamemode is this again?"
EVENT.AltTitle = "Murder"
EVENT.Description = "Innocents gather pieces to get a revolver while traitors try to murder the innocents like the popular gamemodes Murder and Homicide"
EVENT.id = "murder"

CreateConVar("randomat_murder_pickups_pct", 1.5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Ratio of weapons required to get a revolver.", 1, 5)
CreateConVar("randomat_murder_highlight_gun", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to highlight dropped revolvers.")
CreateConVar("randomat_murder_knifespeed", 1.2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Player move speed multiplier whilst knife is held.", 1, 2)

util.AddNetworkString("RandomatRevolverHalo")
util.AddNetworkString("MurderEventActive")

function EVENT:StripBannedWeapons(ply)
    self:StripRoleWeapons(ply)
    for _, wep in pairs(ply:GetWeapons()) do
        local class_name = WEPS.GetClass(wep)
        if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL or wep.Kind == WEAPON_NADE or wep.Kind == WEAPON_NONE or class_name == "weapon_zm_improvised" or class_name == "weapon_ttt_crowbar_fast" or class_name == "weapon_ttt_innocent_knife" or class_name == "weapon_ttt_wrench"
             then
            ply:StripWeapon(class_name)
            -- Reset FOV to unscope
            ply:SetFOV(0, 0.2)
        end
    end
end

function EVENT:Begin()
    -- Sync the convar for gun highlighting
    SetGlobalBool("randomat_murder_highlight_gun", GetConVar("randomat_murder_highlight_gun"):GetBool())

    local players = #self:GetAlivePlayers()
    local wepspawns = 0

    for _, v in pairs(ents.GetAll()) do
        if v.Base == "weapon_tttbase" and v.AutoSpawnable then
            wepspawns = wepspawns+1
        end
    end

    local pck = math.ceil(wepspawns/players)
    net.Start("MurderEventActive")
    net.WriteBool(true)
    net.WriteInt(pck, 32)
    net.Broadcast()

    for _, v in pairs(self.GetAlivePlayers()) do
        if v:GetRole() == ROLE_DETECTIVE then
            timer.Create("RandomatRevolverTimer", 0.15, 1, function()
                self:StripBannedWeapons(v)
                v:Give("weapon_ttt_randomatrevolver")
                v:SetNWBool("RdmMurderRevolver", true)
            end)
        elseif v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_ZOMBIE or v:GetRole() == ROLE_VAMPIRE or v:GetRole() == ROLE_DETRAITOR then
            Randomat:SetRole(v, ROLE_TRAITOR)
            timer.Create("RandomatKnifeTimer"..v:Nick(), 0.15, 1, function()
                self:StripBannedWeapons(v)
                v:Give("weapon_ttt_randomatknife")
            end)
        -- Anyone else except Killers become Innocent
        elseif v:GetRole() ~= ROLE_KILLER then
            Randomat:SetRole(v, ROLE_INNOCENT)
        end
        if v:GetRole() == ROLE_INNOCENT then
            v:PrintMessage(HUD_PRINTTALK, "Stay alive and gather weapons! Gathering "..pck.." weapons will give you a revolver!")
        end
    end
    SendFullStateUpdate()

    timer.Create("RandomatMurderTimer", 0.1, 0, function()
        for _, v in pairs(self.GetAlivePlayers()) do
            self:StripBannedWeapons(v)

            if v:GetRole() ~= ROLE_TRAITOR and v:GetNWInt("MurderWeaponsEquipped") >= pck then
                v:SetNWInt("MurderWeaponsEquipped", 0)
                v:Give("weapon_ttt_randomatrevolver")
                v:SetNWBool("RdmMurderRevolver", true)
            end
        end
    end)

    self:AddHook("EntityTakeDamage", function(tgt, dmg)
        if tgt:IsPlayer() and tgt:GetRole() ~= ROLE_TRAITOR and dmg:IsBulletDamage() then
            dmg:ScaleDamage(0.25)
        end
    end)

    self:AddHook("WeaponEquip", function(wep, ply)
        -- Let the player pick up weapons and nades and count them toward the pieces found
        if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL or wep.Kind == WEAPON_NADE or wep.Kind == WEAPON_NONE then
            ply:SetNWInt("MurderWeaponsEquipped", ply:GetNWInt("MurderWeaponsEquipped") +1)
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        print(ply:Nick() .. " " .. WEPS.GetClass(wep) .. " " .. wep.Kind)
        -- Don't let the player pick up more weapons if they already have the revolver
        if ply:HasWeapon("weapon_ttt_randomatrevolver") then return false end
    end)

    self:AddHook("PlayerDeath", function(tgt, wep, ply)
        if table.HasValue(player.GetAll(), ply) then
            if IsValid(ply) and ply:Alive() and not ply:IsSpec() then
              if WEPS.GetClass(ply:GetActiveWeapon()) == "weapon_ttt_randomatrevolver" and not IsEvil(tgt) and not IsEvil(ply) then
                 ply:DropWeapon(ply:GetActiveWeapon())
                 ply:SetNWBool("RdmtShouldBlind", true)
                 timer.Create("RdmtBlindEndDelay"..ply:Nick(), 5, 1, function()
                    ply:SetNWBool("RdmtShouldBlind", false)
                 end)
              end
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatMurderTimer")
    -- Added by the revolver weapon
    hook.Remove("DrawOverlay", "RdmtMurderBlind")
    for _, v in pairs(player.GetAll()) do
        v:SetNWInt("MurderWeaponsEquipped", 0)
        v:SetNWBool("RdmMurderRevolver", false)
    end
    net.Start("MurderEventActive")
    net.WriteBool(false)
    net.Broadcast()
end

function EVENT:Condition()
    local d = 0
    local t = 0
    for _, v in pairs(player.GetAll()) do
        if v:Alive() and not v:IsSpec() then
            if v:GetRole() == ROLE_DETECTIVE then
                d = d+1
            elseif v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_ZOMBIE or v:GetRole() == ROLE_VAMPIRE or v:GetRole() == ROLE_DETRAITOR then
                t = t+1
            end
        end
    end
    if d > 0 and t > 1 then
        return true
    else
        return false
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"pickups_pct", "knifespeed", "knifedmg"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "knifedmg" and 0 or 1
            })
        end
    end

    local checks = {}
    for _, v in pairs({"highlight_gun"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks
end

Randomat:register(EVENT)