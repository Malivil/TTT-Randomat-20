local EVENT = {}

EVENT.Title = "Glitch in the Matrix"
EVENT.id = "glitch"

CreateConVar("randomat_glitch_traitor_pct", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The percentage of players that will be traitors", 1, 100)
CreateConVar("randomat_glitch_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")
CreateConVar("randomat_glitch_damage_scale", 1.0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The multiplier for damage that the Glitches will take", 0.1, 2.0)
CreateConVar("randomat_glitch_max_glitches", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The maximum number of Glitches this event will create", 0, 16)
CreateConVar("randomat_glitch_starting_health", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the Glitches should start with", 1, 200)

local blocklist = {}

function EVENT:Begin()
    for blocked_id in string.gmatch(GetConVar("randomat_glitch_blocklist"):GetString(), '([^,]+)') do
        table.insert(blocklist, blocked_id:Trim())
    end

    local players = self:GetAlivePlayers(true)
    local tcount = math.ceil(#players * (GetConVar("randomat_glitch_traitor_pct"):GetInt()/100))

    -- Limit the number of Glitches to create
    local maxglitch = GetConVar("randomat_glitch_max_glitches"):GetInt()
    local gcount = nil
    -- 0 means "unlimited"
    if maxglitch > 0 then
        gcount = maxglitch
    end

    for _, v in pairs(players) do
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

function EVENT:CallHooks(isequip, id, ply)
    hook.Call("TTTOrderedEquipment", GAMEMODE, ply, id, isequip)
    net.Start("RandomatRandomWeapons")
    net.WriteBit(isequip)
    if isequip then
        net.WriteInt(id, 16)
    else
        net.WriteString(id)
    end
    net.Send(ply)
end

function EVENT:GiveWep(ply)
    if ply.glitchweptries >= 100 then ply.glitchweptries = nil return end
    ply.glitchweptries = ply.glitchweptries + 1

    local item, item_id, swep_table = self:FindWep()
    if item_id then
        if ply:HasEquipmentItem(item_id) then
            self:GiveWep(ply)
        else
            ply:GiveEquipmentItem(item_id)
            self:CallHooks(true, item_id, ply)
            ply.glitchweptries = 0
        end
    elseif swep_table then
        if ply:CanCarryWeapon(swep_table) then
            ply:Give(item.ClassName)
            self:CallHooks(false, item.ClassName, ply)
            if swep_table.WasBought then
                swep_table:WasBought(ply)
            end
            ply.glitchweptries = 0
        else
            self:GiveWep(ply)
        end
    end
end

function EVENT:FindWep()
    local tbl = table.Copy(EquipmentItems[ROLE_TRAITOR])
    for _, v in pairs(weapons.GetList()) do
        if v and v.CanBuy and not table.HasValue(blocklist, v.ClassName) then
            table.insert(tbl, v)
        end
    end
    table.Shuffle(tbl)

    local item = table.Random(tbl)
    local item_id = tonumber(item.id)
    local swep_table = (not item_id) and weapons.GetStored(item.ClassName) or nil
    return item, item_id, swep_table
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"traitor_pct", "damage_scale", "max_glitches", "starting_health"}) do
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

    local textboxes = {}
    for _, v in pairs({"blocklist"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(textboxes, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, {}, textboxes
end

Randomat:register(EVENT)