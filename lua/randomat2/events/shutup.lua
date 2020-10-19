local EVENT = {}

EVENT.Title = "SHUT UP!"
EVENT.id = "shutup"

function EVENT:Begin()
    -- Wait a second before implementing this
    timer.Simple(1, function()
        self:AddHook("Think", function()
            for _, v in pairs(player.GetAll()) do
                v:ConCommand("soundfade 100 1")
            end
        end)
    end)
end

Randomat:register(EVENT)