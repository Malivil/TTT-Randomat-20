local EVENT = {}

EVENT.Title = "Partial Mayhem"
EVENT.Description = "Causes players to explode when killed by teammates"
EVENT.id = "partialmayhem"
EVENT.Categories = {"deathtrigger", "biased_traitor", "biased", "moderateimpact"}

function EVENT:Begin()
    self:AddHook("PlayerDeath", function(tgt, src, ply)
        if not IsPlayer(ply) or not tgt:IsSameTeam(ply) then return end

        timer.Create("RdmtPartialMayhemDelay" .. tgt:Nick(), 0.1, 1, function()
            local explode = ents.Create("env_explosion")
            explode:SetPos(tgt:GetPos())
            explode:SetOwner(ply)
            explode:Spawn()
            explode:SetKeyValue("iMagnitude", "150")
            explode:Fire("Explode", 0,0)
            explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
            timer.Remove("RdmtPartialMayhemDelay" .. tgt:Nick())
        end)
    end)
end

function EVENT:End()
    for _, p in player.Iterator() do
        timer.Remove("RdmtPartialMayhemDelay" .. p:Nick())
    end
end

function EVENT:Condition()
    if not CR_VERSION then return end

    -- 'Contagious Morality' + this event causes rocket propelled corpses because
    -- the player that is killed keeps exploding as they change role over and over
    return not Randomat:IsEventActive("contagiousmorality") and not Randomat:IsEventActive("mayhem")
end

Randomat:register(EVENT)