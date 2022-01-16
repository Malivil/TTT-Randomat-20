local EVENT = {}

EVENT.Title = "Trickle-Down Economics"
EVENT.Description = "Spent credits are redistributed to other people with shops"
EVENT.id = "trickledown"

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
        target:PrintMessage(HUD_PRINTTALK, "Congratulations! Wealth has finally trickled down and you've been given a free credit!")
        target:PrintMessage(HUD_PRINTCENTER, "Congratulations! Wealth has finally trickled down and you've been given a free credit!")
    end)
end

Randomat:register(EVENT)