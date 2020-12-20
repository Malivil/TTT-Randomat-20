local EVENT = {}

CreateConVar("randomat_explode_timer", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The time between explosions.", 5, 60)

EVENT.Title = ""
EVENT.AltTitle = "A Random Person will explode every "..GetConVar("randomat_explode_timer"):GetInt().." seconds! Watch out! (EXCEPT DETECTIVES)"
EVENT.id = "explode"

function EVENT:Begin()
    Randomat:EventNotifySilent("A Random Person will explode every "..GetConVar("randomat_explode_timer"):GetInt().." seconds! Watch out! (EXCEPT DETECTIVES)")

    local effectdata = EffectData()

    timer.Create("RandomatExplode",GetConVar("randomat_explode_timer"):GetInt() ,0, function()
        local plys = {}
        for _, ply in pairs(self:GetAlivePlayers(true)) do
            if ply:GetRole() ~= ROLE_DETECTIVE and ply:GetRole() ~= ROLE_DETRAITOR then
                table.insert(plys, ply)
            end
        end
        local ply = plys[math.random(#plys)]

        if IsValid(ply) then
            self:SmallNotify(ply:Nick() .. " exploded!")
            ply:EmitSound(Sound("ambient/explosions/explode_4.wav"))

            util.BlastDamage(ply, ply, ply:GetPos(), 300, 10000)

            effectdata:SetStart(ply:GetPos() + Vector(0,0,10))
            effectdata:SetOrigin(ply:GetPos() + Vector(0,0,10))
            effectdata:SetScale(1)

            util.Effect("HelicopterMegaBomb", effectdata)
        else
            self:SmallNotify("No one exploded!")
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatExplode")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer"}) do
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