local EVENT = {}

CreateConVar("randomat_bighead_scale", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Head size multiplier", 1.5, 5)

EVENT.Title = "Big Head Mode"
EVENT.id = "bighead"

local function ScalePlayerHeads(mult)
    for _, p in pairs(player.GetAll()) do
        local boneId = p:LookupBone("ValveBiped.Bip01_Head1")
        if boneId == nil then return end

        local scale = Vector(mult, mult, mult)
        p:ManipulateBoneScale(boneId, scale)
    end
end

function EVENT:Begin()
    ScalePlayerHeads(GetConVar("randomat_bighead_scale"):GetFloat())
end

function EVENT:End()
    ScalePlayerHeads(1)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"scale"}) do
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