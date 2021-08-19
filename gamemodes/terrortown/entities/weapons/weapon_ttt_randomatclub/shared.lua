AddCSLuaFile()

SWEP.HoldType = "pistol"

if CLIENT then
    SWEP.PrintName = "Club"
    SWEP.Slot = 0

    SWEP.DrawCrosshair = false
    SWEP.ViewModelFlip = false
end

SWEP.Base                   = "weapon_tttbase"

SWEP.AutoSpawnable          = false

SWEP.ViewModel              = Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel             = Model("models/weapons/w_stunbaton.mdl")

SWEP.Primary.Damage         = 50
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay          = 0.5

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 0.1

SWEP.Kind                   = WEAPON_MELEE

SWEP.AllowDelete            = false
SWEP.AllowDrop              = false
SWEP.NoSights               = true

local sound_single = Sound("Weapon_Crowbar.Single")

function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if not IsValid(self:GetOwner()) then return end

    if self:GetOwner().LagCompensation then -- for some reason not always true
        self:GetOwner():LagCompensation(true)
    end

    local spos = self:GetOwner():GetShootPos()
    local sdest = spos + (self:GetOwner():GetAimVector() * 140)
    local kmins = Vector(1,1,1) * -10
    local kmaxs = Vector(1,1,1) * 10

    local tr_main = util.TraceHull({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})
    local hitEnt = tr_main.Entity

    self.Weapon:EmitSound(sound_single)

    if IsValid(hitEnt) or tr_main.HitWorld then
        self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

        if not (CLIENT and (not IsFirstTimePredicted())) then
            local edata = EffectData()
            edata:SetStart(spos)
            edata:SetOrigin(tr_main.HitPos)
            edata:SetNormal(tr_main.Normal)
            edata:SetSurfaceProp(tr_main.SurfaceProps)
            edata:SetHitBox(tr_main.HitBox)
            edata:SetDamageType(DMG_CLUB)
            edata:SetEntity(hitEnt)

            if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
                util.Effect("BloodImpact", edata)

                -- do a bullet just to make blood decals work sanely
                -- need to disable lagcomp because firebullets does its own
                self:GetOwner():LagCompensation(false)
                self:GetOwner():FireBullets({ Num = 1, Src = spos, Dir = self:GetOwner():GetAimVector(), Spread = Vector(0, 0, 0), Tracer = 0, Force = 1, Damage = 0 })
            else
                util.Effect("Impact", edata)
            end
        end
    else
        self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    if SERVER then
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)

        if hitEnt and hitEnt:IsValid() then
            local dmg = DamageInfo()
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self.Weapon)
            dmg:SetDamageForce(self:GetOwner():GetAimVector() * 1500)
            dmg:SetDamagePosition(self:GetOwner():GetPos())
            dmg:SetDamageType(DMG_CLUB)

            hitEnt:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)
        end
    end

    if self:GetOwner().LagCompensation then
        self:GetOwner():LagCompensation(false)
    end
end

function SWEP:GetClass()
end

function SWEP:OnDrop()
end