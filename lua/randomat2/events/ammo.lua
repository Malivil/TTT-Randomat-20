local EVENT = {}

EVENT.Title = "Infinite Ammo!"
EVENT.ExtDescription = "Changes all weapons to have infinite ammo and not require reloading"
EVENT.id = "ammo"
-- Mark this as a weapon override type because the weapons used in weapon override types don't have ammo
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"moderateimpact"}

CreateConVar("randomat_ammo_affectbuymenu", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether it gives buy menu weapons infinite ammo too.")

function EVENT:Begin()
    local affects_buy = GetConVar("randomat_ammo_affectbuymenu"):GetBool()
    self:AddHook("Think", function()
        for _, v in ipairs(self:GetAlivePlayers()) do
            local active_weapon = v:GetActiveWeapon()
            if IsValid(active_weapon) and (active_weapon.AutoSpawnable or (not active_weapon.CanBuy or affects_buy)) then
                active_weapon:SetClip1(active_weapon.Primary.ClipSize)
            end
        end
    end)
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"affectbuymenu"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return {}, checks
end

Randomat:register(EVENT)