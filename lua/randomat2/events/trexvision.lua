local EVENT = {}

util.AddNetworkString("RdmtTRexVisionBegin")
util.AddNetworkString("RdmtTRexVisionEnd")

EVENT.Title = "T-Rex Vision"
EVENT.Description = "Your vision is now based on movement"
EVENT.id = "trexvision"

local function IsTooSlow(crouching, val)
    local min = 100
    if crouching then min = 40 end
    return math.Round(math.abs(val)) < min
end

function EVENT:Begin()
    net.Start("RdmtTRexVisionBegin")
    net.Broadcast()

    for _, p in ipairs(self:GetAlivePlayers()) do
        Randomat:SetPlayerInvisible(p)
    end

    self:AddHook("PlayerSpawn", function(ply)
        Randomat:SetPlayerInvisible(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        Randomat:SetPlayerVisible(victim)
    end)

    self:AddHook("FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end

        local vel = mv:GetVelocity()
        if ply:Nick() == "Bot07" then
            print(tostring(vel))
        end

        local crouching = ply:Crouching()
        if IsTooSlow(crouching, vel.x) and IsTooSlow(crouching, vel.y) and IsTooSlow(crouching, vel.z) then
            Randomat:SetPlayerInvisible(ply)
        else
            Randomat:SetPlayerVisible(ply)
        end
    end)
end

function EVENT:End()
    net.Start("RdmtTRexVisionEnd")
    net.Broadcast()

    for _, p in ipairs(player.GetAll()) do
        Randomat:SetPlayerVisible(p)
    end
end

Randomat:register(EVENT)