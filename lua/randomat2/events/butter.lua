local EVENT = {}

CreateConVar("randomat_butter_timer", 10, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The time between each weapon drop.", 5, 60)
CreateConVar("randomat_butter_affectall", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "Whether to affect everyone or just a single random player.")

EVENT.Title = "Butterfingers"
EVENT.Description = "Causes weapons to periodically slip out of players' hands"
EVENT.id = "butter"
EVENT.Categories = {"biased", "moderateimpact"}

function EVENT:Begin()
    local affect_all = GetConVar("randomat_butter_affectall"):GetBool()
    local affected = false
    timer.Create("weapondrop", GetConVar("randomat_butter_timer"):GetInt(), 0, function()
        for _, ply in ipairs(self:GetAlivePlayers(true)) do
            if not affected or affect_all then
                local wep = ply:GetActiveWeapon()
                if IsValid(wep) and wep.AllowDrop then
                    affected = true
                    ply:DropWeapon(wep)
                    ply:SetFOV(0, 0.2)
                    ply:EmitSound("vo/npc/Barney/ba_pain01.wav")
                end
            end
        end
        affected = false
    end)
end

function EVENT:End()
    timer.Remove("weapondrop")
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

    local checks = {}
    for _, v in ipairs({"affectall"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return sliders, checks
end

Randomat:register(EVENT)