-- Event Types
EVENT_TYPE_DEFAULT = 0
EVENT_TYPE_WEAPON_OVERRIDE = 1

-- Shared Functions
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

function Randomat:IsDetectiveLike(ply)
    if ply.IsDetectiveLike then return ply:IsDetectiveLike() end
    local role = ply:GetRole()
    return role == ROLE_DETECTIVE or ROLE_DETRAITOR
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
        [ROLE_KILLER] = Color(50, 0, 70, 255),
        [ROLE_DETRAITOR] = Color(112, 27, 140, 255),
        [ROLE_REVENGER] =  Color(245, 200, 0, 255),
        [ROLE_DRUNK] = Color(255, 80, 235, 255),
        [ROLE_DEPUTY] =  Color(245, 200, 0, 255),
        [ROLE_IMPERSONATOR] = Color(245, 106, 0, 255),
        [ROLE_BEGGAR] = Color(180, 23, 253, 255),
        [ROLE_CLOWN] = Color(255, 80, 235, 255)
    }
    return role_colors[role]
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