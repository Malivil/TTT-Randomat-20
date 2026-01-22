local string = string

local StringStartsWith = string.StartsWith

local EVENT = {}

EVENT.Title = "Cause of Death"
EVENT.Description = "Display a player's cause of death on screen for everyone"
EVENT.id = "causeofdeath"
EVENT.Type = EVENT_TYPE_TRANSLATED_WEAPONS
EVENT.Categories = {"biased_innocent", "moderateimpact"}

local function TriggerAlert(item, ply, victim_name)
    --Event handler located in cl_networkstrings
    net.Start("alerteventtrigger")
    net.WriteString(EVENT.id)
    net.WriteString(item)
    -- Repurpose this string as the player's name
    net.WriteString(victim_name)
    -- We only care about weapons so always send 0 for the is_item
    net.WriteUInt(0, 32)
    net.WriteInt(ply:GetRole(), 16)
    net.Send(ply)
end

function EVENT:Begin()
    self:AddHook("DoPlayerDeath", function(victim, attacker, dmginfo)
        local inflictor = dmginfo:GetInflictor()
        if victim.DiedByWater then
            self:SmallNotify(victim:Nick() .. " drowned!")
            return
        elseif attacker == victim then
            self:SmallNotify(victim:Nick() .. " killed themselves!")
            return
        elseif inflictor ~= NULL then
            if IsPlayer(victim) and (StringStartsWith(inflictor:GetClass(), "prop_physics") or inflictor:GetClass() == "prop_dynamic") then
                self:SmallNotify(victim:Nick() .. " was killed by a prop!")
            elseif attacker then
                if inflictor:GetClass() == "entityflame" or inflictor:GetClass() == "env_fire" then
                    self:SmallNotify(victim:Nick() .. " burned to death!")
                elseif inflictor:GetClass() == "worldspawn" and attacker:GetClass() == "worldspawn" then
                    self:SmallNotify(victim:Nick() .. " fell to their death!")
                elseif IsPlayer(attacker) and victim ~= attacker then
                    local weapon = util.WeaponFromDamage(dmginfo)
	                if weapon then
                        TriggerAlert(WEPS.GetClass(weapon), attacker, victim:Nick())
                    else
                        self:SmallNotify(victim:Nick() .. " was killed by another player!")
                    end
                end
            end
            return
        end

        self:SmallNotify(victim:Nick() .. " died... somehow?")
    end)

    --Event started in cl_networkstrings
    net.Receive("AlertTriggerFinal", function()
        local event = net.ReadString()
        if event ~= EVENT.id then return end

        local name = self:RenameWeps(net.ReadString())
        local nick = net.ReadString()

        self:SmallNotify(nick .. " was killed by another player with the following weapon: " .. name)
    end)
end

Randomat:register(EVENT)