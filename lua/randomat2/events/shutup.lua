local EVENT = {}

EVENT.Title = "SHUT UP!"
EVENT.Description = "Disables all sounds for the duration of the event"
EVENT.id = "shutup"
EVENT.Categories = {"moderateimpact"}

function EVENT:Begin()
    -- Wait a second before implementing this
    timer.Simple(1, function()
        self:AddHook("Think", function()
            for _, v in ipairs(player.GetAll()) do
                v:ConCommand("soundfade 100 1")
            end
        end)
    end)
end

Randomat:register(EVENT)