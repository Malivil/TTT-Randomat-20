local EVENT = {}

CreateConVar("randomat_runforyourlife_delay", 0.2, FCVAR_ARCHIVE, "Time between player taking damage", 0.1, 5)
CreateConVar("randomat_runforyourlife_damage", 3, FCVAR_ARCHIVE, "Amount of damage a player takes", 1, 10)

EVENT.Title = "Run For Your Life!"
EVENT.Description = "Hurts a player while they are sprinting"
EVENT.id = "runforyourlife"
EVENT.Categories = {"moderateimpact"}

local hurt_timers = {}

function EVENT:Begin()
    local delay = GetConVar("randomat_runforyourlife_delay"):GetFloat()
    local damage = GetConVar("randomat_runforyourlife_damage"):GetInt()

    self:AddHook("TTTSprintStateChange", function(ply, sprinting, wasSprinting)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        local timerId = "RdmtRunForYourLifeHurtTimer_" .. ply:SteamID64()
        if sprinting then
            if not hurt_timers[timerId] then
                hurt_timers[timerId] = true
                timer.Create(timerId, delay, 0, function()
                    if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
                    ply:TakeDamage(damage)
                end)
            end
        else
            timer.Remove(timerId)
            hurt_timers[timerId] = false
        end
    end)
end

function EVENT:End()
    for timerId, _ in pairs(hurt_timers) do
        timer.Remove(timerId)
    end
    table.Empty(hurt_timers)
end

function EVENT:Condition()
    -- Check that this variable exists by double negating
    -- We can't just return the variable directly because it's not a boolean
    -- The "TTTSprintStaminaPost" and "TTTSprintStateChange" hooks are only available in the new CR
    local is_new_cr = not not CR_VERSION
    -- If the enabled convar doesn't exist we assume sprint exists
    local has_sprint = not ConVarExists("ttt_sprint_enabled") or GetConVar("ttt_sprint_enabled"):GetBool()

    -- Don't run this while Olympic Sprint is running because then we can't actually track if someone is sprinting...
    return is_new_cr and has_sprint and not Randomat:IsEventActive("olympicsprint")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"delay", "damage"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "delay" and 1 or 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)