local EVENT = {}

CreateConVar("randomat_package_blocklist", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The comma-separated list of weapon IDs to not give out")

EVENT.Title = "Care Package"
EVENT.Description = "Spawns an ammo crate somewhere in the map that contains a free shop item"
EVENT.id = "package"
EVENT.SingleUse = false
EVENT.Categories = {"fun", "entityspawn", "smallimpact"}

function EVENT:Begin()
    local all_entities = ents.GetAll()
    local spawns = {}
    for _, e in ipairs(all_entities) do
        local entity_class = e:GetClass()
        if (string.StartWith(entity_class, "info_") or string.StartWith(entity_class, "weapon_") or string.StartWith(entity_class, "item_")) and not IsValid(e:GetParent()) then
            table.insert(spawns, e)
        end
    end
    local random_spawn = table.Random(spawns)
    local pos = random_spawn:GetPos()

    local ent = ents.Create("ttt_randomat_carepackage")
    ent:SetPos(pos + Vector(0, 5, 0))
    ent:Spawn()
end

Randomat:register(EVENT)