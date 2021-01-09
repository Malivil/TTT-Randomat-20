AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()
	self.Entity:SetModel("models/items/item_item_crate.mdl")
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetModelScale(1)
    self.Entity:SetHealth(250)
    if SERVER then
        self.Entity:PrecacheGibs()
    end

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:OnRemove()
end

function ENT:Think()
end

function ENT:OnTakeDamage(dmgInfo)
    self.Entity:SetHealth(self.Entity:Health() - dmgInfo:GetDamage())
    if self.Entity:Health() <= 0 then
        self.Entity:GibBreakServer(Vector(1, 1, 1))
        self.Entity:Remove()
    end
    return true
end

function ENT:CallHooks(isequip, id, ply)
    hook.Call("TTTOrderedEquipment", GAMEMODE, ply, id, isequip)
    net.Start("TTT_BoughtItem")
    net.WriteBit(isequip)
    if isequip then
        net.WriteInt(id, 16)
    else
        net.WriteString(id)
    end
    net.Send(ply)

    if SERVER then
        Randomat:LogEvent("[RANDOMAT] " .. ply:Nick() .. " picked up the Care Package")
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:Alive() or activator:IsSpec() then return end

    local blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_package_blocklist"):GetString(), '([^,]+)') do
        table.insert(blocklist, blocked_id:Trim())
    end

    Randomat:GiveRandomShopItem(activator, {ROLE_TRAITOR,ROLE_ASSASSIN,ROLE_HYPNOTIST,ROLE_DETECTIVE,ROLE_MERCENARY}, blocklist, false,
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
            self:CallHooks(isequip, id, activator)
        end)

	self:Remove()
end

function ENT:Break()
end
