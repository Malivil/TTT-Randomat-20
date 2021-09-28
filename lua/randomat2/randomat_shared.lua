-- Event Types
EVENT_TYPE_DEFAULT = 0
EVENT_TYPE_WEAPON_OVERRIDE = 1
EVENT_TYPE_VOTING = 2
EVENT_TYPE_SMOKING = 3
EVENT_TYPE_SPECTATOR_UI = 4

-- String Functions
function Randomat:Capitalize(msg)
    return msg:sub(1, 1):upper() .. msg:sub(2):lower()
end

-- Team Functions
function Randomat:IsInnocentTeam(ply, skip_detective)
    -- Handle this early because IsInnocentTeam doesn't
    if skip_detective and Randomat:IsGoodDetectiveLike(ply) then
        return false
    end
    if ply.IsInnocentTeam then return ply:IsInnocentTeam() end
    local role = ply:GetRole()
    return role == ROLE_DETECTIVE or role == ROLE_INNOCENT or role == ROLE_MERCENARY or role == ROLE_PHANTOM or role == ROLE_GLITCH
end

function Randomat:IsTraitorTeam(ply, skip_evil_detective)
    -- Handle this early because IsTraitorTeam doesn't
    if skip_evil_detective and Randomat:IsEvilDetectiveLike(ply) then
        return false
    end
    if player.IsTraitorTeam then return player.IsTraitorTeam(ply) end
    if ply.IsTraitorTeam then return ply:IsTraitorTeam() end
    local role = ply:GetRole()
    return role == ROLE_TRAITOR or role == ROLE_HYPNOTIST or role == ROLE_ASSASSIN or role == ROLE_DETRAITOR
end

function Randomat:IsMonsterTeam(ply)
    if ply.IsMonsterTeam then return ply:IsMonsterTeam() end
    local role = ply:GetRole()
    return role == ROLE_ZOMBIE or role == ROLE_VAMPIRE
end

function Randomat:IsJesterTeam(ply)
    if ply.IsJesterTeam then return ply:IsJesterTeam() end
    local role = ply:GetRole()
    return role == ROLE_JESTER or role == ROLE_SWAPPER
end

function Randomat:IsIndependentTeam(ply)
    if ply.IsIndependentTeam then return ply:IsIndependentTeam() end
    local role = ply:GetRole()
    return role == ROLE_KILLER
end

-- Role Functions
function Randomat:IsDetectiveLike(ply)
    if ply.IsDetectiveLike then return ply:IsDetectiveLike() end
    local role = ply:GetRole()
    return role == ROLE_DETECTIVE or role == ROLE_DETRAITOR
end

function Randomat:IsGoodDetectiveLike(ply)
    local role = ply:GetRole()
    return role == ROLE_DETECTIVE or (Randomat:IsDetectiveLike(ply) and Randomat:IsInnocentTeam(ply))
end

function Randomat:IsEvilDetectiveLike(ply)
    local role = ply:GetRole()
    return role == ROLE_DETRAITOR or (Randomat:IsDetectiveLike(ply) and Randomat:IsTraitorTeam(ply))
end

function Randomat:GetRoleColor(role)
    local color = nil
    if type(ROLE_COLORS) == "table" then
        color = ROLE_COLORS[role]
    end
    -- Don't return the table directly because if the table exists but is missing a role we need to handle that
    if color then return color end

    -- Only the roles in the original Custom Roles need to be defined here because the updated version and my version both have ROLE_COLORS defined
    local role_colors = {
        [ROLE_INNOCENT] = Color(55, 170, 50, 255),
        [ROLE_TRAITOR] = Color(180, 50, 40, 255),
        [ROLE_DETECTIVE] = Color(50, 60, 180, 255),
        [ROLE_MERCENARY] = Color(245, 200, 0, 255),
        [ROLE_JESTER] = Color(180, 23, 253, 255),
        [ROLE_PHANTOM] = Color(82, 226, 255, 255),
        [ROLE_HYPNOTIST] = Color(255, 80, 235, 255),
        [ROLE_GLITCH] = Color(245, 106, 0, 255),
        [ROLE_ZOMBIE] = Color(69, 97, 0, 255),
        [ROLE_VAMPIRE] = Color(45, 45, 45, 255),
        [ROLE_SWAPPER] = Color(111, 0, 255, 255),
        [ROLE_ASSASSIN] = Color(112, 50, 0, 255),
        [ROLE_KILLER] = Color(50, 0, 70, 255)
    }
    return role_colors[role]
end

