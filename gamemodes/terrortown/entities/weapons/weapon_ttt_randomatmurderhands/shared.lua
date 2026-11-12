AddCSLuaFile()

DEFINE_BASECLASS "weapon_tttbase"

SWEP.HoldType = "fist"

if CLIENT then
    SWEP.PrintName     = "Hands"
    SWEP.Slot          = 0
    SWEP.DrawCrosshair = true
    SWEP.ViewModelFOV  = 54
    SWEP.ViewModelFlip = false
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/ttt/icon_hands")

    function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
        surface.SetDrawColor(255, 230, 30)
        surface.SetTexture( self.WepSelectIcon )

        local iconW = wide * 0.7
        local iconH = iconW * (7 / 22)

        local iconX = x + (wide - iconW) / 2
        local iconY = y + (tall - iconH) / 3
        surface.DrawTexturedRect(iconX, iconY, iconW, iconH)
    end
end

SWEP.Base = "weapon_tttbase"

SWEP.Kind      = WEAPON_UNARMED
SWEP.AllowDrop = false
SWEP.NoSights  = true
SWEP.IsSilent  = true

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

SWEP.Primary.Ammo        = "none"
SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = true
SWEP.Primary.Delay       = 0.7

SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Delay       = 0.2

local punchDamage = 20

-- Match magneto stick carry settings EXCEPT, to match Murder, always allow ragdoll carrying and never allow weapon carrying
local PIN_RAG_RANGE            = 90
local CARRY_WEIGHT_LIMIT       = 45

SWEP.EntHolding          = nil
SWEP.CarryHack           = nil
SWEP.Constr              = nil
SWEP.PrevOwner           = nil

local player = player
local IsValid = IsValid
local CurTime = CurTime

local function SetSubPhysMotionEnabled(ent, enable)
    if not IsValid(ent) then return end

    for i = 0, ent:GetPhysicsObjectCount() - 1 do
        local subphys = ent:GetPhysicsObjectNum(i)
        if IsValid(subphys) then
            subphys:EnableMotion(enable)
            if enable then
                subphys:Wake()
            end
        end
    end
end

local function KillVelocity(ent)
    ent:SetVelocity(vector_origin)
    SetSubPhysMotionEnabled(ent, false)
    timer.Simple(0, function() SetSubPhysMotionEnabled(ent, true) end)
end

function SWEP:Reset(keep_velocity)
    if IsValid(self.CarryHack) then
        self.CarryHack:Remove()
    end

    if IsValid(self.Constr) then
        self.Constr:Remove()
    end

    if IsValid(self.EntHolding) then
        if not self.EntHolding:IsWeapon() then
            if not IsValid(self.PrevOwner) then
                self.EntHolding:SetOwner(nil)
            else
                self.EntHolding:SetOwner(self.PrevOwner)
            end
        end

        local phys = self.EntHolding:GetPhysicsObject()
        if IsValid(phys) then
            phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
            phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
            phys:EnableCollisions(true)
            phys:EnableGravity(true)
            phys:EnableDrag(true)
            phys:EnableMotion(true)
        end

        if (not keep_velocity) and (GetConVar("ttt_no_prop_throwing"):GetBool() or self.EntHolding:GetClass() == "prop_ragdoll") then
            KillVelocity(self.EntHolding)
        end
    end

    self.dt.carried_rag = nil

    self.EntHolding = nil
    self.CarryHack  = nil
    self.Constr     = nil

    local owner = self:GetOwner()
    if SERVER and IsValid(owner) then
        owner:SetNWBool("RdmtMurderCarrying", false)
    end
end
SWEP.reset = SWEP.Reset

function SWEP:CheckValidity()
    if not IsValid(self.EntHolding) or not IsValid(self.CarryHack) or not IsValid(self.Constr) then
        if self.EntHolding or self.CarryHack or self.Constr then
            self:Reset()
        end

        return false
    else
        return true
    end
end

local function PlayerStandsOn(ent)
    for _, ply in player.Iterator() do
        if ply:GetGroundEntity() == ent and ply:IsTerror() then
            return true
        end
    end

    return false
end

