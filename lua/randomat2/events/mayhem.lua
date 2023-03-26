local EVENT = {}

EVENT.Title = "Total Mayhem"
EVENT.Description = "Causes players to explode when killed"
EVENT.id = "mayhem"
EVENT.Categories = {"deathtrigger", "biased_traitor", "biased", "moderateimpact"}

function EVENT:Begin()
    self:AddHook("PlayerDeath", function(tgt, src, ply)
        timer.Create("RdmtTotalMayhemDelay" .. tgt:Nick(), 0.1, 1, function()
            local explode = ents.Create("env_explosion")
            explode:SetPos(tgt:GetPos())
            explode:SetOwner(ply)
            explode:Spawn()
            explode:SetKeyValue("iMagnitude", "150")
            explode:Fire("Explode", 0,0)
            explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
            timer.Remove("RdmtTotalMayhemDelay" .. tgt:Nick())
        end)
    end)
end

function EVENT:End()
    for _, p in ipairs(player.GetAll()) do
        timer.Remove("RdmtTotalMayhemDelay" .. p:Nick())
    end
end

-- 'Contagious Morality' + this event causes rocket propelled corpses because
-- the player that is killed keeps exploding as they change role over and over
function EVENT:Condition()
    return not Randomat:IsEventActive("contagiousmorality") and not Randomat:IsEventActive("partialmayhem")
end

Randomat:register(EVENT)