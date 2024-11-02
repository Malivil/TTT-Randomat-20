local EVENT = {}

util.AddNetworkString("JumpCooldownBegin")
util.AddNetworkString("JumpCooldownEnd")

CreateConVar("randomat_jumpcooldown_length", "5", FCVAR_ARCHIVE, "The length of the jump cooldown", 1, 180)

EVENT.Title = "There's a cooldown on the jump!"
EVENT.Description = "Players can only jump once every 5 seconds"
EVENT.id = "jumpcooldown"
EVENT.Type = EVENT_TYPE_JUMPING
EVENT.Categories = {"fun", "moderateimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    local cooldown = GetConVar("randomat_jumpcooldown_length"):GetInt()
    self.Description = "Players can only jump once every " .. cooldown .. " seconds"
end

function EVENT:Begin()
    local cooldown = GetConVar("randomat_jumpcooldown_length"):GetInt()
    net.Start("JumpCooldownBegin")
    net.WriteUInt(cooldown, 8)
    net.Broadcast()
end

function EVENT:End()
    net.Start("JumpCooldownEnd")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"length"}) do
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