if SERVER then
    local ent_diff = vector_origin
    local ent_diff_time = CurTime()
    local stand_time = 0

    function SWEP:Think()
        BaseClass.Think(self)
        if not self:CheckValidity() then return end

        if CurTime() > ent_diff_time then
            ent_diff = self:GetPos() - self.EntHolding:GetPos()

            if ent_diff:Dot(ent_diff) > 40000 then
                self:Reset()
                return
            end

            ent_diff_time = CurTime() + 1
        end

        if CurTime() > stand_time then
            if PlayerStandsOn(self.EntHolding) then
                self:Reset()
                return
            end

            stand_time = CurTime() + 0.1
        end

        self.CarryHack:SetPos(self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 70)
        self.CarryHack:SetAngles(self:GetOwner():GetAngles())
        self.EntHolding:PhysWake()
    end
end

function SWEP:Deploy()
    local owner = self:GetOwner()

    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if IsValid(owner) then
        local vm = owner:GetViewModel()

        if IsValid(vm) then
            vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
        end
    end

    self:Reset()
    return true
end

-- Pushes players/damages everything else (so Bystanders can break windows to get through)
local anim = "fists_left"

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    -- Don't allow punching if the player is carrying something
    if IsValid(self.EntHolding) or owner:GetNWBool("RdmtMurderCarrying", false) then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if owner.LagCompensation then
        owner:LagCompensation(true)
    end

    -- Alternate between right and left punches
    anim = anim == "fists_left" and "fists_right" or "fists_left"
    local vm = owner:GetViewModel()

    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:ViewPunch(Angle(4, 0, 0))

    local spos  = owner:GetShootPos()
    local sdest = spos + (owner:GetAimVector() * 70)

    local tr = util.TraceHull({
        start  = spos,
        endpos = sdest,
        filter = owner,
        mask   = MASK_SHOT_HULL,
        mins   = Vector(-10, -10, -10),
        maxs   = Vector(10, 10, 10)
    })

    self:EmitSound(Sound("Weapon_Crowbar.Single"))

    if tr.HitWorld or IsValid(tr.Entity) then
        self:SendWeaponAnim(ACT_VM_HITCENTER)

        local hitEnt = tr.Entity
        local hitEntClass = hitEnt:GetClass()

        -- Show impact particles (but not on players, they just get shoved)
        if not IsPlayer(hitEnt) and not (CLIENT and not IsFirstTimePredicted()) then
            local edata = EffectData()
            edata:SetStart(spos)
            edata:SetOrigin(tr.HitPos)
            edata:SetNormal(tr.HitNormal or tr.Normal)
            edata:SetSurfaceProp(tr.SurfaceProps)
            edata:SetHitBox(tr.HitBox)
            edata:SetEntity(hitEnt or NULL)
            util.Effect("Impact", edata)
        end

        if SERVER and IsValid(hitEnt) then
            if IsPlayer(hitEnt) then
                -- Push not damage (taken straight from the crowbar code)
                local pushVelocity = tr.Normal * GetConVar("ttt_crowbar_pushforce"):GetFloat()

                -- Limit the upward force to prevent launching
                pushVelocity.z = math.Clamp(pushVelocity.z, 50, 100)

                hitEnt:SetVelocity(hitEnt:GetVelocity() + pushVelocity)
                hitEnt:EmitSound("Flesh.ImpactHard")

                hitEnt.was_pushed = {att = owner, t = CurTime(), wep = self:GetClass()}
            -- Don't damage dropped knives/guns because that sends them flying
            elseif hitEntClass ~= "weapon_ttt_randomatmurderknife" and hitEntClass ~= "weapon_ttt_randomatmurderrevolver" then
                -- Damage not push
                local dmg = DamageInfo()
                dmg:SetDamage(punchDamage)
                dmg:SetAttacker(owner)
                dmg:SetInflictor(self)
                dmg:SetDamageForce(owner:GetAimVector() * 5000)
                dmg:SetDamagePosition(tr.HitPos)
                dmg:SetDamageType(DMG_CLUB)

                hitEnt:DispatchTraceAttack(dmg, spos, sdest)
            end
        end
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    if owner.LagCompensation then
        owner:LagCompensation(false)
    end
end

function SWEP:GetRange(target)
    if IsValid(target) and target:GetClass() == "prop_ragdoll" then
        return 75
    else
        return 100
    end
end

