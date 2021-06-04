local EVENT = {}

EVENT.Title = "Honey, I shrunk the terrorists"
EVENT.Description = "Scales each player's size and speed"
EVENT.id = "shrink"

CreateConVar("randomat_shrink_scale", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The shrinking scale factor", 0.1, 0.9)

local offsets = {}
local offsets_ducked = {}

function EVENT:Begin()
    local sc = GetConVar("randomat_shrink_scale"):GetFloat()
    for _, ply in ipairs(self:GetAlivePlayers()) do
        ply:SetStepSize(ply:GetStepSize() * sc)
        ply:SetModelScale(ply:GetModelScale() * sc, 1)

        -- Save the original values
        if not offsets[ply:SteamID64()] then
            offsets[ply:SteamID64()] = ply:GetViewOffset()
        end
        if not offsets_ducked[ply:SteamID64()] then
            offsets_ducked[ply:SteamID64()] = ply:GetViewOffsetDucked()
        end

        -- Use the current, not the saved, values so that this can run multiple times (in theory)
        ply:SetViewOffset(ply:GetViewOffset()*sc)
        ply:SetViewOffsetDucked(ply:GetViewOffsetDucked()*sc)

        local a, b = ply:GetHull()
        ply:SetHull(a * sc, b * sc)

        a, b = ply:GetHullDuck()
        ply:SetHullDuck(a * sc, b * sc)

        -- Reduce the player speed on the client
        local speed_factor = math.Clamp(ply:GetStepSize() / 9, 0.25, 1)
        net.Start("RdmtSetSpeedMultiplier")
        net.WriteFloat(speed_factor)
        net.WriteString("RdmtShrinkSpeed")
        net.Send(ply)
    end

    -- Reduce the player speed on the server
    self:AddHook("TTTSpeedMultiplier", function(ply, mults)
        if not ply:Alive() or ply:IsSpec() then return end
        local speed_factor = math.Clamp(ply:GetStepSize() / 9, 0.25, 1)
        table.insert(mults, speed_factor)
    end)

    timer.Create("RdmtTimerShrinkHp", 1, 0, function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            local rat = ply:GetStepSize() / 18
            if ply:Health() > math.floor(rat * 100) then
                ply:SetHealth(math.floor(rat * 100))
            end
            ply:SetMaxHealth(math.floor(rat * 100))
        end
    end)
end

function EVENT:End()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetModelScale(1, 1)

        -- Retrieve the saved offsets
        local offset = nil
        if offsets[ply:SteamID64()] then
            offset = offsets[ply:SteamID64()]
            offsets[ply:SteamID64()] = nil
        end
        -- Reset the view offset to the saved value or the default (if the ec_ViewChanged is not set)
        -- The "ev_ViewChanged" property is from the "Enhanced Camera" mod which use ViewOffset to make the camera more "realistic"
        if offset or not ply.ec_ViewChanged then
            ply:SetViewOffset(offset or Vector(0, 0, 64))
        end

        -- Retrieve the saved ducked offsets
        local offset_ducked = nil
        if offsets_ducked[ply:SteamID64()] then
            offset_ducked = offsets_ducked[ply:SteamID64()]
            offsets_ducked[ply:SteamID64()] = nil
        end
        -- Reset the view offset to the saved value or the default (if the ec_ViewChanged is not set)
        -- The "ev_ViewChanged" property is from the "Enhanced Camera" mod which use ViewOffset to make the camera more "realistic"
        if offset_ducked or not ply.ec_ViewChanged then
            ply:SetViewOffsetDucked(offset_ducked or Vector(0, 0, 28))
        end
        ply:ResetHull()
        ply:SetStepSize(18)
    end
    timer.Remove("RdmtTimerShrinkHp")

    -- Reset the player speed on the client
    net.Start("RdmtRemoveSpeedMultiplier")
    net.WriteString("RdmtShrinkSpeed")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"scale"}) do
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
    return sliders
end

Randomat:register(EVENT)