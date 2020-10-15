local EVENT = {}

CreateConVar("randomat_moongravity_gravity", 0.1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The gravity scale")

EVENT.Title = "What? Moon Gravity on Earth?"
EVENT.id = "moongravity"

function EVENT:Begin()
    for _, ply in pairs(self:GetPlayers()) do
        ply:SetGravity(GetConVar("randomat_moongravity_gravity"):GetFloat())
    end
    self:Timer()
end

function EVENT:Timer()
    timer.Create("RandomatMoonGravityTimer", 1,0, function()
        for _, ply in pairs(self:GetPlayers()) do
            ply:SetGravity(GetConVar("randomat_moongravity_gravity"):GetFloat())
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatMoonGravityTimer")
    for _, ply in pairs(player.GetAll()) do
        ply:SetGravity(1)
    end
end

Randomat:register(EVENT)