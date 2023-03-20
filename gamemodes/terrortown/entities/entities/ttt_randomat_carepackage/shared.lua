AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()
    self:SetModel("models/items/item_item_crate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetModelScale(1)
    self:SetHealth(250)
    if SERVER then
        self:PrecacheGibs()
    end

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    if CLIENT then
        local GetPTranslation = LANG.GetParamTranslation
        LANG.AddToLanguage("english", "rdmt_carepackage_name", "Care Package")
        LANG.AddToLanguage("english", "rdmt_carepackage_hint", "Press '{usekey}' to receive item")
        self.TargetIDHint = function()
            return {
                name = "rdmt_carepackage_name",
                hint = "rdmt_carepackage_hint",
                fmt  = function(ent, txt)
                    return GetPTranslation(txt, { usekey = Key("+use", "USE") } )
                end
            };
        end
    end
end

function ENT:OnRemove()
end

function ENT:Think()
end

function ENT:OnTakeDamage(dmgInfo)
    self:SetHealth(self:Health() - dmgInfo:GetDamage())
    if self:Health() <= 0 then
        self:GibBreakServer(Vector(1, 1, 1))
        self:Remove()
    end
    return true
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:Alive() or activator:IsSpec() then return end

    local blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_package_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    Randomat:GiveRandomShopItem(activator, Randomat:GetShopRoles(), blocklist, false,
        -- gettrackingvar
        function()
            return activator.packageweptries
        end,
        -- settrackingvar
        function(value)
            activator.packageweptries = value
        end,
        -- onitemgiven
        function(isequip, id)
            Randomat:CallShopHooks(isequip, id, activator)
            if SERVER then
                Randomat:LogEvent("[RANDOMAT] " .. activator:Nick() .. " picked up the Care Package")
            end
        end)

    self:Remove()
end

function ENT:Break()
end
