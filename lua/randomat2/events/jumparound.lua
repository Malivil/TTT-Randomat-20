local EVENT = {}

util.AddNetworkString("JumpAroundBegin")
util.AddNetworkString("JumpAroundEnd")

CreateConVar("randomat_jumparound_jumps", 5, FCVAR_ARCHIVE, "How many multi-jumps the players can do", 2, 10)

EVENT.Title = "Jump Around!"
EVENT.Description = "Players can only move by multi-jumping"
EVENT.id = "jumparound"
EVENT.Type = EVENT_TYPE_JUMPING
EVENT.Categories = {"fun", "moderateimpact"}

local jumps = nil
function EVENT:Begin()
    if not jumps then
        local jumpConVar = GetConVar("multijump_default_jumps")
        jumps = jumpConVar:GetInt()
        jumpConVar:SetInt(GetConVar("randomat_jumparound_jumps"):GetInt())
    end

    net.Start("JumpAroundBegin")
    net.Broadcast()
end

function EVENT:End()
    if jumps then
        GetConVar("multijump_default_jumps"):SetInt(jumps)
    end

    net.Start("JumpAroundEnd")
    net.Broadcast()
end

function EVENT:Condition()
    return ConVarExists("multijump_default_jumps")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"jumps"}) do
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