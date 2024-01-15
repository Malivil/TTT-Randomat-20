local EVENT = {}

local viewpct = CreateConVar("randomat_tunnelvision_viewpct", 33, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "What percent of the screen the player should be able to see through", 1, 99)

EVENT.Title = "Tunnel Vision"
EVENT.Description = "Players are having trouble seeing things on the edge of their screen..."
EVENT.id = "tunnelvision"
EVENT.Categories = {"moderateimpact"}

util.AddNetworkString("TriggerTunnelVision")
util.AddNetworkString("EndTunnelVision")

function EVENT:Begin()
    net.Start("TriggerTunnelVision")
    net.WriteUInt(viewpct:GetInt(), 7)
    net.Broadcast()
end

function EVENT:End()
    net.Start("EndTunnelVision")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"viewpct"}) do
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