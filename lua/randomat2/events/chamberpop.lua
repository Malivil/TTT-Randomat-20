local EVENT = {}

EVENT.Title = "Chamber Pop"
EVENT.Description = "Weapons explode if you try to fire them while empty"
EVENT.id = "chamberpop"
EVENT.Categories = {"moderateimpact"}

local chamberpop_explosion_magnitude = CreateConVar("randomat_chamberpop_explosion_magnitude", 150, FCVAR_ARCHIVE, "Weapon explosion magnitude", 50, 250)

local function CheckAndPop(ply, weap, magnitude, can_fire, ammoTbl, ammoFn)
    -- If we can't use the attack and we COULD have ammo but we don't... then just assume we're dry firing
    -- This is necessary (as opposed to just overriding DryFire) because some custom weapons use a base mod that doens't use DryFire for... dry... firing
    if not can_fire and not weap.RdmtChamberPopped and ammoTbl and ammoTbl.ClipSize > 0 and ammoFn(weap) == 0 then
        weap.RdmtChamberPopped = true

        local explode = ents.Create("env_explosion")
        explode:SetPos(ply:GetPos())
        explode:SetOwner(ply)
        explode:Spawn()
        explode:SetKeyValue("iMagnitude", magnitude)
        explode:Fire("Explode", 0,0)
        explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
    end
end

function EVENT:SetupWeapon(ply, weap, magnitude)
    if not weap.OldCanPrimaryAttack and weap.CanPrimaryAttack then
        weap.OldCanPrimaryAttack = weap.CanPrimaryAttack
        weap.CanPrimaryAttack = function(w)
            local can_primary = w:OldCanPrimaryAttack()
            CheckAndPop(ply, w, magnitude, can_primary, w.Primary, w.Clip1)
            return can_primary
        end
    end

    if not weap.OldCanSecondaryAttack and weap.CanSecondaryAttack then
        weap.OldCanSecondaryAttack = weap.CanSecondaryAttack
        weap.CanSecondaryAttack = function(w)
            local can_secondary = w:OldCanSecondaryAttack()
            CheckAndPop(ply, w, magnitude, can_secondary, w.Secondary, w.Clip2)
            return can_secondary
        end
    end
end

function EVENT:ResetWeapon(weap)
    if weap.OldCanPrimaryAttack then
        weap.CanPrimaryAttack = weap.OldCanPrimaryAttack
        weap.OldCanPrimaryAttack = nil
    end

    if weap.OldCanSecondaryAttack then
        weap.CanSecondaryAttack = weap.OldCanSecondaryAttack
        weap.OldCanSecondaryAttack = nil
    end
end

-- Only rig primary weapons and pistols
function EVENT:IsValidWeapon(weap)
    return IsValid(weap) and (weap.Kind == WEAPON_HEAVY or weap.Kind == WEAPON_PISTOL)
end

function EVENT:Begin()
    local magnitude = chamberpop_explosion_magnitude:GetString()

    -- Rig all of the curretly-held weapons
    for _, p in ipairs(self:GetAlivePlayers()) do
        for _, w in ipairs(p:GetWeapons()) do
            if self:IsValidWeapon(w) then
                self:SetupWeapon(p, w, magnitude)
            end
        end
    end

    -- Rig when picking up weapon
    self:AddHook("WeaponEquip", function(weap, ply)
        if not self:IsValidWeapon(weap) or not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        self:SetupWeapon(ply, weap, magnitude)
    end)

    -- Un-rig when dropping weapon
    self:AddHook("PlayerDroppedWeapon", function(ply, weap)
        if not self:IsValidWeapon(weap) or not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        self:ResetWeapon(ply, weap, magnitude)
    end)
end

function EVENT:End()
    -- Reset all of the curretly-held weapons
    for _, p in ipairs(self:GetAlivePlayers()) do
        for _, w in ipairs(p:GetWeapons()) do
            if self:IsValidWeapon(w) then
                self:ResetWeapon(w)
            end
        end
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"explosion_magnitude"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)