local EVENT = {}

local reload_wait_time = CreateConVar("randomat_reload_wait_time", 5, FCVAR_NONE, "Seconds after last shot before draining", 0.5, 10)
local reload_drain_time = CreateConVar("randomat_reload_drain_time", 2, FCVAR_NONE, "Seconds between each ammo drain", 0.5, 10)
local reload_keep_ammo = CreateConVar("randomat_reload_keep_ammo", 1, FCVAR_NONE, "Whether drained ammo is kept or destroyed")
local reload_affectbuymenu = CreateConVar("randomat_reload_affectbuymenu", 0, FCVAR_NONE, "Whether buy menu weapons lose ammo too")

EVENT.Title = "Compulsive Reloading"
EVENT.Description = "Slowly drains a user's ammo over time if they haven't fired a gun recently"
EVENT.id = "reload"
-- Mark this as a weapon override type because the weapons used in weapon override types aren't reloadable
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"moderateimpact"}

local playerlastshottime = {}
local playerlastdraintime = {}
local playerdraining = {}

function EVENT:Begin()
    self:AddHook("EntityFireBullets", function(entity, data)
        if not IsPlayer(entity) then return end
        local playername = entity:Nick()
        playerlastshottime[playername] = CurTime()
        playerdraining[playername] = false
    end)

    local wait_time = reload_wait_time:GetFloat()
    local drain_time = reload_drain_time:GetFloat()
    local keep_ammo = reload_keep_ammo:GetBool()
    local affects_buy = reload_affectbuymenu:GetBool()
    self:AddHook("Think", function()
        for _, v in ipairs(self:GetAlivePlayers()) do
            local playername = v:GetName()
            if playerdraining[playername] == nil then
                playerdraining[playername] = false
            end
            if playerlastshottime[playername] == nil then
                playerlastshottime[playername] = CurTime()
            end

            -- We've waited long enough, start draining
            if CurTime() - playerlastshottime[playername] > wait_time then
                playerdraining[playername] = true
            end

            if not playerdraining[playername] then continue end

            if playerlastdraintime[playername] == nil then
                playerlastdraintime[playername] = CurTime()
            end

            -- Not time to drain again
            if CurTime() - playerlastdraintime[playername] < drain_time then continue end

            playerlastdraintime[playername] = CurTime()

            local active_weapon = v:GetActiveWeapon()
            if IsValid(active_weapon) and (active_weapon.AutoSpawnable or (not Randomat:IsWeaponBuyable(active_weapon) or affects_buy)) then
                -- Weapons that have matching clip size and clip max have no extra clips so removing their Clip1 just deletes ammo which is not cool... unless we aren't doing that anyway
                if keep_ammo and (not active_weapon.Primary or not active_weapon.Primary.ClipMax or not active_weapon.Primary.ClipSize or active_weapon.Primary.ClipSize == active_weapon.Primary.ClipMax) then continue end

                local current_clip = active_weapon:Clip1() - 1
                if current_clip >= 0 then
                    active_weapon:SetClip1(current_clip)

                    -- Give them their ammo back if we're configured to do so
                    if keep_ammo then
                        local ammo_type = active_weapon:GetPrimaryAmmoType()
                        v:GiveAmmo(1, ammo_type, true)
                    end
                end
            end
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"wait_time", "drain_time"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 1
            })
        end
    end

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

    return sliders, checks
end

Randomat:register(EVENT)