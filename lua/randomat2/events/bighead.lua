AddCSLuaFile()

local EVENT = {}

util.AddNetworkString("BigHeadActivate")
util.AddNetworkString("BigHeadStop")

CreateConVar("randomat_bighead_scale", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Head size multiplier", 1.5, 5)

EVENT.Title = "Big Head Mode"
EVENT.id = "bighead"

function EVENT:Begin()
    net.Start("BigHeadActivate")
    net.WriteFloat(GetConVar("randomat_bighead_scale"):GetFloat())
    net.Broadcast()
end

function EVENT:End()
    net.Start("BigHeadStop")
    net.Broadcast()
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