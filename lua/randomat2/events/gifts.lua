local EVENT = {}

util.AddNetworkString("RdmtDeadGiftBegin")
util.AddNetworkString("RdmtDeadGiftEnd")

CreateConVar("randomat_gifts_charge_time", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many seconds before the dead can give a gift", 10, 120)
CreateConVar("randomat_gifts_random_items", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether everyone should get a random item to gift")
CreateConVar("randomat_gifts_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")

EVENT.Title = "Gifts from the Dead"
EVENT.Description = "Allows dead players to give the living a single gift"
EVENT.id = "gifts"
EVENT.Type = EVENT_TYPE_SPECTATOR_UI

local traitor_default = "weapon_ttt_c4"
local innocent_default = "weapon_ttt_stungun"
local blocklist = {}
local equips = {}
local function GetPlayerEquip(ply)
    local sid = ply:SteamID64()
    if not equips[sid] then
        local random = GetConVar("randomat_gifts_random_items"):GetBool()
        -- Use the defaults if random weapons are disabled
        if not random then
            if Randomat:IsTraitorTeam(ply) or Randomat:IsIndependentTeam(ply) then
                equips[sid] = traitor_default
            else
                equips[sid] = innocent_default
            end
        else
            local default
            local roles
            if Randomat:IsTraitorTeam(ply) or Randomat:IsIndependentTeam(ply) then
                default = traitor_default
                roles = {ROLE_TRAITOR}
            else
                default = innocent_default
                roles = {ROLE_DETECTIVE}
            end

            local _, _, swep_table = Randomat:GetShopEquipment(ply, roles, blocklist, false, ply.deadgiftstries,
                -- settrackingvar
                function(value)
                    ply.deadgiftstries = value
                end, true)

            -- If we haven't gotten a valid weapon (for whatever reason) use the default ofrt his team
            equips[sid] = WEPS.GetClass(swep_table) or default
        end
    end
    return equips[sid]
end

function EVENT:Begin()
    equips = {}
    blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_blackmarket_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    for _, p in ipairs(player.GetAll()) do
        p:SetNWInt("RdmtDeadGiftPower", 0)
        p:SetNWBool("RdmtDeadGiftSent", false)
        if not p:Alive() or p:IsSpec() then
            net.Start("RdmtDeadGiftBegin")
            net.WriteString(GetPlayerEquip(p))
            net.Send(p)
        end
    end

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        net.Start("RdmtDeadGiftEnd")
        net.Send(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        net.Start("RdmtDeadGiftBegin")
        net.WriteString(GetPlayerEquip(victim))
        net.Send(victim)
    end)

    self:AddHook("KeyPress", function(ply, key)
        if key == IN_JUMP and ply:GetNWInt("RdmtDeadGiftPower", 0) == 100 then
            local equip = GetPlayerEquip(ply)
            local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil
            -- Try to give this item to the current spectator target
            if IsPlayer(target) then
                if target:CanCarryWeapon(weapons.GetStored(equip)) then
                    ply:PrintMessage(HUD_PRINTTALK, "You gave " .. target:Nick() .. " your gift")
                    ply:PrintMessage(HUD_PRINTCENTER, "You gave " .. target:Nick() .. " your gift")
                    target:PrintMessage(HUD_PRINTTALK, ply:Nick() .. " gave you a gift")
                    target:PrintMessage(HUD_PRINTCENTER, ply:Nick() .. " gave you a gift")
                    target:Give(equip)
                else
                    ply:PrintMessage(HUD_PRINTTALK, target:Nick() .. " can't use your gift")
                    ply:PrintMessage(HUD_PRINTCENTER, target:Nick() .. " can't use your gift")
                    return
                end
            -- If there is no target, just drop it on the ground
            else
                local ent = ents.Create(equip)
                ent:SetPos(ply:GetPos())
                ent:Spawn()

                ply:PrintMessage(HUD_PRINTTALK, "Your gift has been dropped on the ground")
                ply:PrintMessage(HUD_PRINTCENTER, "Your gift has been dropped on the ground")
            end

            -- Reset the player's power
            ply:SetNWInt("RdmtDeadGiftPower", 0)
            ply:SetNWBool("RdmtDeadGiftSent", true)

            -- Hide the UI
            net.Start("RdmtDeadGiftEnd")
            net.Send(ply)
        end
    end)

    local tick = GetConVar("randomat_gifts_charge_time"):GetInt() / 100
    timer.Create("RdmtDeadGiftPowerTimer", tick, 0, function()
        for _, p in ipairs(self:GetDeadPlayers()) do
            if not p:GetNWBool("RdmtDeadGiftSent", false) then
                local power = p:GetNWInt("RdmtDeadGiftPower", 0)
                if power < 100 then
                    p:SetNWInt("RdmtDeadGiftPower", power + 1)
                end
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtDeadGiftPowerTimer")
    net.Start("RdmtDeadGiftEnd")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"charge_time"}) do
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

    local checks = {}
    for _, v in ipairs({"random_items"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks
end

Randomat:register(EVENT)