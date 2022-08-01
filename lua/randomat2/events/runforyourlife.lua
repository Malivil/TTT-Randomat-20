local EVENT = {}

util.AddNetworkString("RandomatRunForYourLifeStart")
util.AddNetworkString("RandomatRunForYourLifeEnd")
util.AddNetworkString("RandomatRunForYourLifeDamage")

CreateConVar("randomat_runforyourlife_delay", 0.2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between player taking damage", 0.1, 5)
CreateConVar("randomat_runforyourlife_damage", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Amount of damage a player takes", 1, 10)

EVENT.Title = "Run For Your Life!"
EVENT.Description = "Hurts a player while they are sprinting"
EVENT.id = "runforyourlife"
EVENT.Categories = {"moderateimpact"}

function EVENT:Begin()
    local delay = GetConVar("randomat_runforyourlife_delay"):GetFloat()
    net.Start("RandomatRunForYourLifeStart")
    net.WriteFloat(delay)
    net.Broadcast()

    local last_hurt_time = {}
    local damage = GetConVar("randomat_runforyourlife_damage"):GetInt()
    net.Receive("RandomatRunForYourLifeDamage", function()
        local ply = net.ReadEntity()
        local last_hurt = net.ReadFloat()
        if ply == nil or not IsValid(ply) or not ply:Alive() then return end

        local sid64 = ply:SteamID64()
        local diff = math.abs(last_hurt - (last_hurt_time[sid64] or 0))
        if diff >= delay then
            ply:TakeDamage(damage)
            last_hurt_time[sid64] = last_hurt
        end
    end)
end

function EVENT:End()
    net.Start("RandomatRunForYourLifeEnd")
    net.Broadcast()
end

function EVENT:Condition()
    -- Check that this variable exists by double negating
    -- We can't just return the variable directly because it's not a boolean
    -- The "TTTSprintStaminaPost" hook is only available in the new CR
    local is_new_cr = not not CR_VERSION
    -- If the enabled convar doesn't exist we assume sprint exists
    local has_sprint = not ConVarExists("ttt_sprint_enabled") or GetConVar("ttt_sprint_enabled"):GetBool()

    -- Don't run this while Olympic Sprint is running because then we can't actually track if someone is sprinting...
    return is_new_cr and has_sprint and not Randomat:IsEventActive("olympicsprint")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"delay", "damage"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "delay" and 1 or 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)