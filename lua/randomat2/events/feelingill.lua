local EVENT = {}

EVENT.Title = "I'm feeling kinda ILL"
EVENT.Description = "Causes players to slowly lose health over time"
EVENT.id = "feelingill"
EVENT.Categories = {"moderateimpact"}

CreateConVar("randomat_feelingill_timer", 3, FCVAR_NONE, "How often a player will lose health", 1, 60)
CreateConVar("randomat_feelingill_health", 1, FCVAR_NONE, "How much health per tick you lose", 1, 10)

function EVENT:Begin()
    local illtime = GetConVar("randomat_feelingill_timer"):GetInt()
    self:AddHook("Think", function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            if not ply.rmdfeelingill then
                ply.rmdfeelingill = CurTime() + illtime
            end

            local hp = ply:Health()
            if ply.rmdfeelingill <= CurTime() and hp > 1 then
                local newhp = math.max(1, hp - GetConVar("randomat_feelingill_health"):GetInt())
                ply:SetHealth(newhp)
                ply.rmdfeelingill = CurTime() + illtime
            end
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "health"}) do
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