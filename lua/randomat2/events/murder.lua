local EVENT = {}

EVENT.Title = "What gamemode is this again?"
EVENT.AltTitle = "Murder"
EVENT.Description = "Innocents gather pieces to get a revolver while traitors try to murder the innocents like the popular gamemodes Murder and Homicide"
EVENT.id = "murder"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"gamemode", "biased_traitor", "biased", "item", "rolechange", "largeimpact"}

CreateConVar("randomat_murder_pickups_ratio", 0.75, FCVAR_ARCHIVE, "Ratio of weapons required to get a revolver.", 1, 5)
CreateConVar("randomat_murder_highlight_gun", 1, FCVAR_ARCHIVE, "Whether to highlight dropped revolvers.")
CreateConVar("randomat_murder_knifespeed", 1.2, FCVAR_ARCHIVE, "Player move speed multiplier whilst knife is held.", 1, 2)
CreateConVar("randomat_murder_allow_shop", 0, FCVAR_ARCHIVE, "Whether to allow the shop to be used.")

util.AddNetworkString("MurderEventActive")

local function IsEvil(ply)
    return Randomat:IsTraitorTeam(ply) or Randomat:IsIndependentTeam(ply)
end

function EVENT:StripBannedWeapons(ply)
    -- Let the killer keep their knife since their role does not change
    if ply:GetRole() ~= ROLE_KILLER then
        self:StripRoleWeapons(ply, true)
    end
    for _, wep in ipairs(ply:GetWeapons()) do
        local class_name = WEPS.GetClass(wep)
        if (not WEAPON_CATEGORY_ROLE or wep.Category ~= WEAPON_CATEGORY_ROLE) and (wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL or wep.Kind == WEAPON_NADE or wep.Kind == WEAPON_NONE or class_name == "weapon_zm_improvised" or class_name == "weapon_ttt_crowbar_fast" or class_name == "weapon_ttt_innocent_knife" or class_name == "weapon_ttt_wrench")
             then
            ply:StripWeapon(class_name)
            -- Reset FOV to unscope
            ply:SetFOV(0, 0.2)
        end
    end
end

function EVENT:Begin()
    local speed_factor = GetConVar("randomat_murder_knifespeed"):GetFloat()
    local allow_shop = GetConVar("randomat_murder_allow_shop"):GetBool()
    local players = #self:GetAlivePlayers()
    local wepspawns = 0

    for _, v in ents.Iterator() do
        if v.Base == "weapon_tttbase" and v.AutoSpawnable then
            wepspawns = wepspawns+1
        end
    end

    local ratio = GetConVar("randomat_murder_pickups_ratio"):GetFloat()
    local pck = math.ceil((wepspawns * ratio)/players)
    net.Start("MurderEventActive")
    net.WriteBool(allow_shop)
    net.WriteInt(pck, 32)
    net.WriteBool(GetConVar("randomat_murder_highlight_gun"):GetBool())
    net.Broadcast()

    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(v) then
            timer.Create("RandomatRevolverTimer", 0.15, 1, function()
                self:StripBannedWeapons(v)
                v:Give("weapon_ttt_randomatrevolver")
                v:SetNWBool("RdmMurderRevolver", true)
            end)
        elseif Randomat:IsTraitorTeam(v) then
            Randomat:SetRole(v, ROLE_TRAITOR)
            timer.Create("RandomatKnifeTimer" .. v:Nick(), 0.15, 1, function()
                self:StripBannedWeapons(v)
                v:Give("weapon_ttt_randomatknife")

                -- Increase the player speed on the client
                net.Start("RdmtSetSpeedMultiplier_WithWeapon")
                net.WriteFloat(speed_factor)
                net.WriteString("RdmtMurderSpeed")
                net.WriteString("weapon_ttt_randomatknife")
                net.Send(v)
            end)
        -- Anyone else except Killers become Innocent
        elseif v:GetRole() ~= ROLE_KILLER then
            Randomat:SetRole(v, ROLE_INNOCENT)
        end
        if v:GetRole() == ROLE_INNOCENT then
            v:PrintMessage(HUD_PRINTTALK, "Stay alive and gather weapons! Gathering " .. pck .. " weapons will give you a revolver!")
        end
    end
    SendFullStateUpdate()

    timer.Create("RandomatMurderTimer", 0.1, 0, function()
        for _, v in ipairs(self:GetAlivePlayers()) do
            self:StripBannedWeapons(v)

            if v:GetRole() ~= ROLE_TRAITOR and v:GetNWInt("MurderWeaponsEquipped") >= pck then
                v:SetNWInt("MurderWeaponsEquipped", 0)
                v:Give("weapon_ttt_randomatrevolver")
                v:SetNWBool("RdmMurderRevolver", true)
            end
        end
    end)

    self:AddHook("EntityTakeDamage", function(tgt, dmg)
        if IsPlayer(tgt) and tgt:GetRole() ~= ROLE_TRAITOR and dmg:IsBulletDamage() then
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
        -- Don't let the player pick up more weapons if they already have the revolver
        -- Also don't let bad players pick up weapon pieces but do let them pick up the knife
        if ply:HasWeapon("weapon_ttt_randomatrevolver") or (IsEvil(ply) and WEPS.GetClass(wep) == "weapon_ttt_randomatrevolver") then return false end
    end)

    self:AddHook("PlayerDeath", function(tgt, infl, ply)
        if not IsPlayer(ply) then return end
        if not ply:Alive() or ply:IsSpec() then return end
        if IsEvil(tgt) or IsEvil(ply) then return end

        local wep = ply.GetActiveWeapon and ply:GetActiveWeapon() or nil
        if IsValid(wep) and WEPS.GetClass(wep) == "weapon_ttt_randomatrevolver" then
            Randomat:SendChatToAll(ply:Nick() .. " killed an innocent bystander")
            ply:DropWeapon(wep)
            ply:SetNWBool("RdmtShouldBlind", true)
            timer.Create("RdmtBlindEndDelay_" .. ply:Nick(), 5, 1, function()
                ply:SetNWBool("RdmtShouldBlind", false)
            end)
        end
    end)

    -- Increase the player speed on the server
    self:AddHook("TTTSpeedMultiplier", function(ply, mults)
        if not IsPlayer(ply) then return end
        if not ply:Alive() or ply:IsSpec() then return end
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and WEPS.GetClass(wep) == "weapon_ttt_randomatknife" then
            table.insert(mults, speed_factor)
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatMurderTimer")
    for _, v in player.Iterator() do
        v:SetNWInt("MurderWeaponsEquipped", 0)
        v:SetNWBool("RdmMurderRevolver", false)
        timer.Remove("RdmtBlindEndDelay_" .. v:Nick())
    end
end

function EVENT:Condition()
    local has_detective = false
    local t = 0
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(v) then
            has_detective = true
        elseif Randomat:IsTraitorTeam(v) then
            t = t+1
        end
    end

    return has_detective and t > 1
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"pickups_ratio", "knifespeed", "knifedmg"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            local decimal = 0
            if v == "knifespeed" then
                decimal = 1
            elseif v == "pickups_ratio" then
                decimal = 2
            end
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = decimal
            })
        end
    end

    local checks = {}
    for _, v in ipairs({"highlight_gun", "allow_shop"}) do
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