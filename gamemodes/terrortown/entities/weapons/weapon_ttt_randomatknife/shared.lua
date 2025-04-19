AddCSLuaFile()

CreateConVar("randomat_murder_knifedmg", 50, FCVAR_NONE, "Damage of the traitor's knife", 10, 200)

SWEP.HoldType               = "knife"

if CLIENT then
    SWEP.PrintName           = "knife_name"
    SWEP.Slot                = 0

    SWEP.ViewModelFlip       = false
    SWEP.ViewModelFOV        = 54
    SWEP.DrawCrosshair       = false

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "knife_desc"
    }

    SWEP.Icon                = "vgui/ttt/icon_knife"
    SWEP.IconLetter          = "j"
end

SWEP.Base                   = "weapon_tttbase"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel             = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage         = GetConVar("randomat_murder_knifedmg"):GetInt()
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 1.1
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 1.4

SWEP.Kind                   = WEAPON_MELEE
SWEP.LimitedStock           = true -- only buyable once
SWEP.WeaponID               = AMMO_KNIFE

SWEP.IsSilent               = true

-- Pull out faster than standard guns
SWEP.DeploySpeed            = 2
SWEP.AllowDrop              = false

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    if not IsValid(self:GetOwner()) then return end

    self:GetOwner():LagCompensation(true)

    local spos = self:GetOwner():GetShootPos()
    local sdest = spos + (self:GetOwner():GetAimVector() * 70)

    local kmins = Vector(1,1,1) * -10
    local kmaxs = Vector(1,1,1) * 10

    local tr = util.TraceHull({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

    -- Hull might hit environment stuff that line does not hit
    if not IsValid(tr.Entity) then
        tr = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
    end

    local hitEnt = tr.Entity

    -- effects
    if IsValid(hitEnt) then
        self:SendWeaponAnim(ACT_VM_HITCENTER)

        local edata = EffectData()
        edata:SetStart(spos)
        edata:SetOrigin(tr.HitPos)
        edata:SetNormal(tr.Normal)
        edata:SetEntity(hitEnt)

        if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
            util.Effect("BloodImpact", edata)
        end
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    if SERVER then
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)

        if tr.Hit and tr.HitNonWorld and IsPlayer(hitEnt) then
            local dmg = DamageInfo()
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamageForce(self:GetOwner():GetAimVector() * 5)
            dmg:SetDamagePosition(self:GetOwner():GetPos())
            dmg:SetDamageType(DMG_SLASH)

            hitEnt:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)
        end
    end

   self:GetOwner():LagCompensation(false)
end

function SWEP:OnDrop()
    self:Remove()
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Equip()
    self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay * 1.5))
    self:SetNextSecondaryFire(CurTime() + (self.Secondary.Delay * 1.5))
end

function SWEP:OnRemove()
    if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
        RunConsoleCommand("lastinv")
    end
end