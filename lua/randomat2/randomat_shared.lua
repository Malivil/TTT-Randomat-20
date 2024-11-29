-- Events
EVENT_TYPE_DEFAULT = 0
EVENT_TYPE_WEAPON_OVERRIDE = 1
EVENT_TYPE_VOTING = 2
EVENT_TYPE_SMOKING = 3
EVENT_TYPE_SPECTATOR_UI = 4
EVENT_TYPE_RESPAWN = 5
EVENT_TYPE_GUNSOUNDS = 6
EVENT_TYPE_JUMPING = 7
EVENT_TYPE_MUSIC = 8
EVENT_TYPE_FORCED_DEATH = 9

function Randomat:IsEventActive(id)
    for _, v in pairs(Randomat.ActiveEvents) do
        if v.Id == id then
            return true
        end
    end
    return false
end

-- String Functions

function Randomat:Capitalize(msg, skip_lower)
    local first = msg:sub(1, 1):upper()
    local rest = msg:sub(2)
    if not skip_lower then
        rest = rest:lower()
    end
    return first .. rest
end

function Randomat:GetPlayerNameListString(players, includeAnd)
    local names = {}
    for _, p in ipairs(players) do
        table.insert(names, p:Nick())
    end

    local joined = table.concat(names, ", ")
    if includeAnd then
        if #names > 2 then
            local result, _ = string.gsub(joined, "(.*),", "%1, and")
            return result
        -- Don't include the comma if there are only two entries
        else
            local result, _ = string.gsub(joined, "(.*),", "%1 and")
            return result
        end
    end
    return joined
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

function Randomat:IsDetectiveTeam(ply)
    if ply.IsDetectiveTeam then return ply:IsDetectiveTeam() end
    return ply:GetRole() == ROLE_DETECTIVE
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

function Randomat:CanRoleSpawn(role)
    if not role or role == -1 then return false end

    if util.CanRoleSpawn then
        return util.CanRoleSpawn(role)
    end

    if role == ROLE_DETECTIVE or role == ROLE_INNOCENT or role == ROLE_TRAITOR then
        return true
    end

    if ROLE_STRINGS_RAW or ROLE_STRINGS then
        local cvar = "ttt_" .. (ROLE_STRINGS_RAW[role] or ROLE_STRINGS[role]) .. "_enabled"
        return ConVarExists(cvar) and GetConVar(cvar):GetBool()
    end

    return false
end

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

function Randomat:ShouldActLikeJester(ply)
    if ply.ShouldActLikeJester then return ply:ShouldActLikeJester() end
    return Randomat:IsJesterTeam(ply)
end

function Randomat:GetRoleColor(role)
    if type(role) == "Player" then
        role = role:GetRole()
    end

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
    -- Otherwise just assume any role in the list of shop roles can use the shop
    local shop_roles = Randomat:GetShopRoles()
    return shop_roles[ply:GetRole()] or false
end

function Randomat:IsZombifying(ply)
    return (ply.IsZombifying and ply:IsZombifying()) or ply:GetNWBool("IsZombifying", false) or ply:GetPData("IsZombifying", 0) == 1
end

function Randomat:GetRoleTeamName(role_team)
    if GetRoleTeamName and CLIENT then return GetRoleTeamName(role_team) end

    if role_team == ROLE_TEAM_TRAITOR then
        return "Traitor"
    elseif role_team == ROLE_TEAM_MONSTER then
        return "Monster"
    elseif role_team == ROLE_TEAM_JESTER then
        return "Jester"
    elseif role_team == ROLE_TEAM_INDEPENDENT then
        return "Independent"
    end
    return "Innocent"
end

-- Weapon Functions

function Randomat:IsWeaponBuyable(wep)
    if not wep or not wep.CanBuy then return false end
    return #wep.CanBuy > 0
end

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

