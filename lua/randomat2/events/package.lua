local EVENT = {}

CreateConVar("randomat_package_blocklist", "", FCVAR_NONE, "The comma-separated list of weapon IDs to not give out")

EVENT.Title = "Care Package"
EVENT.Description = "Spawns an ammo crate somewhere in the map that contains a free shop item"
EVENT.id = "package"
EVENT.SingleUse = false
EVENT.Categories = {"entityspawn", "smallimpact"}
EVENT.ConVars = {"randomat_package_blocklist"}

function EVENT:Begin()
    local spawns = {}
    for _, e in ents.Iterator() do
        local entity_class = e:GetClass()
        if (string.StartsWith(entity_class, "info_") or string.StartsWith(entity_class, "weapon_") or string.StartsWith(entity_class, "item_")) and not IsValid(e:GetParent()) then
            table.insert(spawns, e)
        end
    end
    local random_spawn = spawns[math.random(#spawns)]
    local pos = random_spawn:GetPos()

    local ent = ents.Create("ttt_randomat_carepackage")
    ent:SetPos(pos + Vector(0, 5, 0))
    ent:Spawn()
end

Randomat:register(EVENT)