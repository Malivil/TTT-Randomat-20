local EVENT = {}

util.AddNetworkString("RdmtVarietyBegin")
util.AddNetworkString("RdmtVarietyTypeSet")
util.AddNetworkString("RdmtVarietyEnd")

EVENT.Title = "Variety is the Spice of Life"
EVENT.Description = "Prevents players from killing using the same type of damage (bullets, crowbar, etc.) twice in a row"
EVENT.id = "variety"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"largeimpact"}

local damageTypes = {
    ["Fire"] = DMG_BURN,
    ["Explosion"] = DMG_BLAST,
    ["Falling"] = DMG_FALL,
    ["Blunt (Crowbar)"] = DMG_CLUB,
    ["Crush (Prop)"] = DMG_CRUSH,
    ["Bullet"] = DMG_BULLET,
    ["Slash (Knife)"] = DMG_SLASH
}
local function GetDamageType(dmginfo)
    -- Do it this way to isolate specific damage types
    -- Using "GetDamageType" gives back a flag that can be made up of multiple enum values (multiple damage types)
    for name, damageType in pairs(damageTypes) do
        if dmginfo:IsDamageType(damageType) then
            return damageType, name
        end
    end

    -- "Generic" damage is a special case
    if dmginfo:GetDamageType() == 0 then
        return DMG_GENERIC, "Generic"
    end
    return nil, nil
end

function EVENT:Begin()
    net.Start("RdmtVarietyBegin")
    net.Broadcast()

    -- Track the last type of damage used to kill a player
    local lastKillDamage = {}
    self:AddHook("DoPlayerDeath", function(victim, attacker, dmginfo)
        if not IsPlayer(victim) then return end
        if not IsPlayer(attacker) then return end

        local sid64 = attacker:SteamID64()
        local damageType, damageTypeName = GetDamageType(dmginfo)
        if not damageType then return end

        lastKillDamage[sid64] = damageType

        net.Start("RdmtVarietyTypeSet")
        net.WriteString(damageTypeName)
        net.Send(attacker)
    end)

    -- Don't let any player use the same damage type to kill twice in a row
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not IsPlayer(ent) then return end

        local att = dmginfo:GetAttacker()
        if not IsPlayer(att) then return end

        local sid64 = att:SteamID64()
        if not lastKillDamage[sid64] then return end

        if dmginfo:IsDamageType(lastKillDamage[sid64]) then
            dmginfo:ScaleDamage(0)
            dmginfo:SetDamage(0)
        end
    end)
end

function EVENT:End()
    net.Start("RdmtVarietyEnd")
    net.Broadcast()
end

Randomat:register(EVENT)