local EVENT = {}

EVENT.Title = "NO NERD HEALING"
EVENT.id = "noheal"

local playerhealth = {}

function EVENT:Begin()
    for _, v in pairs(self:GetAlivePlayers(true)) do
        playerhealth[v:GetName()] = v:Health()
    end

    hook.Add("Think", "RdmtHealCheckHook", function()
        for _, v in pairs(self:GetAlivePlayers(true)) do
            local playername = v:GetName()
            if v:Health() > playerhealth[playername] then
                v:SetHealth(playerhealth[playername])
            else
                playerhealth[playername] = v:Health()
            end
        end
    end)

    hook.Add("PlayerSpawn", "RdmtHealSpawnHook", function(ply)
        -- Save the player's initial health on spawn so if they get ressed, it resets to full
        playerhealth[ply:GetName()] = ply:Health()
    end)
end

function EVENT:End()
    hook.Remove("Think", "RdmtHealCheckHook")
    hook.Remove("PlayerSpawn", "RdmtHealSpawnHook")
end

Randomat:register(EVENT)