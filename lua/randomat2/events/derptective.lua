local EVENT = {}

CreateConVar("randomat_derptective_rate_of_fire", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Rate of Fire multiplier for the H.U.G.E.", 2, 5)

local function GetEventDescription(has_detraitor, has_deputy_and_imposter)
    local msg = "Forces the " .. Randomat:GetRoleString(ROLE_DETECTIVE) .. "(s)"

    -- Only mention roles that actually exist
    if has_detraitor then
        msg = msg .. " and " .. Randomat:GetRoleString(ROLE_DETRAITOR) .. "(s)"
    elseif has_deputy_and_imposter then
        msg = msg .. " and promoted " .. Randomat:GetRoleString(ROLE_DETECTIVE) .. "-like player(s)"
    end

    return msg .. " to use the M249 H.U.G.E. with infinite ammo and an adjusted rate of fire"
end

EVENT.Title = "Derptective"
EVENT.Description = "Forces the detective(s) to use the M249 H.U.G.E. with infinite ammo and an adjusted rate of fire"
EVENT.id = "derptective"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"biased", "item", "moderateimpact"}

function EVENT:Begin()
    EVENT.Description = GetEventDescription(ROLE_DETRAITOR ~= -1, ROLE_DEPUTY ~= -1 and ROLE_IMPERSONATOR ~= -1)

    local rof = GetConVar("randomat_derptective_rate_of_fire"):GetInt()
    self:AddHook("Think", function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            if Randomat:IsDetectiveLike(ply) then
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
        if Randomat:IsDetectiveLike(ply) then
            return WEPS.GetClass(wep) == "weapon_zm_sledge"
        end
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if not Randomat:IsDetectiveLike(ply) then return end
        if not is_item then
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'!\nYour purchase has been refunded.")
            return false
        end
    end)
end

function EVENT:End()
    for _, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsDetectiveLike(ply) then
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
    -- Only run if there is at least one detective-like player living
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsDetectiveLike(v) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"rate_of_fire"}) do
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