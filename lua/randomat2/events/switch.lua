local EVENT = {}

EVENT.Title = "There's this game my father taught me years ago, it's called \"Switch\""
EVENT.AltTitle = "Switch"
EVENT.Description = "Randomly switches positions of two players periodically"
EVENT.id = "switch"
EVENT.Categories = {"fun", "moderateimpact"}

CreateConVar("randomat_switch_timer", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often players are switched", 5, 60)

function EVENT:Begin()
    timer.Create("RandomatSwitchTimer", GetConVar("randomat_switch_timer"):GetInt(), 0, function()
        local i = 0
        local ply1 = 0
        local ply2 = 0
        for _, v in ipairs(self:GetAlivePlayers(true)) do
            if i == 0 then
                ply1 = v
                i = i+1
            elseif i == 1 then
                ply2 = v
                i = i+1
            end
        end

        ply1:ExitVehicle()
        ply2:ExitVehicle()

        -- Wait for the dismount to take effect
        timer.Simple(0.2, function()
            local ply1pos = ply1:GetPos()
            ply1:SetPos(ply2:GetPos())
            ply2:SetPos(ply1pos)
            self:SmallNotify("Go!")
        end)
    end)
end

function EVENT:End()
    timer.Remove("RandomatSwitchTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)