local EVENT = {}

util.AddNetworkString("RdmtFOVBegin")

CreateConVar("randomat_fov_scale", 1.5, FCVAR_ARCHIVE, "Scale of the FOV increase", 1.1, 2.0)
CreateConVar("randomat_fov_scale_ironsight", 1.0, FCVAR_ARCHIVE, "Scale of the FOV increase when ironsighted", 0.8, 2.0)

EVENT.Title = "Quake Pro"
EVENT.Description = "Increases each player's Field of View (FOV) so it looks like you're playing Quake"
EVENT.id = "fov"
EVENT.SingleUse = false
EVENT.Categories = {"largeimpact"}

local function PlayerInIronsights(ply)
    if not ply.GetActiveWeapon then return false end
    local weap = ply:GetActiveWeapon()
    return IsValid(weap) and weap.GetIronsights and weap:GetIronsights()
end

function EVENT:Begin()
    local scale = GetConVar("randomat_fov_scale"):GetFloat()
    local scaleIronsight = GetConVar("randomat_fov_scale_ironsight"):GetFloat()
    local originalFOV = {}
    for _, v in player.Iterator() do
        if PlayerInIronsights(v) then
            v:GetActiveWeapon():SetIronsights(false)
            v:SetFOV(0, 0)
        end
    end
    net.Start("RdmtFOVBegin")
    net.Broadcast()

    timer.Create("RandomatFOVTimer", 0.1, 0, function()
        for _, v in player.Iterator() do
            if v:Alive() and not v:IsSpec() then
                local fovScale
                if PlayerInIronsights(v) then
                    fovScale = scaleIronsight
                else
                    fovScale = scale
                end

                -- Save the player's scaled FOV the first time we see them
                if originalFOV[v:SteamID64()] == nil then
                    originalFOV[v:SteamID64()] = v:GetFOV()
                end

                v:SetFOV(originalFOV[v:SteamID64()] * fovScale, 0)
            else
                v:SetFOV(0, 0)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatFOVTimer")
    for _, v in player.Iterator() do
        v:SetFOV(0, 0)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"scale", "scale_ironsight"}) do
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