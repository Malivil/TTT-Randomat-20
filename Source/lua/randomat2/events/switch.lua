local EVENT = {}

EVENT.Title = "There's this game my father taught me years ago, it's called \"Switch\""
EVENT.id = "switch"

CreateConVar("randomat_switch_timer", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often players are switched")

function EVENT:Begin()
    timer.Create("RandomatSwitchTimer", GetConVar("randomat_switch_timer"):GetInt(), 0, function()
        local i = 0
        local ply1 = 0
        local ply2 = 0
        for _, v in pairs(self:GetAlivePlayers()) do
            if i == 0 then
                ply1 = v
                i = i+1
            elseif i == 1 then
                ply2 = v
                i = i+1
            end
        end
        i = 0
        local ply1pos = ply1:GetPos()
        ply1:SetPos(ply2:GetPos())
        ply2:SetPos(ply1pos)
        self:SmallNotify("Go!")
    end)
end

function EVENT:End()
    timer.Remove("RandomatSwitchTimer")
end

Randomat:register(EVENT)