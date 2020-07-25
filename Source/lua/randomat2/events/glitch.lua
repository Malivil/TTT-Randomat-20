local EVENT = {}

EVENT.Title = "Glitch in the Matrix"
EVENT.id = "glitch"

CreateConVar("randomat_glitch_traitor_pct", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The percentage of players that will be traitors", 1, 100)
CreateConVar("randomat_glitch_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")

local function StripBannedWeapons(ply)
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
end

local blocklist = {}

function EVENT:Begin()
    for blocked_id in string.gmatch(GetConVar("randomat_glitch_blocklist"):GetString(), '([^,]+)') do
        table.insert(blocklist, blocked_id:Trim())
    end

    local players = self:GetAlivePlayers(true);
    local tcount = math.ceil(#players * (GetConVar("randomat_glitch_traitor_pct"):GetInt()/100))
    for _, v in pairs(players) do
        if tcount > 0 then
            Randomat:SetRole(v, ROLE_TRAITOR)
            tcount = tcount - 1
        else
            Randomat:SetRole(v, ROLE_GLITCH)
        end

        StripBannedWeapons(v)

        timer.Simple(0.1, function()
            v.glitchweptries = 0
            self:GiveWep(v)
        end)
    end
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
    for _, v in pairs({"traitor_pct"}) do
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