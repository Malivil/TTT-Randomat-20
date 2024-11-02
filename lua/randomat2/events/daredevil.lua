local EVENT = {}

local min_damage_scale = CreateConVar("randomat_daredevil_min_damage_scale", 1, FCVAR_ARCHIVE, "", 0, 1)
local max_damage_scale = CreateConVar("randomat_daredevil_max_damage_scale", 2.5, FCVAR_ARCHIVE, "", 1.1, 5)

EVENT.Title = "Daredevil"
EVENT.Description = "Scale a player's damage up the faster they move (including falling)"
EVENT.id = "daredevil"
EVENT.Categories = {"moderateimpact"}

local baseVelocity = 48400

function EVENT:Begin()
    local lastVelocity = {}
    self:AddHook("FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        lastVelocity[ply:SteamID64()] = math.ceil(ply:GetVelocity():LengthSqr())
    end)

    local minScale = min_damage_scale:GetFloat()
    local maxScale = max_damage_scale:GetFloat()

    -- Sanity check
    if minScale > maxScale then
        minScale = maxScale
    end

    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        local atk = dmginfo:GetAttacker()
        if not IsPlayer(atk) or not atk:Alive() or atk:IsSpec() then return end
        local sid64 = atk:SteamID64()
        if not lastVelocity[sid64] then return end

        local velocity = lastVelocity[sid64]
        local scale = velocity / baseVelocity
        scale = math.Clamp(scale, minScale, maxScale)
        dmginfo:ScaleDamage(scale)
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"min_damage_scale", "max_damage_scale"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)