function SWEP:AllowPickup(target)
    local phys = target:GetPhysicsObject()
    local ply = self:GetOwner()

    return (
        IsValid(phys) and IsValid(ply) and
            (not phys:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)) and
            phys:GetMass() < CARRY_WEIGHT_LIMIT and
            (not PlayerStandsOn(target)) and
            (target.CanPickup ~= false) and
            (not target:IsWeapon())
        )
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    if IsValid(self.EntHolding) then
        self:SendWeaponAnim(ACT_VM_MISSCENTER)

        if self.EntHolding:GetClass() == "prop_ragdoll" then
            self:PinRagdoll()
        end

        self:Drop()
        self:SetNextSecondaryFire(CurTime() + 0.3)
        return
    end

    local ply = self:GetOwner()
    local trace = ply:GetEyeTrace(MASK_SHOT)
    local ent = trace.Entity
    if not IsValid(ent) then return end

    local phys = ent:GetPhysicsObject()

    if not IsValid(phys) or not phys:IsMoveable() or phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
        return
    end

    if CLIENT then return end

    if (ply:EyePos() - trace.HitPos):Length() < self:GetRange(ent) then
        if self:AllowPickup(ent) then
            self:PickUp()
            self:SendWeaponAnim(ACT_VM_HITCENTER)

            local delay = (ent:GetClass() == "prop_ragdoll") and 0.8 or 0.5
            self:SetNextSecondaryFire(CurTime() + delay)
            return
        end
    end
end

function SWEP:PickUp()
    if CLIENT or IsValid(self.EntHolding) then return end

    local ply = self:GetOwner()
    local trace = ply:GetEyeTrace(MASK_SHOT)
    local ent = trace.Entity
    self.EntHolding = ent
    local entphys = ent:GetPhysicsObject()

    if IsValid(ent) and IsValid(entphys) then
        self.CarryHack = ents.Create("prop_physics")
        if IsValid(self.CarryHack) then
            self.CarryHack:SetPos(self.EntHolding:GetPos())
            self.CarryHack:SetModel("models/weapons/w_bugbait.mdl")
            self.CarryHack:SetColor(Color(50, 250, 50, 240))
            self.CarryHack:SetNoDraw(true)
            self.CarryHack:DrawShadow(false)
            self.CarryHack:SetHealth(999)
            self.CarryHack:SetOwner(ply)
            self.CarryHack:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self.CarryHack:SetSolid(SOLID_NONE)
            self.CarryHack:SetAngles(ply:GetAngles())
            self.CarryHack:Spawn()

            if not self.EntHolding:IsWeapon() then
                self.PrevOwner = self.EntHolding:GetOwner()
                self.EntHolding:SetOwner(ply)
            end

            local phys = self.CarryHack:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetMass(200)
                phys:SetDamping(0, 1000)
                phys:EnableGravity(false)
                phys:EnableCollisions(false)
                phys:EnableMotion(false)
                phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            end

            entphys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            local bone = math.Clamp(trace.PhysicsBone, 0, 1)
            local max_force = GetConVar("ttt_prop_carrying_force"):GetInt()

            if ent:GetClass() == "prop_ragdoll" then
                self.dt.carried_rag = ent
                bone = trace.PhysicsBone
                max_force = 0
            else
                self.dt.carried_rag = nil
            end

            self.Constr = constraint.Weld(self.CarryHack, self.EntHolding, 0, bone, max_force, true)
        end
    end

    -- Set the player as carrying something for the movement penalty
    if SERVER and IsValid(ply) then
        ply:SetNWBool("RdmtMurderCarrying", IsValid(self.EntHolding))
    end
end

local down = Vector(0, 0, -1)
function SWEP:AllowEntityDrop()
    local ply = self:GetOwner()
    local ent = self.CarryHack
    if not IsValid(ply) or not IsValid(ent) then return false end

    local ground = ply:GetGroundEntity()
    if ground and (ground:IsWorld() or IsValid(ground)) then return true end

    local diff = (ent:GetPos() - ply:GetShootPos()):GetNormalized()
    return down:Dot(diff) <= 0.75
end

