local EVENT = {}

CreateConVar("randomat_highground_damage", 1, FCVAR_NONE, "The amount of health the player will lose each interval", 1, 100)
CreateConVar("randomat_highground_damage_delay", 10, FCVAR_NONE, "The delay before damage starts", 1, 60)
CreateConVar("randomat_highground_damage_interval", 2, FCVAR_NONE, "How often the player will take damage", 1, 60)

EVENT.Title = "It's over Anakin! I have the high ground!"
EVENT.Description = "Does damage over time to the player who is closest to the ground"
EVENT.id = "highground"
EVENT.Categories = {"biased_innocent", "smallimpact"}

function EVENT:Begin()
    local damage = GetConVar("randomat_highground_damage"):GetInt()
    local delay = GetConVar("randomat_highground_damage_delay"):GetInt()
    local interval = GetConVar("randomat_highground_damage_interval"):GetInt()
    local adjusted = false
    timer.Create("RdmtHighGroundDamage", delay, 0, function()
        if not adjusted then
            adjusted = true
            timer.Adjust("RdmtHighGroundDamage", interval)
        end

        local lowest_ply = nil
        local lowest_z = math.huge
        -- Randomize this so if multiple players are at the same Z, it will choose one randomly
        for _, ply in ipairs(self:GetAlivePlayers(true)) do
            local pos = ply:GetPos()
            if pos.z < lowest_z then
                lowest_z = pos.z
                lowest_ply = ply
            end
        end

        if not IsPlayer(lowest_ply) then return end

        local dmginfo = DamageInfo()
        dmginfo:SetDamage(damage)
        dmginfo:SetAttacker(game.GetWorld())
        dmginfo:SetInflictor(game.GetWorld())
        dmginfo:SetDamageType(DMG_BULLET)
        dmginfo:SetDamageForce(Vector(0, 0, 0))
        lowest_ply:TakeDamageInfo(dmginfo)

        Randomat:PrintMessage(lowest_ply, MSG_PRINTCENTER, "You're taking damage because you're the closest to the ground!")
    end)
end

function EVENT:End()
    timer.Remove("RdmtHighGroundDamage")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"damage", "damage_delay", "damage_interval"}) do
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