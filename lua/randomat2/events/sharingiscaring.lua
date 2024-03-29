local EVENT = {}

EVENT.Title = "Sharing is Caring"
EVENT.Description = "When a player kills another, their inventory is swapped with their victim's"
EVENT.id = "sharingiscaring"
EVENT.Categories = {"biased_innocent", "biased", "deathtrigger", "largeimpact"}

function EVENT:Begin()
    self:AddHook("DoPlayerDeath", function(victim, attacker, dmginfo)
        if not IsPlayer(victim) then return end
        if not IsPlayer(attacker) then return end

        -- Get the list of the victim's weapons and then strip them so they don't get dropped
        local weps = victim:GetWeapons()

        victim:StripWeapons()
        -- Give the victim's weapons to the killer
        self:SwapWeapons(attacker, weps)
    end)
end

Randomat:register(EVENT)