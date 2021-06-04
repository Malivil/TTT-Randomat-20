local EVENT = {}

util.AddNetworkString("PropHuntRemoveRadar")

CreateConVar("randomat_prophunt_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given prop disguisers", 1, 15)
CreateConVar("randomat_prophunt_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether the event strips your other weapons")
CreateConVar("randomat_prophunt_blind_time", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long to blind the hunters for at the start", 0, 60)
CreateConVar("randomat_prophunt_round_time", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How many seconds the Prop Hunt round should last", 0, 600)
CreateConVar("randomat_prophunt_weaponid", "weapon_ttt_prop_disguiser", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")

local cvar_states = {}
local default_weaponids = {"weapon_ttt_prop_disguiser", "weapon_ttt_prophide"}
local weaponid = nil

EVENT.Title = "Prop Hunt"
EVENT.Description = "Forces Innocents to use a Prop Disguiser, changing this to play like the popular gamemode Prop Hunt"
EVENT.id = "prophunt"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

local function PopulateWeaponId()
    if weaponid ~= nil then return end

    local config_weapon = GetConVar("randomat_prophunt_weaponid"):GetString()
    local weapon_options = table.Add({}, default_weaponids)
    -- Insert this ID at the start of the table if it's not already there
    if not table.HasValue(weapon_options, config_weapon) then
        table.insert(weapon_options, 0, config_weapon)
    end

    -- Find the first weapon in the list (which has the config value first) that exists
    for _, v in pairs(weapon_options) do
        if util.WeaponForClass(v) ~= nil then
            weaponid = v
            break
        end
    end
end

local function OverrideCvar(name, value)
    if not ConVarExists(name) then return end

    cvar_states[name] = GetConVar(name):GetInt()
    RunConsoleCommand(name, value)
end

function EVENT:HandleRoleWeapons(ply)
    local updated = false
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and not ply:GetRole() == ROLE_TRAITOR) or Randomat:IsMonsterTeam(ply) or Randomat:IsIndependentTeam(ply) then
        Randomat:SetRole(ply, ROLE_TRAITOR)
        updated = true
    end

    -- Remove role weapons from anyone on the traitor team now
    if Randomat:IsTraitorTeam(ply) then
        self:StripRoleWeapons(ply)
    end
    return updated
end

function EVENT:Begin()
    PopulateWeaponId()

    -- Set the round time if that CVar is being used
    local round_time = GetConVar("randomat_prophunt_round_time"):GetInt()
    if round_time > 0 then
        SetGlobalFloat("ttt_round_end", CurTime() + round_time)
    end

    -- Disable prop possession
    OverrideCvar("ttt_spec_prop_control", 0)
    -- Change CVar values back to their old defaults to make the prop disguiser weapon more usable for this event
    OverrideCvar("ttt_prop_disguiser_time", 30)
    OverrideCvar("ttt_prop_disguiser_cooldown", 2)

    for _, v in ipairs(self:GetAlivePlayers()) do
        local equip = {}
        local messages = {}
        -- All bad guys are traitors
        if Randomat:IsTraitorTeam(v) or Randomat:IsMonsterTeam(v) or Randomat:IsIndependentTeam(v) then
            Randomat:SetRole(v, ROLE_TRAITOR)

            local credits = v:GetCredits()
            -- Any player who has no credits most-likely was just transformed from a role without any credits so give them one to start with
            -- If a traitor already spent all their credits this will give them one too but that's fine
            if credits == 0 then
                credits = 1
            end

            -- Keep track of what equipment the player had
            local i = 1
            while i < EQUIP_MAX do
                if v:HasEquipmentItem(i) then
                    -- Remove and refund any radar that was purchased
                    if i == EQUIP_RADAR then
                        table.insert(messages, "Radars are disabled while Prop Hunt is active! Your purchase has been refunded.")
                        credits = credits + 1
                        net.Start("PropHuntRemoveRadar")
                        net.Send(v)
                    else
                        table.insert(equip, i)
                    end
                end
                -- Double the index since this is a bit-mask
                i = i * 2
            end

            -- Give the player enough credits to compensate for the equipment they can no longer use
            v:SetCredits(credits)
            table.insert(messages, 1, "Hunt Innocents disguised as props, but be careful -- shooting non-player props will cause you to take damage!")
        -- Everyone else is innocent
        else
            Randomat:SetRole(v, ROLE_INNOCENT)
            v:SetCredits(0)
            table.insert(messages, "Use the Prop Disguiser to hide from the Traitors!")
        end

        self:StripRoleWeapons(v)
        -- Remove all their equipment
        v:ResetEquipment()

        -- Add back the others (since we only want to remove radar)
        for _, id in ipairs(equip) do
            v:GiveEquipmentItem(id)
        end

        -- Delay the messages so they come after the event notification in chat
        timer.Create(v:Nick() .. "RandomatPropHuntMessageTimer", 1, 1, function()
            for _, msg in ipairs(messages) do
                v:ChatPrint(msg)
            end
        end)
    end
    SendFullStateUpdate()

    local traitors_blinded = false
    timer.Create("RandomatPropHuntTimer", GetConVar("randomat_prophunt_timer"):GetInt(), 0, function()
        if not traitors_blinded then
            local blind_time = GetConVar("randomat_prophunt_blind_time"):GetInt()
            if blind_time > 0 then
                Randomat:SilentTriggerEvent("blind", self.owner, {blind_time})
            end
            traitors_blinded = true
        end

        local updated = false
        for _, ply in ipairs(self:GetAlivePlayers()) do
            if ply:GetRole() == ROLE_INNOCENT then
                if GetConVar("randomat_prophunt_strip"):GetBool() then
                    for _, wep in ipairs(ply:GetWeapons()) do
                        local weaponclass = WEPS.GetClass(wep)
                        if weaponclass ~= weaponid then
                            ply:StripWeapon(weaponclass)
                        end
                    end

                    -- Reset FOV to unscope
                    ply:SetFOV(0, 0.2)
                end

                if not ply:HasWeapon(weaponid) then
                    ply:Give(weaponid)
                end
            end

            -- Workaround the case where people can respawn as Zombies while this is running
            updated = updated or self:HandleRoleWeapons(ply)
        end

        -- If anyone's role changed, send the update
        if updated then
            SendFullStateUpdate()
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not GetConVar("randomat_prophunt_strip"):GetBool() then return end
        -- Invalid, dead, spectator, and traitor players can pickup whatever they want
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:GetRole() == ROLE_TRAITOR then
            return
        end
        -- Everyone else can only pick up the assigned weapon
        return IsValid(wep) and WEPS.GetClass(wep) == weaponid
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if is_item == EQUIP_RADAR then
            ply:ChatPrint("Radars are disabled while Prop Hunt is active! Your purchase has been refunded.")
            return false
        end
    end)

    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not IsValid(ent) or not (string.StartWith(ent:GetClass(), "prop_physics") or ent:GetClass() == "prop_dynamic") then return end
        local att = dmginfo:GetAttacker()
        if not IsValid(att) or not att:IsPlayer() then return end

        -- If the thing they attacked is not a disguise then they should take the damage
        -- This property is added by the Prop Disguiser [310403737] (and the Prop Disguiser Improved [2127939503])
        if not ent.IsADisguise then
            att:TakeDamage(dmginfo:GetDamage(), att, att:GetActiveWeapon())
        end
    end)
end

function EVENT:End()
    -- Reset CVars back to normal
    for k, v in pairs(cvar_states) do
        RunConsoleCommand(k, v)
    end

    for _, ply in ipairs(player.GetAll()) do
        timer.Remove(ply:GetName() .. "RandomatPropHuntMessageTimer")
    end

    timer.Remove("RandomatPropHuntTimer")
end

function EVENT:Condition()
    if Randomat:IsEventActive("ragdoll") then return false end

    PopulateWeaponId()
    if util.WeaponForClass(weaponid) == nil then return false end

    -- Only run this if there are actual props
    if table.Count(ents.FindByClass("prop_physics*")) == 0 and table.Count(ents.FindByClass("prop_dynamic")) == 0 then return false end

    -- Only run if there is at least one innocent or jester/swapper living
    for _, v in ipairs(self:GetAlivePlayers()) do
        if (Randomat:IsJesterTeam(v) or Randomat:IsInnocentTeam(v)) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "blind_time", "round_time"}) do
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
    for _, v in ipairs({"strip"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    local textboxes = {}
    for _, v in ipairs({"weaponid"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(textboxes, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks, textboxes
end

Randomat:register(EVENT)