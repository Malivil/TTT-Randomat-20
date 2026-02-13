local EVENT = {}
EVENT.id = "trexvision"

local function IsPlayerValid(p)
    return IsPlayer(p) and p:Alive() and not p:IsSpec()
end

function EVENT:Begin()
    self:AddHook("TTTTargetIDPlayerBlockIcon", function(ply, cli)
        if not IsPlayerValid(cli) or not IsPlayerValid(ply) then return end

        if Randomat:IsPlayerInvisible(ply) then
            return true
        end
    end)

    self:AddHook("TTTTargetIDPlayerBlockInfo", function(ply, cli)
        if not IsPlayerValid(cli) or not IsPlayerValid(ply) then return end

        if Randomat:IsPlayerInvisible(ply) then
            return true
        end
    end)
end

Randomat:register(EVENT)