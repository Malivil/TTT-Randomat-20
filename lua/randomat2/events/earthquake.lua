local EVENT = {}

CreateConVar("randomat_earthquake_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of maps to not allow this map on")

EVENT.Title = "Earthquake"
EVENT.ExtDescription = "Shakes all props, weapons, and ammo on the map"
EVENT.id = "earthquake"
EVENT.SingleUse = false
EVENT.Categories = {"fun", "smallimpact"}

function EVENT:Begin()
    local magnitude = math.random(1, 10)
    self.Description = "Magnitude " .. magnitude .. "!"

    -- Shake the screen aroudn the owner's location in case there are really big maps with a lot of empty space
    util.ScreenShake(self.owner:GetPos(), magnitude, 5, 2 * magnitude, 5000)
    timer.Create("RdmtEarthquake", 0.25, 5 * magnitude, function ()
        for _, ent in ipairs(ents.GetAll()) do
            local class = ent:GetClass()
            if (string.StartWith(class, "prop_physics") or class == "prop_dynamic" or
                string.StartWith(class, "item_ammo_") or string.StartWith(class, "item_box_") or
                type(ent) == "Weapon") and not IsValid(ent:GetParent()) then
                ent:PhysWake()
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    local push = Vector(math.random(-150, 150), math.random(-150, 150), math.random(-150, 150))
                    phys:SetVelocity(phys:GetVelocity() + push)
                end
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtEarthquake")
end

function EVENT:Condition()
    local blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_earthquake_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    -- Don't start this event on maps that are on the blocklist
    return not table.HasValue(blocklist, game.GetMap())
end

Randomat:register(EVENT)