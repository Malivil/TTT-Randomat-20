local EVENT = {}

util.AddNetworkString("RdmtFogOfWarBegin")
util.AddNetworkString("RdmtFogOfWarEnd")

local default = CreateConVar("randomat_fogofwar_default", 1, FCVAR_ARCHIVE, "The fog distance scale for non-traitors", 0.2, 5)
local traitor = CreateConVar("randomat_fogofwar_traitor", 1.5, FCVAR_ARCHIVE, "The fog distance scale for traitors", 0.2, 5)

EVENT.Title = "Fog of War"
EVENT.Description = "Covers the map in a fog which restricts player view"
EVENT.id = "fogofwar"
EVENT.Categories = {"biased_traitor", "biased", "moderateimpact"}

function EVENT:Begin()
    net.Start("RdmtFogOfWarBegin")
    net.WriteFloat(default:GetFloat())
    net.WriteFloat(traitor:GetFloat())
    net.Broadcast()
end

function EVENT:End()
    net.Start("RdmtFogOfWarEnd")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"default", "traitor"}) do
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