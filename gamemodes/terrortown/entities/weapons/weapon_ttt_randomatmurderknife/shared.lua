AddCSLuaFile()

SWEP.HoldType = "knife"

if CLIENT then
    SWEP.PrintName     = "Knife"
    SWEP.Slot          = 1
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV  = 54
    SWEP.DrawCrosshair = false
    SWEP.IconLetter    = "j"

    surface.CreateFont("Rdmt_Murder_KnifeIcon", {
        font      = "cs",
        size      = math.ceil(ScrH() / 15) * 2,
        weight    = 0,
        antialias = true,
        additive  = true
    })

    function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
        -- Draw weapon icon
        local boxCentreX = x + wide / 2
        local boxCentreY = y + tall * 0.4
        draw.SimpleText(self.IconLetter, "Rdmt_Murder_KnifeIcon", boxCentreX, boxCentreY, Color(255, 230, 30), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

SWEP.Base = "weapon_tttbase"

SWEP.UseHands   = true
SWEP.ViewModel  = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage      = 1000
SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = true
SWEP.Primary.Delay       = 0.5
SWEP.Primary.Ammo        = "none"
SWEP.Primary.Force       = 900

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.Kind        = WEAPON_MELEE
SWEP.IsSilent    = false
SWEP.AllowDrop   = false
SWEP.DeploySpeed = 2

function SWEP:SetupDataTables()
    self.BaseClass.SetupDataTables(self)
    self:NetworkVar("Float", "ChargeStart")
end

-- Make charge bar go up and down
function SWEP:GetCharge()
    local heldTime = CurTime() - self:GetChargeStart()
    return math.Clamp((math.sin(heldTime * 2 - 1) + 1) / 2, 0, 1)
end

function SWEP:PrimaryAttack()
    if SERVER and self:GetChargeStart() ~= 0 then
        self:SetChargeStart(0)
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if self:GetChargeStart() ~= 0 then return end

    owner:LagCompensation(true)

    local spos  = owner:GetShootPos()
    local sdest = spos + (owner:GetAimVector() * 70)

    local tr = util.TraceLine({start = spos, endpos = sdest, filter = owner, mask = MASK_SHOT_HULL})

    local hit_ent = tr.Entity

    if IsValid(hit_ent) then
        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

        local edata = EffectData()
        edata:SetStart(spos)
        edata:SetOrigin(tr.HitPos)
        edata:SetNormal(tr.Normal)
        edata:SetEntity(hit_ent)

        if hit_ent:IsPlayer() or hit_ent:GetClass() == "prop_ragdoll" then
            util.Effect("BloodImpact", edata)
        end
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    if SERVER then
        owner:SetAnimation(PLAYER_ATTACK1)

        if tr.Hit and tr.HitNonWorld and IsPlayer(hit_ent) then
            local dmg = DamageInfo()
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetAttacker(owner)
            dmg:SetInflictor(self)
            dmg:SetDamageForce(owner:GetAimVector() * self.Primary.Force)
            dmg:SetDamagePosition(owner:GetPos())
            dmg:SetDamageType(DMG_SLASH)

            hit_ent:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
        end
    end

    owner:LagCompensation(false)
end

-- Start charging knife throw
function SWEP:SecondaryAttack()
    if self:GetChargeStart() ~= 0 then return end

    if SERVER then
        self:SetChargeStart(CurTime())
    end
end

function SWEP:Think()
    if CLIENT or self:GetChargeStart() == 0 then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then
        self:SetChargeStart(0)
        return
    end

    if not owner:KeyDown(IN_ATTACK2) then
        self:ThrowKnife(self:GetCharge())
    end
end

function SWEP:Holster()
    if SERVER then self:SetChargeStart(0) end

    return true
end

if SERVER then
    function SWEP:ThrowKnife(charge)
        local owner = self:GetOwner()
        self:SetChargeStart(0)

        local knifeProjectile = ents.Create("ttt_randomat_murderknife")
        if not IsValid(knifeProjectile) then return end

        knifeProjectile:SetPos(owner:GetShootPos())
        local angle = Angle(-28, 0, 0) + owner:EyeAngles()
        angle:RotateAroundAxis(angle:Right(), -90)
        knifeProjectile:SetAngles(angle)
        knifeProjectile:SetOwner(owner)
        knifeProjectile:Spawn()

        knifeProjectile.rdmtMurderKnife = true

        local physObj = knifeProjectile:GetPhysicsObject()
        if not IsValid(physObj) then
            knifeProjectile:Remove()
            return
        end

        physObj:SetVelocity(owner:GetAimVector() * (charge * 1000 + 200))
        physObj:AddAngleVelocity(Vector(0, 1500, 0))

        -- Switch back to hands
        timer.Simple(0, function()
            if IsValid(owner) and owner:Alive() then
                owner:SelectWeapon("weapon_ttt_randomatmurderhands")
            end
        end)

        self:Remove()
    end
end

if CLIENT then
    local scrW = ScrW()
    local scrH = ScrH()

    -- Charge bar while holding right click
    function SWEP:DrawHUD()
        if self:GetChargeStart() == 0 then return end

        local w, h = math.Round(scrW * 0.2), 40
        local x, y = scrW / 2 - w / 2, scrH / 2 - h / 2 + 120

        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(x, y, w, h)
        surface.SetDrawColor(255, 0, 0, 150)
        surface.DrawRect(x, y, w * self:GetCharge(), h)
    end
end

function SWEP:OnDrop()
    self:Remove()
end