if SERVER then
    function Randomat:RemoveEquipmentItem(ply, item_id)
        -- Use the new method if it exists
        if ply.RemoveEquipmentItem then
            if ply:HasEquipmentItem(item_id) then
                ply:RemoveEquipmentItem(item_id)
                -- Give the player enough credits to compensate for the equipment they can no longer use
                ply:AddCredits(1)
                return true
            end
            return false
        end

        -- Keep track of what equipment the player had
        local i = 1
        local equip = {}
        local credits = 0
        local removed = false
        while i <= EQUIP_MAX do
            if ply:HasEquipmentItem(i) then
                -- Remove and refund the specific equipment item we're removing
                if i == item_id then
                    removed = true
                    credits = credits + 1
                else
                    table.insert(equip, i)
                end
            end
            -- Double the index since this is a bit-mask
            i = i * 2
        end

        -- Exit early if we didn't change anything
        if not removed then return false end

        -- Give the player enough credits to compensate for the equipment they can no longer use
        ply:AddCredits(credits)

        -- Remove all their equipment
        ply:ResetEquipment()

        -- Add back the others (since we only want to remove the given item)
        for _, id in ipairs(equip) do
            ply:GiveEquipmentItem(id)
        end

        return true
    end

    function Randomat:RemovePhdFlopper(ply, block_message)
        local removed = false
        -- Remove and refund the player's PHD Flopper
        if Randomat:RemoveEquipmentItem(ply, EQUIP_PHD) then
            removed = true
            ply:SetNWBool("PHDActive", false)
        elseif ply:GetNWString("phdIsActive", "false") == "true" then
            ply:SetNWString("phdIsActive", "false")
            ply.ShouldRemoveFallDamage = false
            hook.Remove("HUDPaint", "perkHUDPaintIcon")
            -- Explicitly refund this here. RemoveEquipmentItem handles the refund of the other type of PHD Flopper
            ply:AddCredits(1)
        end

        if removed and not block_message then
            timer.Simple(1, function()
                ply:ChatPrint("PHD Floppers are disabled while this event is active! Your purchase has been refunded.")
            end)
        end
    end

    -- Player Functions
    local player_view_offsets = {}
    local player_view_offsets_ducked = {}
    function Randomat:SetPlayerScale(ply, scale, id, skip_speed)
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
        ply:SetViewOffset(ply:GetViewOffset() * scale)
        ply:SetViewOffsetDucked(ply:GetViewOffsetDucked() * scale)

        local a, b = ply:GetHull()
        ply:SetHull(a * scale, b * scale)

        a, b = ply:GetHullDuck()
        ply:SetHullDuck(a * scale, b * scale)

        -- If we don't want to adjust the player's speed, we're done here
        if skip_speed then return end

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
end

function Randomat:IsPlayerInvisible(ply)
    return ply:GetNWBool("RdmtInvisible", false)
end

function Randomat:SetPlayerInvisible(ply)
    ply:SetColor(Color(255, 255, 255, 0))
    ply:SetMaterial("sprites/heatwave")
    ply:SetNWBool("RdmtInvisible", true)
    ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    ply:SetNoDraw(true)
end

function Randomat:SetPlayerVisible(ply)
    ply:SetColor(COLOR_WHITE)
    ply:SetMaterial("")
    ply:SetNWBool("RdmtInvisible", false)
    ply:SetRenderMode(RENDERMODE_NORMAL)
    ply:SetNoDraw(false)
end

function Randomat:IsPlayerInVehicle(ply)
    if not IsValid(ply) then return false, nil end

    local parent = ply:GetParent()
    if not IsValid(parent) then return false, nil end

    local class = parent:GetClass()
    return string.StartsWith(class, "prop_vehicle_"), parent
end

-- Round Functions

if SERVER then
    function Randomat:GetRoundCompletePercent()
        return ((CurTime() - GAMEMODE.RoundStartTime) / (GetGlobalFloat("ttt_round_end", CurTime()) - GAMEMODE.RoundStartTime)) * 100
    end

    function Randomat:GetRoundLimit()
        return GetConVar("ttt_round_limit"):GetInt()
    end

    function Randomat:GetRoundsComplete()
        return Randomat:GetRoundLimit() - Randomat:GetRoundsLeft()
    end

    function Randomat:GetRoundsLeft()
        return math.max(0, GetGlobalInt("ttt_rounds_left", Randomat:GetRoundLimit()))
    end
end

-- Chat functions

-- Shim the CR4TTT message constants
if not MSG_PRINTBOTH then
    MSG_PRINTBOTH = 1
    MSG_PRINTTALK = HUD_PRINTTALK
    MSG_PRINTCENTER = HUD_PRINTCENTER
end

function Randomat:PrintMessage(ply, msgtype, message)
    -- QueueMessage already handles immediately printing MSG/HUD_PRINTTALK so there's no reason for us to think too much about it here
    if CR_VERSION and msgtype ~= HUD_PRINTCONSOLE then
        ply:QueueMessage(msgtype, message)
        return
    end

    -- If we're trying to print to both without the new CR version, just do that manually
    if msgtype == MSG_PRINTBOTH then
        ply:PrintMessage(HUD_PRINTTALK, message)
        ply:PrintMessage(HUD_PRINTCENTER, message)
    else
        ply:PrintMessage(msgtype, message)
    end
