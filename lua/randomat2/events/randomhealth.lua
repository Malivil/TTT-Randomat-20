local EVENT = {}

CreateConVar("randomat_randomhealth_upper", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The upper limit of health gained")
CreateConVar("randomat_randomhealth_lower", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The lower limit of health gained")

EVENT.Title = "Random Health for everyone!"
EVENT.id = "randomhealth"

function EVENT:Begin()
    for _, ply in pairs(self:GetPlayers(true)) do
        local newhealth = ply:Health() + math.random(GetConVar("randomat_randomhealth_lower"):GetInt(), GetConVar("randomat_randomhealth_upper"):GetInt())

        ply:SetHealth(newhealth)

        if ply:Health() > ply:GetMaxHealth() then
            ply:SetMaxHealth(newhealth)
        end
    end
end

Randomat:register(EVENT)