local EVENT = {}

EVENT.Title = "Bomberman"
EVENT.Description = "Spawns an explosive barrel behind a player when they crouch"
EVENT.id = "bomberman"

function EVENT:Begin()
    local was_ducking = {}

    self:AddHook("FinishMove", function(ply, mv)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        local sid64 = ply:SteamID64()
        if ply:Crouching() and was_ducking[sid64] then return end

        if ply:Crouching() then
            was_ducking[sid64] = true

            -- Don't spawn a barrel if the player is not on the ground
            if ply:IsOnGround() then
                local pos = ply:GetPos()
                local ang = ply:GetAngles()
                local new_pos = pos - (ang:Forward() * 40)
                Randomat:SpawnBarrel(new_pos, 1, 1, true)
            end
        else
            was_ducking[sid64] = false
        end
    end)
end

Randomat:register(EVENT)