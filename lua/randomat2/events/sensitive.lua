local EVENT = {}

util.AddNetworkString("RdmtSetSensitivityValue")

EVENT.Title = "Don't be so Sensitive"
EVENT.Description = "Periodically changes each player's mouse sensitivity"
EVENT.id = "sensitive"
EVENT.Categories = {"fun", "largeimpact"}

CreateConVar("randomat_sensitive_change_interval", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often to change each player's sensitivity", 5, 60)
CreateConVar("randomat_sensitive_scale_min", 25, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The minimum sensitivity to use", 10, 100)
CreateConVar("randomat_sensitive_scale_max", 500, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum sensitivity to use", 100, 1000)

local function SetSensitivity(ply, sensitivity)
    net.Start("RdmtSetSensitivityValue")
    net.WriteFloat(sensitivity)
    net.Send(ply)
end

function EVENT:Begin()
    local interval = GetConVar("randomat_sensitive_change_interval"):GetInt()
    local min = GetConVar("randomat_sensitive_scale_min"):GetInt()
    local max = GetConVar("randomat_sensitive_scale_max"):GetInt()
    timer.Create("RdmtSensitivityChangeTimer", interval, 0, function()
        for _, v in player.Iterator() do
            local sensitivity = 0
            if v:Alive() and not v:IsSpec() then
                sensitivity = math.random(min, max) / 100
            end
            SetSensitivity(v, sensitivity)
        end
    end)

    -- Reset dead player's sensitivity
    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        SetSensitivity(victim, 0)
    end)
end

function EVENT:End()
    timer.Remove("RdmtSensitivityChangeTimer")
    -- Added in cl_sensitive
    hook.Remove("AdjustMouseSensitivity", "RdmtSensitiveChangeHook")
    for _, v in player.Iterator() do
        SetSensitivity(v, 0)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"change_interval", "scale_min", "scale_max"}) do
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