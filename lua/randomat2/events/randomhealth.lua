local EVENT = {}

CreateConVar("randomat_randomhealth_upper", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The upper limit of health gained", 10, 200)
CreateConVar("randomat_randomhealth_lower", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The lower limit of health gained", 0, 100)

EVENT.Title = "Random Health for everyone!"
EVENT.ExtDescription = "Gives everyone a random amount of additional health"
EVENT.id = "randomhealth"
EVENT.SingleUse = false
EVENT.Categories = {"fun", "moderateimpact"}

function EVENT:Begin()
    local lower = GetConVar("randomat_randomhealth_lower"):GetInt()
    local upper = GetConVar("randomat_randomhealth_upper"):GetInt()
    -- For sanity
    if lower > upper then
        upper = lower + 1
    end

    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        local newhealth = ply:Health() + math.random(lower, upper)

        ply:SetHealth(newhealth)

        if ply:Health() > ply:GetMaxHealth() then
            ply:SetMaxHealth(newhealth)
        end
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"upper", "lower"}) do
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