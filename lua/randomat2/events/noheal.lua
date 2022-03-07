local EVENT = {}

EVENT.Title = "NO NERD HEALING"
EVENT.Description = "Prevents any player from regaining lost health"
EVENT.id = "noheal"
EVENT.Categories = {"moderateimpact"}

local playerhealth = {}

function EVENT:Begin()
    for _, v in ipairs(self:GetAlivePlayers()) do
        playerhealth[v:GetName()] = v:Health()
    end

    self:AddHook("Think", function()
        for _, v in ipairs(self:GetAlivePlayers()) do
            local playername = v:GetName()
            if v:Health() > playerhealth[playername] then
                v:SetHealth(playerhealth[playername])
            else
                playerhealth[playername] = v:Health()
            end
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        -- Save the player's initial health on spawn so if they get ressed, it resets to full
        playerhealth[ply:GetName()] = ply:Health()
    end)
end

Randomat:register(EVENT)