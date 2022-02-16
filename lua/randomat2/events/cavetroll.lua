local EVENT = {}

util.AddNetworkString("RdmtCaveTrollBegin")
util.AddNetworkString("RdmtCaveTrollEnd")

EVENT.Title = "They have a cave troll"
EVENT.Description = "Chooses a random traitor and makes them a strong giant with a club.\nOther random players are chosen to be smaller and given knives"
EVENT.id = "cavetroll"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

CreateConVar("randomat_cavetroll_troll_scale", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The scale factor to use for the troll", 1.1, 3.0)
CreateConVar("randomat_cavetroll_troll_damage", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How much damage the club should do", 0, 100)
CreateConVar("randomat_cavetroll_troll_health", 150, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The amount of health the troll should have", 100, 300)
CreateConVar("randomat_cavetroll_hobbit_scale", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The scale factor to use for the hobbits", 0.1, 0.9)
CreateConVar("randomat_cavetroll_hobbit_pct", 0.34, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The percent of non-traitors to be hobbits", 0, 0.5)
CreateConVar("randomat_cavetroll_hobbit_damage", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How much damage the swords should do", 1, 100)

function EVENT:Begin()
    local troll_scale = GetConVar("randomat_cavetroll_troll_scale"):GetFloat()
    local troll_damage = GetConVar("randomat_cavetroll_troll_damage"):GetInt()
    local troll_health = GetConVar("randomat_cavetroll_troll_health"):GetInt()
    local hobbit_scale = GetConVar("randomat_cavetroll_hobbit_scale"):GetFloat()
    local hobbit_pct = GetConVar("randomat_cavetroll_hobbit_pct"):GetFloat()
    local hobbit_damage = GetConVar("randomat_cavetroll_hobbit_damage"):GetInt()

    -- Sort the players
    local traitors = {}
    local others = {}
    local detective = nil
    for _, p in ipairs(self:GetAlivePlayers(true)) do
        if Randomat:IsTraitorTeam(p) then
            table.insert(traitors, p)
        elseif Randomat:IsGoodDetectiveLike(p) then
            detective = p
        else
            table.insert(others, p)
        end
    end

    -- Determine how many hobbits there should be
    local other_count = #others + (detective and 1 or 0)
    local hobbit_count = math.max(1, math.Round(other_count * hobbit_pct))
    local hobbits = {}

    -- If there is a detective, they automatically become a hobbit
    if detective ~= nil then
        table.insert(hobbits, detective)
        hobbit_count = hobbit_count - 1
    end

    -- Select the remaining hobbits
    for i = 1, hobbit_count do
        table.insert(hobbits, others[i])
    end

    -- Choose the troll, update their role and health, and remove their weapons
    local troll = traitors[1]
    local max_hp = troll:GetMaxHealth()
    Randomat:SetRole(troll, ROLE_TRAITOR, false)
    troll:SetMaxHealth(troll_health)
    troll:SetHealth(troll_health - (max_hp - troll:Health()))
    troll:StripWeapons()
    local club = troll:Give("weapon_ttt_randomatclub")
    if club then
        club.Primary.Damage = troll_damage
    end

    -- Give the cave troll infinite sprint
    net.Start("RdmtCaveTrollBegin")
    net.Send(troll)

    -- Scale the players and give the hobbits knives
    Randomat:SetPlayerScale(troll, troll_scale, self.id)
    for _, h in ipairs(hobbits) do
        Randomat:SetPlayerScale(h, hobbit_scale, self.id)
        h:StripWeapon("weapon_zm_improvised")
        local knife = h:Give("weapon_ttt_randomatknife")
        if knife then
            knife.Primary.Damage = hobbit_damage
        end
    end

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        -- Invalid, dead, spectator, and non-trolls can pick up whatever they want
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply ~= troll then
            return
        end
        -- The troll can only use the club
        return IsValid(wep) and WEPS.GetClass(wep) == "weapon_ttt_randomatclub"
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if ply ~= troll then return end
        if not is_item then
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'!\nYour purchase has been refunded.")
            return false
        end
    end)

    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end

        -- Reduce damage to the non-traitors who have body armor
        if not Randomat:IsTraitorTeam(ply) and ply:HasEquipmentItem(EQUIP_ARMOR) and not dmginfo:IsBulletDamage() then
            dmginfo:ScaleDamage(0.5)
        end
    end)
end

function EVENT:End()
    self:ResetAllPlayerScales()
    net.Start("RdmtCaveTrollEnd")
    net.Broadcast()
end

function EVENT:Condition()
    for _, p in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsTraitorTeam(p) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"hobbit_pct"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end
    for _, v in ipairs({"troll_scale","troll_health", "hobbit_scale"}) do
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
    for _, v in ipairs({"troll_damage", "hobbit_damage"}) do
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