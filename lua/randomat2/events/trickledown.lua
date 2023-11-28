local EVENT = {}

EVENT.Title = "Trickle-Down Economics"
EVENT.Description = "Spent credits are redistributed to other people with shops"
EVENT.id = "trickledown"
EVENT.Categories = {"moderateimpact"}

function EVENT:Begin()
    self:AddHook("TTTOrderedEquipment", function(ply, item, is_item, fromrdmt)
        if fromrdmt then return end

        local target = nil
        for _, p in ipairs(self:GetAlivePlayers(true)) do
            if Randomat:CanUseShop(p) and p ~= ply then
                target = p
                break
            end
        end

        if not target then return end

        target:AddCredits(1)
        Randomat:PrintMessage(target, MSG_PRINTBOTH, "Congratulations! Wealth has finally trickled down and you've been given a free credit!")
    end)
end

Randomat:register(EVENT)