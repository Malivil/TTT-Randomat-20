AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Revolver"
    SWEP.Slot = 0
    SWEP.Icon = "vgui/ttt/icon_revolver"
    SWEP.IconLetter = "f"
end

SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "pistol"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 4.5
SWEP.Primary.Recoil = 0.8
SWEP.Primary.Cone = 0.0325
SWEP.Primary.Damage = 1000
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Sound = "Weapon_357.Single"

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.ViewModel = Model("models/weapons/c_357.mdl")
SWEP.WorldModel = Model("models/weapons/w_357.mdl")

SWEP.IronSightsPos = Vector (-4.64, -3.96, 0.68)
SWEP.IronSightsAng = Vector (0.214, -0.1767, 0)

SWEP.Kind = WEAPON_MELEE
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = "none"
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.ForceReload = true

function SWEP:PrimaryAttack(worldsnd)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if not worldsnd then
        self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
    elseif SERVER then
        sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
    end

    self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())

    local owner = self:GetOwner()
    if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

    owner:ViewPunch(Angle(util.SharedRandom(self:GetClass(), -0.2, -0.1, 0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(),  -0.1, 0.1, 1) * self.Primary.Recoil, 0))

    if not self.ForceReload then return end
    timer.Create("RandomatRevolverReload_" .. self:EntIndex(), 0.5, 1, function()
        if IsPlayer(owner) and owner:GetActiveWeapon().ClassName == "weapon_ttt_randomatrevolver" then
            owner:GetViewModel():SetPlaybackRate(0.5)
        end
        self:SendWeaponAnim(self.ReloadAnim)
        self:SetIronsights(false)
    end)
end