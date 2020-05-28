local EVENT = {}

EVENT.Title = "Glitch in the Matrix"
EVENT.id = "glitch"

CreateConVar("randomat_glitch_traitor_pct", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The percentage of players that will be traitors", 1, 100)

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

function EVENT:Begin()
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
            v.randomweptries = 0
            self:GiveWep(v)
        end)
    end
    SendFullStateUpdate()
end

function EVENT:CallHooks(IsEquip, ID, ply)
    hook.Call("TTTOrderedEquipment", GAMEMODE, ply, ID, IsEquip)
    net.Start("RandomatRandomWeapons")
    net.WriteBit(IsEquip)
    if IsEquip then
        net.WriteInt(ID, 16)
    else
        net.WriteString(ID)
    end
    net.Send(ply)
end

function EVENT:GiveWep(ply)
    if ply.randomweptries == 100 then ply.randomweptries = nil return end
    ply.randomweptries = ply.randomweptries + 1

    local item, is_item, swep_table = self:FindWep()
    if is_item then
        if ply:HasEquipmentItem(is_item) then
            self:GiveWep(ply)
        else
            ply:GiveEquipmentItem(is_item)
            self:CallHooks(true, is_item, ply)
            ply.randomweptries = 0
        end
    elseif swep_table then
        if ply:CanCarryWeapon(swep_table) then
            ply:Give(item.ClassName)
            self:CallHooks(false, item.ClassName, ply)
            if swep_table.WasBought then
                swep_table:WasBought(ply)
            end
            ply.randomweptries = 0
        else
            self:GiveWep(ply)
        end
    end
end

function EVENT:FindWep()
    local tbl = table.Copy(EquipmentItems[ROLE_TRAITOR])
    for _, v in pairs(weapons.GetList()) do
        if v and v.CanBuy then
            table.insert(tbl, v)
        end
    end
    table.Shuffle(tbl)
    local item = table.Random(tbl)
    local is_item = tonumber(item.id)
    local swep_table = (not is_item) and weapons.GetStored(item.ClassName) or nil

    return item, is_item, swep_table
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
    return sliders
end

Randomat:register(EVENT)