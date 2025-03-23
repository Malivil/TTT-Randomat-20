local EVENT = {}

CreateConVar("randomat_scoutsonly_gravity", 0.1, FCVAR_NONE, "The gravity scale", 0.1, 0.9)

EVENT.Title = "Scouts Only"
EVENT.Description = "Forces everyone to use a rifle and lowers everyone's gravity"
EVENT.id = "scoutsonly"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"gamemode", "item", "rolechange", "largeimpact"}

local function SetGravity(alive_players)
    local gravity = GetConVar("randomat_scoutsonly_gravity"):GetFloat()
    for _, ply in ipairs(alive_players) do
        ply:SetGravity(gravity)
    end
end

function EVENT:Begin()
    local alive_players = self:GetAlivePlayers()
    SetGravity(alive_players)
    timer.Create("RandomatScoutsOnlyTimer", 1, 0, function()
        SetGravity(self:GetAlivePlayers())
    end)

    -- Convert all players to vanilla roles and replace all their weapons with the rifle
    local new_traitors = {}
    for _, p in ipairs(alive_players) do
        if Randomat:IsInnocentTeam(p) then
            if p:GetRole() ~= ROLE_INNOCENT then
                Randomat:SetRole(p, ROLE_INNOCENT)
            end
        elseif p:GetRole() ~= ROLE_TRAITOR then
            if not Randomat:IsTraitorTeam(p) then
                table.insert(new_traitors, p)
            end
            Randomat:SetRole(p, ROLE_TRAITOR)
        end

        p:StripWeapons()
        local weap = p:Give("weapon_zm_rifle")
        if weap then
            weap.AllowDrop = false
        end
    end
    SendFullStateUpdate()

    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        return false
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if not is_item then
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'!\nYour purchase has been refunded.")
            return false
        end
    end)

    self:AddHook("Think", function()
        for _, v in ipairs(self:GetAlivePlayers()) do
            local active_weapon = v:GetActiveWeapon()
            if IsValid(active_weapon) and active_weapon.Primary then
                active_weapon:SetClip1(active_weapon.Primary.ClipSize)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatScoutsOnlyTimer")
    for _, ply in player.Iterator() do
        ply:SetGravity(1)
        ply:Give("weapon_ttt_unarmed")
        ply:Give("weapon_zm_carry")
        ply:Give("weapon_zm_improvised")
        local weap = ply:GetActiveWeapon()
        if weap then
            weap.AllowDrop = true
        end
    end
end

function EVENT:Condition()
    for _, p in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsJesterTeam(p) then
            return false
        end
    end
    return true
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"gravity"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 1
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)