function Randomat:GetRoleExtendedString(role, hide_secret_roles)
    -- Hide detraitors and impersonators so they don't get outed
    if hide_secret_roles then
        if role == ROLE_DETRAITOR then
            role = ROLE_DETECTIVE
        elseif role == ROLE_IMPERSONATOR then
            role = ROLE_DEPUTY
        end
    end

    -- Use the role strings if they exist
    local role_string = ROLE_STRINGS_EXT and ROLE_STRINGS_EXT[role] or nil
    if role_string then
        return Randomat:Capitalize(role_string)
    end

    -- Otherwise fall back to the defaults
    if role == ROLE_TRAITOR then
        return "A traitor"
    elseif role == ROLE_HYPNOTIST then
        return "A hypnotist"
    elseif role == ROLE_ASSASSIN then
        return "An assassin"
    elseif role == ROLE_DETECTIVE then
        return "A detective"
    elseif role == ROLE_MERCENARY then
        return "A mercenary"
    elseif role == ROLE_ZOMBIE then
        return "A zombie"
    elseif role == ROLE_VAMPIRE then
        return "A vampire"
    elseif role == ROLE_KILLER then
        return "A killer"
    elseif role == ROLE_INNOCENT then
        return "An innocent"
    elseif role == ROLE_GLITCH then
        return "A glitch"
    elseif role == ROLE_PHANTOM then
        return "A phantom"
    end
    return "Someone"
end

function Randomat:GetRoleString(role)
    -- Use the role strings if they exist
    if ROLE_STRINGS and ROLE_STRINGS[role] or nil then
        return ROLE_STRINGS[role]
    end

    -- Otherwise fall back to the defaults
    if role == ROLE_TRAITOR then
        return "Traitor"
    elseif role == ROLE_HYPNOTIST then
        return "Hypnotist"
    elseif role == ROLE_ASSASSIN then
        return "Assassin"
    elseif role == ROLE_DETECTIVE then
        return "Detective"
    elseif role == ROLE_MERCENARY then
        return "Mercenary"
    elseif role == ROLE_ZOMBIE then
        return "Zombie"
    elseif role == ROLE_VAMPIRE then
        return "Vampire"
    elseif role == ROLE_KILLER then
        return "Killer"
    elseif role == ROLE_INNOCENT then
        return "Innocent"
    elseif role == ROLE_GLITCH then
        return "Glitch"
    elseif role == ROLE_PHANTOM then
        return "Phantom"
    end
    return "Someone"
end

function Randomat:GetRolePluralString(role)
    -- Use the role strings if they exist
    if ROLE_STRINGS_PLURAL and ROLE_STRINGS_PLURAL[role] or nil then
        return ROLE_STRINGS_PLURAL[role]
    end

    -- Otherwise fall back to the defaults
    if role == ROLE_TRAITOR then
        return "Traitors"
    elseif role == ROLE_HYPNOTIST then
        return "Hypnotists"
    elseif role == ROLE_ASSASSIN then
        return "Assassins"
    elseif role == ROLE_DETECTIVE then
        return "Detectives"
    elseif role == ROLE_MERCENARY then
        return "Mercenaries"
    elseif role == ROLE_ZOMBIE then
        return "Zombies"
    elseif role == ROLE_VAMPIRE then
        return "Vampires"
    elseif role == ROLE_KILLER then
        return "Killers"
    elseif role == ROLE_INNOCENT then
        return "Innocents"
    elseif role == ROLE_GLITCH then
        return "Glitches"
    elseif role == ROLE_PHANTOM then
        return "Phantoms"
    elseif role == ROLE_DETRAITOR then
        return "Detraitors"
    end
    return "Players"
end

function Randomat:GetValidRoles(roles, check)
    local valid_roles = {}
    for _, r in ipairs(roles) do
        if r ~= -1 and (not check or check(r)) then
            table.insert(valid_roles, r)
        end
    end
    return valid_roles
end

function Randomat:GetShopRoles()
    -- Get the default list of roles
    local initial_roles = {ROLE_TRAITOR,ROLE_ASSASSIN,ROLE_HYPNOTIST,ROLE_DETECTIVE,ROLE_MERCENARY,ROLE_JESTER,ROLE_SWAPPER}
    if type(SHOP_ROLES) == "table" then
        if type(SHOP_ROLES[1]) == "boolean" then
            initial_roles = table.GetKeys(SHOP_ROLES)
        else
            initial_roles = SHOP_ROLES
        end
    end

    return Randomat:GetValidRoles(initial_roles, WEPS.DoesRoleHaveWeapon)
end

function Randomat:CanUseShop(ply)
    if ply.CanUseShop then return ply:CanUseShop() end
    if player.HasBuyMenu then return player.HasBuyMenu(ply) end
    -- Otherwise just assume any roel in the list of shop roles can use the shop
    local shop_roles = Randomat:GetShopRoles()
    return shop_roles[ply:GetRole()] or false
