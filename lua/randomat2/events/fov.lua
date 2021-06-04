local EVENT = {}

CreateConVar("randomat_fov_scale", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Scale of the FOV increase", 1.1, 2.0)

EVENT.Title = "Quake Pro"
EVENT.Description = "Increases each player's Field of View (FOV) so it looks like you're playing Quake"
EVENT.id = "fov"
EVENT.SingleUse = false

function EVENT:Begin()
    local scale = GetConVar("randomat_fov_scale"):GetFloat()
    local changedFOV = {}
    timer.Create("RandomatFOVTimer", 0.1, 0, function()
        for _, v in ipairs(player.GetAll()) do
            if v:Alive() and not v:IsSpec() then
                -- Save the player's scaled FOV the first time we see them
                if changedFOV[v:SteamID64()] == nil then
                    changedFOV[v:SteamID64()] = v:GetFOV() * scale
                end

                v:SetFOV(changedFOV[v:SteamID64()], 0)
            else
                v:SetFOV(0, 0)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatFOVTimer")
    for _, v in ipairs(player.GetAll()) do
        v:SetFOV(0, 0)
    end
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