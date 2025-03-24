local EVENT = {}

EVENT.Title = "NO NERD HEALING"
EVENT.Description = "Prevents any player from regaining lost health"
EVENT.id = "noheal"
EVENT.Categories = {"moderateimpact"}

local playerhealth = {}

function EVENT:Begin()
    for _, v in ipairs(self:GetAlivePlayers()) do
        playerhealth[v:SteamID64()] = v:Health()
    end

    self:AddHook("Think", function()
        for _, v in ipairs(self:GetAlivePlayers()) do
            local sid64 = v:SteamID64()
            local hp = v:Health()
            if hp > playerhealth[sid64] then
                v:SetHealth(playerhealth[sid64])
            else
                playerhealth[sid64] = hp
            end
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        -- Save the player's initial health on spawn so if they get ressed, it resets to full
        playerhealth[ply:SteamID64()] = ply:Health()
    end)
end

Randomat:register(EVENT)