local EVENT = {}

EVENT.Title = "Chamber Pop"
EVENT.Description = "Weapons explode if you try to fire them while empty"
EVENT.id = "chamberpop"
EVENT.Categories = {"moderateimpact"}

local chamberpop_explosion_magnitude = CreateConVar("randomat_chamberpop_explosion_magnitude", 150, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Weapon explosion magnitude", 50, 250)

function EVENT:SetupWeapon(ply, weap, magnitude)
    if weap.OldDryFire then return end

    print("Rig", ply, weap, magnitude)

    weap.OldDryFire = weap.DryFire
    weap.DryFire = function(w, setnext)
        print("Dry fire")
        w:OldDryFire(setnext)

        local explode = ents.Create("env_explosion")
        explode:SetPos(ply:GetPos())
        explode:SetOwner(ply)
        explode:Spawn()
        explode:SetKeyValue("iMagnitude", magnitude)
        explode:Fire("Explode", 0,0)
        explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
    end
end

function EVENT:ResetWeapon(weap)
    if not weap.OldDryFire then return end
    weap.DryFire = weap.OldDryFire
    weap.OldDryFire = nil
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