end

function Randomat:SendChatToAll(msg, tbl)
    if type(tbl) ~= "table" then
        tbl = player.GetAll()
    end

    for _, p in pairs(tbl) do
        p:PrintMessage(HUD_PRINTTALK, msg)
    end
end

if SERVER then
    function Randomat:SendMessageToTeam(msg, roleTeam, detectivesAreInnocent, aliveOnly, printTypes, excludedPlayers)
        -- This method only works with CR for TTT
        if not CR_VERSION then return end

        -- This is required
        if not roleTeam then return end

        if type(printTypes) ~= "table" then
            if type(printTypes) == "number" then
                printTypes = {printTypes}
            else
                printTypes = {HUD_PRINTTALK}
            end
        end

        player.ExecuteAgainstTeamPlayers(roleTeam, detectivesAreInnocent, aliveOnly, function(ply)
            -- Skip excluded players, if we have any
            if excludedPlayers and table.HasValue(excludedPlayers, ply) then return end

            for _, printType in ipairs(printTypes) do
                ply:PrintMessage(printType, msg)
            end
        end)
    end
end

-- Player Model functions, credit to The Stig

local playermodelData = {}

function Randomat:GetPlayerModelData(ply)
    if not IsPlayer(ply) then return nil end

    local bodygroupValues = {}
    for _, value in ipairs(ply:GetBodyGroups()) do
        bodygroupValues[value.id] = ply:GetBodygroup(value.id)
    end

    return {
        model = ply:GetModel(),
        viewOffset = ply:GetViewOffset(),
        viewOffsetDucked = ply:GetViewOffsetDucked(),
        playerColor = ply:GetPlayerColor(),
        skin = ply:GetSkin(),
        bodyGroups = ply:GetBodyGroups(),
        bodygroupValues = bodygroupValues
    }
end

local function SetHands(ent, model)
    if not IsValid(ent) then return end
    local simpleModelName = player_manager.TranslateToPlayerModelName(model)
    local handsData = player_manager.TranslatePlayerHands(simpleModelName)

    if handsData then
        ent:SetModel(handsData.model)
        ent:SetSkin(handsData.skin)
        ent:SetBodyGroups(handsData.body)
    end
end

function Randomat:ForceSetPlayermodel(ply, data)
    if not IsPlayer(ply) then return end

    -- Use the entity SetModel meta function to bypass model blocking things like in Enhanced Player Model Selector
    local SetModel = FindMetaTable("Entity").SetModel

    -- If just a model by itself is passed, just set the model and leave it at that
    if not istable(data) then
        if not isstring(data) or not util.IsValidModel(data) then return end
        SetModel(ply, data)
        SetHands(ply:GetHands(), data)
        return
    end

    -- Else, set everything that's in the data table
    if util.IsValidModel(data.model) then
        SetModel(ply, data.model)
        SetHands(ply:GetHands(), data.model)
    end

    if data.playerColor then
        ply:SetPlayerColor(data.playerColor)
    end

    if data.skin then
        ply:SetSkin(data.skin)
    end

    if data.bodyGroups then
        for _, value in pairs(data.bodyGroups) do
            ply:SetBodygroup(value.id, data.bodygroupValues[value.id])
        end
    elseif data.bodygroupValues then
        for id = 0, #data.bodygroupValues do
            ply:SetBodygroup(id, data.bodygroupValues[id])
        end
    end

    timer.Simple(0.1, function()
        if data.viewOffset then
            ply:SetViewOffset(data.viewOffset)
        else
            ply:SetViewOffset(Vector(0, 0, 64))
        end

        if data.viewOffsetDucked then
            ply:SetViewOffsetDucked(data.viewOffsetDucked)
        else
            ply:SetViewOffsetDucked(Vector(0, 0, 28))
        end
    end)
end

function Randomat:ForceResetAllPlayermodels()
    for _, ply in player.Iterator() do
        local sid64 = ply:SteamID64()
        if playermodelData[sid64] then
            Randomat:ForceSetPlayermodel(ply, playermodelData[sid64])
        end
    end
end

hook.Add("TTTBeginRound", "RdmtGetStartingPlayerModels", function()
    table.Empty(playermodelData)
    for _, ply in player.Iterator() do
        playermodelData[ply:SteamID64()] = Randomat:GetPlayerModelData(ply)
    end
end)