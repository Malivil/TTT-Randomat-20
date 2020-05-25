local EVENT = {}

EVENT.Title = "Malfunction"
EVENT.id = "malfunction"

CreateConVar("randomat_malfunction_upper", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The upper limit for the random timer")
CreateConVar("randomat_malfunction_lower", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The lower limit for the random timer")
CreateConVar("randomat_malfunction_affectall", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Set to 1 for the event to affect everyone at once")
CreateConVar("randomat_malfunction_duration", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Duration of gun malfunction (set to 0 for 1 shot)")

function EVENT:Begin()
    local x = 0
    local wep = 0
    timer.Create("RdmtMalfunctionMain", math.random(GetConVar("randomat_malfunction_lower"):GetInt(), GetConVar("randomat_malfunction_upper"):GetInt()), 0, function()
        for _, ply in pairs( self:GetAlivePlayers(true)) do
            if x == 0 or GetConVar("randomat_malfunction_affectall"):GetBool() then
                wep = ply:GetActiveWeapon()
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
        x = 0
        timer.Adjust("RdmtMalfunctionMain", math.random(GetConVar("randomat_malfunction_lower"):GetInt(), GetConVar("randomat_malfunction_upper"):GetInt()))
    end)
end

function EVENT:End()
    timer.Remove("RdmtMalfunctionMain")
    timer.Remove("RdmtMalfunctionActive")
end

Randomat:register(EVENT)