function SWEP:Drop()
    if not self:CheckValidity() then return end
    if not self:AllowEntityDrop() then return end

    if SERVER then
        self.Constr:Remove()
        self.CarryHack:Remove()

        local ent = self.EntHolding
        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:EnableCollisions(true)
            phys:EnableGravity(true)
            phys:EnableDrag(true)
            phys:EnableMotion(true)
            phys:Wake()
            phys:ApplyForceCenter(self:GetOwner():GetAimVector() * 500)

            phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
            phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
        end

        if GetConVar("ttt_no_prop_throwing"):GetBool() or ent:GetClass() == "prop_ragdoll" then
            KillVelocity(ent)
        end

        ent:SetPhysicsAttacker(self:GetOwner())
    end

    self:Reset()
end

local CONSTRAINT_TYPE = "Rope"

local function RagdollPinnedTakeDamage(rag, dmginfo)
    local att = dmginfo:GetAttacker()
    if not IsValid(att) then return end

    constraint.RemoveConstraints(rag, CONSTRAINT_TYPE)
    rag:PhysWake()

    rag:SetHealth(0)
    rag.is_pinned = false
end

function SWEP:PinRagdoll()
    if not GetConVar("ttt_ragdoll_pinning"):GetBool() then return end
    if not self:GetOwner():IsTraitor() and not GetConVar("ttt_ragdoll_pinning_innocents"):GetBool() then return end

    local rag = self.EntHolding
    local ply = self:GetOwner()

    local tr = util.TraceLine({
        start  = ply:EyePos(),
        endpos = ply:EyePos() + (ply:GetAimVector() * PIN_RAG_RANGE),
        filter = {ply, self, rag, self.CarryHack},
        mask   = MASK_SOLID
    })

    if tr.HitWorld and (not tr.HitSky) then
        local bone = self.Constr.Bone2

        for _, c in pairs(constraint.FindConstraints(rag, CONSTRAINT_TYPE)) do
            if c.Bone1 == bone then
                c.Constraint:Remove()
            end
        end

        local bonephys = rag:GetPhysicsObjectNum(bone)
        if not IsValid(bonephys) then return end

        local bonepos = bonephys:GetPos()
        local attachpos = tr.HitPos
        local length = (bonepos - attachpos):Length() * 0.9

        bonepos = bonephys:WorldToLocal(bonepos)

        constraint.Rope(rag, tr.Entity, bone, 0, bonepos, attachpos,
                        length, length * 0.1, 6000,
                        1, "cable/rope", false)

        rag.is_pinned = true
        rag.OnPinnedDamage = RagdollPinnedTakeDamage
        rag:SetHealth(999999)

        self:Reset(true)
    end
end

function SWEP:SetupDataTables()
    self:DTVar("Bool", 0, "can_rag_pin")
    self:DTVar("Bool", 1, "can_rag_pin_inno")
    self:DTVar("Entity", 0, "carried_rag")
    return self.BaseClass.SetupDataTables(self)
end

if SERVER then
    function SWEP:Initialize()
        self.dt.can_rag_pin = GetConVar("ttt_ragdoll_pinning"):GetBool()
        self.dt.can_rag_pin_inno = GetConVar("ttt_ragdoll_pinning_innocents"):GetBool()
        self.dt.carried_rag = nil

        return self.BaseClass.Initialize(self)
    end
end

function SWEP:OnRemove()
    self:Reset()
end

function SWEP:Deploy()
    self:Reset()
    return true
end

function SWEP:Holster()
    self:Reset()
    return true
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:OnDrop()
    self:Remove()
end

function SWEP:Reload()
    return false
end

if CLIENT then
    local draw = draw
    local util = util

    local PT = LANG.GetParamTranslation
    local key_params = {primaryfire = Key("+attack2", "RIGHT MOUSE")}
    function SWEP:DrawHUD()
        self.BaseClass.DrawHUD(self)

        if GetConVar("ttt_ragdoll_pinning"):GetBool() and IsValid(self.dt.carried_rag) then
            local client = LocalPlayer()

            if not client:IsSpec() then
                local tr = util.TraceLine({
                    start  = client:EyePos(),
                    endpos = client:EyePos() + (client:GetAimVector() * PIN_RAG_RANGE),
                    filter = {client, self, self.dt.carried_rag},
                    mask   = MASK_SOLID
                })

                if tr.HitWorld and (not tr.HitSky) then
                    draw.SimpleText(PT("magnet_help", key_params), "TabLarge", ScrW() / 2, ScrH() / 2 - 50, COLOR_RED, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
end