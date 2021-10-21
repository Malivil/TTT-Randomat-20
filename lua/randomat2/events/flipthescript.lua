local EVENT = {}

EVENT.Title = "Flip the Script"
EVENT.Description = "Inverses everyone's health"
EVENT.id = "flipthescript"
EVENT.SingleUse = false
EVENT.MinRoundCompletePercent = 25

function EVENT:Begin()
    for _, v in ipairs(self:GetAlivePlayers()) do
        local hp = v:Health()
        -- Do this incase the player is currently overhealed
        local max = math.max(v:GetMaxHealth(), hp)
        local new_hp = (max - hp) + 1
        v:SetHealth(new_hp)
    end
end

Randomat:register(EVENT)