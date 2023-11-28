local EVENT = {}

local looseclips_keep_ammo = CreateConVar("randomat_looseclips_keep_ammo", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether drained ammo is kept or destroyed")
local looseclips_affectbuymenu = CreateConVar("randomat_looseclips_affectbuymenu", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether buy menu weapons lose ammo too")

EVENT.Title = "Loose Clips"
EVENT.Description = "Sprinting causes your gun clip to fall out, forcing reloads"
EVENT.id = "looseclips"
EVENT.Categories = {"moderateimpact"}

function EVENT:Begin()
    local keep_ammo = looseclips_keep_ammo:GetBool()
    local affects_buy = looseclips_affectbuymenu:GetBool()
    self:AddHook("TTTSpeedMultiplier", function(ply, mults, sprinting)
        if not IsPlayer(ply) or not sprinting then return end

        local active_weapon = ply:GetActiveWeapon()
        if IsValid(active_weapon) and
              -- Only affect weapons that spawn around the map unless buyables is enabled
              (active_weapon.AutoSpawnable or (not active_weapon.CanBuy or affects_buy)) and
              -- Don't affect weapons that don't actually have ammo
              (not active_weapon.Primary or active_weapon.Primary.Ammo ~= "none") then
            local current_clip = active_weapon:Clip1()
            if current_clip > 0 then
                active_weapon:SetClip1(0)

                local message = "Your gun clip fell out"
                -- Give them their ammo back if we're configured to do so
                if keep_ammo then
                    message = message .. ", but you picked it back up"
                    local ammo_type = active_weapon:GetPrimaryAmmoType()
                    ply:GiveAmmo(current_clip, ammo_type, true)
                end

                Randomat:PrintMessage(ply, MSG_PRINTBOTH, message .. "!")
            end
        end
    end)
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"keep_ammo", "affectbuymenu"}) do
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