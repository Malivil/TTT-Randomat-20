local EVENT = {}

CreateConVar("randomat_headgrow_max", 2.5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The maximum head size multiplier", 2, 5)
CreateConVar("randomat_headgrow_per_kill", 0.25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The head size increase per kill", 0.25, 1)
CreateConVar("randomat_headgrow_steal", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to steal a player's head size on kill")

EVENT.Title = "Don't Let it Go to Your Head"
EVENT.Description = "Grows a player's head each time they kill"
EVENT.id = "headgrow"

local function ScalePlayerHead(ply, mult)
    if not IsValid(ply) then return end

    local scale = Vector(mult, mult, mult)
    local boneId = ply:LookupBone("ValveBiped.Bip01_Head1")
    if boneId ~= nil then
        ply:ManipulateBoneScale(boneId, scale)
    end
end

function EVENT:Begin()
    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) or not IsValid(killer) then return end

        -- Initial scale is 0
        if killer.HeadScale == nil then
            killer.HeadScale = 0
        end

        -- Keep the killer's existing scale and add the per_kill amount
        local scale = killer.HeadScale + GetConVar("randomat_headgrow_per_kill"):GetFloat()
        -- If the victim has a scaled head and we're supposed to steal, add that as well
        if victim.HeadScale ~= nil and GetConVar("randomat_headgrow_steal"):GetBool() then
            scale = scale + victim.HeadScale
        end

        -- Ensure the scale is below the maximum
        local max = GetConVar("randomat_headgrow_max"):GetFloat()
        if scale > max then
            scale = max
        end

        killer.HeadScale = scale
        ScalePlayerHead(killer, 1 + scale)
    end)
end

function EVENT:End()
    for _, p in pairs(player.GetAll()) do
        p.HeadScale = 0
        ScalePlayerHead(p, 1)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"max", "per_kill"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end

    local checks = {}
    for _, v in pairs({"steal"}) do
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