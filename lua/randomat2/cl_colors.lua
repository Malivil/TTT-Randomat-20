function Randomat:GetRoleColor(role)
    if type(ROLE_COLORS) == "table" then
        return ROLE_COLORS[role];
    end
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
        [ROLE_ROMANTIC] =  Color(245, 200, 0, 255),
        [ROLE_DRUNK] = Color(255, 80, 235, 255),
        [ROLE_DEPUTY] =  Color(245, 200, 0, 255),
        [ROLE_IMPERSONATOR] = Color(245, 106, 0, 255),
        [ROLE_BEGGAR] = Color(180, 23, 253, 255),
        [ROLE_CLOWN] = Color(255, 80, 235, 255)
    }
    return role_colors[role]
end