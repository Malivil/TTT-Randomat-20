local EVENT = {}

EVENT.Title = "Malfunction"
EVENT.Description = "Causes players to randomly shoot their gun"
EVENT.id = "malfunction"
EVENT.Categories = {"moderateimpact"}

CreateConVar("randomat_malfunction_upper", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The upper limit for the random timer", 2, 60)
CreateConVar("randomat_malfunction_lower", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The lower limit for the random timer", 1, 60)
CreateConVar("randomat_malfunction_affectall", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Set to 1 for the event to affect everyone at once")
CreateConVar("randomat_malfunction_duration", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Duration of gun malfunction (set to 0 for 1 shot)", 0.0, 3.0)

function EVENT:Begin()
    local lower = GetConVar("randomat_malfunction_lower"):GetInt()
    local upper = GetConVar("randomat_malfunction_upper"):GetInt()
    -- For sanity
    if lower > upper then
        upper = lower + 1
    end

    local x = 0
    timer.Create("RdmtMalfunctionMain", math.random(lower, upper), 0, function()
        for _, ply in ipairs(self:GetAlivePlayers(true)) do
            if x == 0 or GetConVar("randomat_malfunction_affectall"):GetBool() then
                local wep = ply:GetActiveWeapon()
                if wep ~= nil and wep.Primary and type(wep.Primary.Delay) == "number" and wep.Primary.Delay > 0 then
                    local dur = GetConVar("randomat_malfunction_duration"):GetFloat()
                    local repeats = math.floor(dur/wep.Primary.Delay) + 1
                    timer.Create("RdmtMalfunctionActive", wep.Primary.Delay, repeats, function()
                        if wep:Clip1() ~= 0 then
                            wep:PrimaryAttack()
                            wep:SetNextPrimaryFire(CurTime() + wep.Primary.Delay)
                        end
                    end)
                    x = 1
                end
            end
        end
        x = 0
        timer.Adjust("RdmtMalfunctionMain", math.random(lower, upper))
    end)
end

function EVENT:End()
    timer.Remove("RdmtMalfunctionMain")
    timer.Remove("RdmtMalfunctionActive")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"upper", "lower", "duration"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "duration" and 1 or 0
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