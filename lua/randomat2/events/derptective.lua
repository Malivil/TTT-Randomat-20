local EVENT = {}

CreateConVar("randomat_derptective_rate_of_fire", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Rate of Fire multiplier for the H.U.G.E.", 2, 5)

EVENT.Title = "Derptective"
EVENT.Description = "Forces the detective(s) and detraitor(s) to use the M249 H.U.G.E. with infinite ammo and an adjusted rate of fire"
EVENT.id = "derptective"

function EVENT:Begin()
    local rof = GetConVar("randomat_derptective_rate_of_fire"):GetInt()
    self:AddHook("Think", function()
        for _, ply in pairs(self:GetAlivePlayers()) do
            if ply:GetRole() == ROLE_DETECTIVE or ply:GetRole() == ROLE_DETRAITOR then
                -- Force the player to use the H.U.G.E.
                if not ply:HasWeapon("weapon_zm_sledge")  then
                    ply:StripWeapons()
                    ply:Give("weapon_zm_sledge")
                    ply:SelectWeapon("weapon_zm_sledge")
                end

                local huge = ply:GetActiveWeapon()
                if IsValid(huge) then
                    -- Don't let them drop it
                    huge.AllowDrop = false
                    -- Make it fire super fast
                    if huge.Primary.DefaultDelay == nil then
                        huge.Primary.DefaultDelay = huge.Primary.Delay
                    end
                    huge.Primary.Delay = huge.Primary.DefaultDelay / rof
                    -- Disable ironsights
                    huge.NoSights = true
                    -- Give them infinite ammo
                    huge:SetClip1(ply:GetActiveWeapon().Primary.ClipSize)
                end
            end
        end
    end)

    -- Disallow them from picking up new weapons
    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not IsValid(ply) then return end
        local weapon_class = WEPS.GetClass(wep)
        return not (ply:GetRole() == ROLE_DETECTIVE or ply:GetRole() == ROLE_DETRAITOR) or (weapon_class == "weapon_zm_sledge")
    end)
end

function EVENT:End()
    for _, ply in pairs(self:GetAlivePlayers()) do
        if ply:GetRole() == ROLE_DETECTIVE or ply:GetRole() == ROLE_DETRAITOR then
            local wep = ply:GetActiveWeapon()
            -- Reverse the changes to the H.U.G.E. if they have one
            if IsValid(wep) and WEPS.GetClass(wep) == "weapon_zm_sledge" then
                wep.AllowDrop = true
                if wep.Primary.DefaultDelay ~= nil then
                    wep.Primary.Delay = wep.Primary.DefaultDelay
                end
                wep.NoSights = false
            end
        end
    end
end

function EVENT:Condition()
    -- Only run if there is at least one detective/detraitor living
    for _, v in pairs(player.GetAll()) do
        if (v:GetRole() == ROLE_DETECTIVE or v:GetRole() == ROLE_DETRAITOR) and v:Alive() and not v:IsSpec() then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"rate_of_fire"}) do
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