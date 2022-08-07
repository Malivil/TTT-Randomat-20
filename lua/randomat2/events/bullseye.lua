local EVENT = {}

EVENT.Title = "Bullseye"
EVENT.Description = "Only headshots do damage"
EVENT.id = "bullseye"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

local function WasHeadHit(ply, hitgroup)
    if hitgroup == HITGROUP_HEAD then return true end

    -- If the player wasn't hit in the head, search all the hitboxes to see if any of them belong to the head hitgroup
    local hitbox_count = ply:GetHitBoxCount(0)
    for i = 0, hitbox_count - 1 do
        local box = ply:GetHitBoxHitGroup(i, 0)
        -- If they have a head hitgroup then we know for sure they weren't hit in the head
        if box == HITGROUP_HEAD then
            return false
        end
    end

    -- If they don't have a head hitgroup then any shot will count so they still take damage
    return true
end

function EVENT:Begin()
    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        -- Let the barnacle still do the damage or else people can just get stuck in there
        if IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "npc_barnacle" then return end
        -- If they hit the head then let it do normal damage
        if WasHeadHit(ply, hitgroup) then return end

        dmginfo:ScaleDamage(0)
    end)
end

function EVENT:Condition()
    return not ConVarExists("ttt_disable_headshots") or not GetConVar("ttt_disable_headshots"):GetBool()
end

Randomat:register(EVENT)