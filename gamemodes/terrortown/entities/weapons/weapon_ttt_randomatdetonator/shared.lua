if CLIENT then
    SWEP.PrintName = "Detonator"
    SWEP.Slot = 7

    SWEP.ViewModelFOV = 60
end

SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.Weight = 2

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AutoSpawnable = false
SWEP.HoldType = "slam"
SWEP.AdminSpawnable = true
SWEP.Kind = WEAPON_EQUIP2
SWEP.Target = nil

SWEP.AllowDrop = false
SWEP.NoSights = true
SWEP.UseHands = true
SWEP.LimitedStock = true
SWEP.AmmoEnt = nil

SWEP.Primary.Delay = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Cone = 0
SWEP.Primary.Ammo = nil
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Sound = ""

function SWEP:Initialize()
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
end

function SWEP:Equip()
    if not self.Target or not IsValid(self.Target) then return end
    self:GetOwner():PrintMessage(HUD_PRINTTALK, "You have recieved the detonator for " .. self.Target:Nick())
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
    return true
end

local function DetonatePlayer(owner, ply)
    if not Randomat:ShouldActLikeJester(owner) then
        local pos = nil
        if ply:Alive() then
            pos = ply:GetPos()
        else
            local body = ply.server_ragdoll or ply:GetRagdollEntity()
            if IsValid(body) then
                pos = body:GetPos()
                body:Remove()
            end
        end

        if pos ~= nil then
            local explode = ents.Create("env_explosion")
            explode:SetPos(pos)
            explode:SetOwner(owner)
            explode:Spawn()
            explode:SetKeyValue("iMagnitude", "230")
            explode:Fire("Explode", 0,0)
            explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
        end
    end
    for _, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, owner:Nick().." has detonated "..ply:Nick())
    end
end

function SWEP:PrimaryAttack()
    if SERVER then
        DetonatePlayer(self:GetOwner(), self.Target)
        self:Remove()
    end
end