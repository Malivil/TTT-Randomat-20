local EVENT = {}

EVENT.id = "downunder"

function EVENT:Begin()
    local view = { origin = vector_origin, angles = angle_zero, fov = 0 }
    self:AddHook("CalcView", function(ply, origin, angles, fov)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        -- Get the views as given plus whatever is calculated from the current weapon
        view.origin = origin
        view.angles = angles
        view.fov = fov

        local wep = ply:GetActiveWeapon()
        if IsValid(wep) then
            local func = wep.CalcView
            if func then
                view.origin, view.angles, view.fov = func(wep, ply, origin * 1, angles * 1, fov)
            end
        end

        -- And then flip it upside-down
        view.angles.r = view.angles.r + 180

        return view
    end)

    -- Inverts mouse input to make this event easier to control
    local client = LocalPlayer()
    self:AddHook("InputMouseApply", function(cmd, x, y, ang)
        if not IsPlayer(client) or not client:Alive() or client:IsSpec() then return end

        ang.yaw = ang.yaw + (x / 50)
        ang.pitch = math.Clamp(ang.pitch - y / 50, -89, 89)
        cmd:SetViewAngles(ang)

        return true
    end)
end

Randomat:register(EVENT)