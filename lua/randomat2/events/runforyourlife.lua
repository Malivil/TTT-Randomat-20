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
    net.Start("RandomatRunForYourLifeStart")
    net.WriteFloat(GetConVar("randomat_runforyourlife_delay"):GetFloat())
    net.Broadcast()

    net.Receive("RandomatRunForYourLifeDamage", function()
        local ply = net.ReadEntity()
        local damage = GetConVar("randomat_runforyourlife_damage"):GetInt()
        ply:TakeDamage(damage)
    end)
end

function EVENT:End()
    net.Start("RandomatRunForYourLifeEnd")
    net.Broadcast()
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