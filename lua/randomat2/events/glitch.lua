local EVENT = {}

EVENT.Title = "Glitch in the Matrix"
EVENT.Description = "Changes everyone's role to be either Glitch or Traitor and gives a random shop item."
EVENT.id = "glitch"
EVENT.Categories = {"rolechange", "largeimpact"}

CreateConVar("randomat_glitch_traitor_pct", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The percentage of players that will be traitors", 1, 100)
CreateConVar("randomat_glitch_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")
CreateConVar("randomat_glitch_damage_scale", 1.0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The multiplier for damage that the Glitches will take", 0.1, 2.0)
CreateConVar("randomat_glitch_max_glitches", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The maximum number of Glitches this event will create", 0, 16)
CreateConVar("randomat_glitch_starting_health", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the Glitches should start with", 1, 200)
CreateConVar("randomat_glitch_min_traitors", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The minimum number of Traitors before this event will run", 0, 32)

local blocklist = {}

function EVENT:Begin()
    -- Update this in case the role names have been changed
    EVENT.Description = "Randomly changes everyone's role to be either " .. Randomat:GetRoleString(ROLE_GLITCH) .. " or " .. Randomat:GetRoleString(ROLE_TRAITOR)

    blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_glitch_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    -- Set this as a glitch round so role assignment logic behaves correctly
    SetGlobalBool("ttt_glitch_round", true)

    local players = self:GetAlivePlayers(true)
    local tcount = math.ceil(#players * (GetConVar("randomat_glitch_traitor_pct"):GetInt()/100))

    -- Limit the number of Glitches to create
    local maxglitch = GetConVar("randomat_glitch_max_glitches"):GetInt()
    local gcount = nil
    -- 0 means "unlimited"
    if maxglitch > 0 then
        gcount = maxglitch
    end

    for _, v in ipairs(players) do
        -- If we have exceeded the maximum number of Glitches, make the remaining players Traitors, even if we have surpassed the configured percent
        if tcount > 0 or (gcount ~= nil and gcount == 0) then
            Randomat:SetRole(v, ROLE_TRAITOR)
            tcount = tcount - 1
        else
            Randomat:SetRole(v, ROLE_GLITCH)
            if gcount ~= nil then
                gcount = gcount - 1
            end

            -- Update the Glitches' health to the configured max, but keep the amount of damage they've already taken
            local glitchhealth = GetConVar("randomat_glitch_starting_health"):GetInt()
            if glitchhealth ~= 100 then
                local healthlost = v:GetMaxHealth() - v:Health()
                local newhealth = glitchhealth - healthlost
                v:SetMaxHealth(glitchhealth)
                v:SetHealth(newhealth)
            end
        end

        self:StripRoleWeapons(v)

        timer.Simple(0.1, function()
            v.glitchweptries = 0
            self:GiveWep(v)
        end)
    end

    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        if not IsValid(ply) then return end

        if ply:IsGlitch() then
            dmginfo:ScaleDamage(GetConVar("randomat_glitch_damage_scale"):GetFloat())
        end
    end)

    SendFullStateUpdate()
end

function EVENT:GiveWep(ply)
    Randomat:GiveRandomShopItem(ply, {ROLE_TRAITOR}, blocklist, true,
        -- gettrackingvar
        function()
            return ply.glitchweptries
        end,
        -- settrackingvar
        function(value)
            ply.glitchweptries = value
        end,
        -- onitemgiven
        function(isequip, id)
            Randomat:CallShopHooks(isequip, id, ply)
        end)
end

function EVENT:Condition()
    local min_traitors = GetConVar("randomat_glitch_min_traitors"):GetInt()
    if min_traitors <= 0 then return true end

    local t = 0
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsTraitorTeam(v) then
            t = t + 1
        end
    end

    return t >= min_traitors
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"traitor_pct", "damage_scale", "max_glitches", "starting_health", "min_traitors"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "damage_scale" and 1 or 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)