end

function Randomat:IsZombifying(ply)
    return ply:GetNWBool("IsZombifying", false) or ply:GetPData("IsZombifying", 0) == 1
end

-- Weapon Sound Functions
function Randomat:RestoreWeaponSound(wep)
    if not IsValid(wep) or not wep.Primary then return end
    if wep.Primary.OriginalSound then
        wep.Primary.Sound = wep.Primary.OriginalSound
        wep.Primary.OriginalSound = nil
    end
end

function Randomat:OverrideWeaponSound(wep, chosen_sound)
    if not IsValid(wep) or not wep.Primary then return end
    if wep.Primary.OriginalSound ~= nil then return end

    wep.Primary.OriginalSound = wep.Primary.Sound
    wep.Primary.Sound = chosen_sound
end

function Randomat:OverrideWeaponSoundData(data, chosen_sound)
    if not IsValid(data.Entity) then return end

    local current_sound = data.SoundName:lower()
    local fire_start, _ = string.find(current_sound, ".*weapons/.*fire.*%..*")
    local shot_start, _ = string.find(current_sound, ".*weapons/.*shot.*%..*")
    local shoot_start, _ = string.find(current_sound, ".*weapons/.*shoot.*%..*")
    if fire_start or shot_start or shoot_start then
        data.SoundName = chosen_sound
        return true
    end
end

-- Player Functions
local player_view_offsets = {}
local player_view_offsets_ducked = {}
function Randomat:SetPlayerScale(ply, scale, id)
    ply:SetStepSize(ply:GetStepSize() * scale)
    ply:SetModelScale(ply:GetModelScale() * scale, 1)

    -- Save the original values
    local sid = ply:SteamID64()
    if not player_view_offsets[sid] then
        player_view_offsets[sid] = ply:GetViewOffset()
    end
    if not player_view_offsets_ducked[sid] then
        player_view_offsets_ducked[sid] = ply:GetViewOffsetDucked()
    end

    -- Use the current, not the saved, values so that this can run multiple times (in theory)
    ply:SetViewOffset(ply:GetViewOffset()*scale)
    ply:SetViewOffsetDucked(ply:GetViewOffsetDucked()*scale)

    local a, b = ply:GetHull()
    ply:SetHull(a * scale, b * scale)

    a, b = ply:GetHullDuck()
    ply:SetHullDuck(a * scale, b * scale)

    -- Reduce the player speed on the client
    local speed_factor = math.Clamp(ply:GetStepSize() / 9, 0.25, 1)
    net.Start("RdmtSetSpeedMultiplier")
    net.WriteFloat(speed_factor)
    net.WriteString("Rdmt" .. id .. "Speed")
    net.Send(ply)
end

function Randomat:ResetPlayerScale(ply, id)
    ply:SetModelScale(1, 1)

    -- Retrieve the saved offsets
    local offset = nil
    local sid = ply:SteamID64()
    if player_view_offsets[sid] then
        offset = player_view_offsets[sid]
        player_view_offsets[sid] = nil
    end
    -- Reset the view offset to the saved value or the default (if the ec_ViewChanged is not set)
    -- The "ec_ViewChanged" property is from the "Enhanced Camera" mod which use ViewOffset to make the camera more "realistic"
    if offset or not ply.ec_ViewChanged then
        ply:SetViewOffset(offset or Vector(0, 0, 64))
    end

    -- Retrieve the saved ducked offsets
    local offset_ducked = nil
    if player_view_offsets_ducked[sid] then
        offset_ducked = player_view_offsets_ducked[sid]
        player_view_offsets_ducked[sid] = nil
    end
    -- Reset the view offset to the saved value or the default (if the ec_ViewChanged is not set)
    -- The "ec_ViewChanged" property is from the "Enhanced Camera" mod which use ViewOffset to make the camera more "realistic"
    if offset_ducked or not ply.ec_ViewChanged then
        ply:SetViewOffsetDucked(offset_ducked or Vector(0, 0, 28))
    end
    ply:ResetHull()
    ply:SetStepSize(18)

    -- Reset the player speed on the client
    net.Start("RdmtRemoveSpeedMultiplier")
    net.WriteString("Rdmt" .. id .. "Speed")
    net.Send(ply)
end

function Randomat:SetPlayerInvisible(ply)
    ply:SetColor(Color(255, 255, 255, 0))
    ply:SetMaterial("sprites/heatwave")
end

function Randomat:SetPlayerVisible(ply)
    ply:SetColor(Color(255, 255, 255, 255))
    ply:SetMaterial("models/glass")
end