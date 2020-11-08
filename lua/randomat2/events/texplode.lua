local EVENT = {}

CreateConVar("randomat_texplode_timer", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The time before the traitor explodes")
CreateConVar("randomat_texplode_radius", 600, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Radius of the traitor explosion")

EVENT.Title = ""
EVENT.AltTitle = "A traitor will explode in "..GetConVar("randomat_texplode_timer"):GetInt().." seconds!"
EVENT.id = "texplode"

function EVENT:Begin()
    local explodetimer = GetConVar("randomat_texplode_timer"):GetInt()
    Randomat:EventNotifySilent("A traitor will explode in "..explodetimer.." seconds!")

    local x = 0
    local tgt = nil
    for _, ply in pairs(self:GetAlivePlayers(true)) do
        if ply:GetRole() == ROLE_TRAITOR or ply:GetRole() == ROLE_HYPNOTIST or ply:GetRole() == ROLE_ASSASSIN or ply:GetRole() == ROLE_DETRAITOR then
            if tgt == nil then
                tgt = ply
                tgt:PrintMessage(HUD_PRINTTALK, "You have been chosen to explode. Watch out, and stay close to innocents.")
            else
                ply:PrintMessage(HUD_PRINTTALK, tgt:Nick().." has been chosen to explode. Be careful.")
            end
        end
    end

    local effectdata = EffectData()

    timer.Create("RandomatTraitorExplode", 1, explodetimer, function()
        x = x+1
        if explodetimer >= 45 and x == explodetimer - 30 then
            self:SmallNotify("30 seconds until the traitor explodes!")
        elseif explodetimer >= 20 and x == explodetimer - 10 then
            self:SmallNotify("10 seconds remaining!")
        elseif x == explodetimer then
            self:SmallNotify("The traitor has exploded!")
            tgt:EmitSound(Sound("ambient/explosions/explode_4.wav"))

            local pos = nil
            if tgt:Alive() then
                pos = tgt:GetPos()
            else
                local body = tgt.server_ragdoll or tgt:GetRagdollEntity()
                if IsValid(body) then
                    pos = body:GetPos()
                    body:Remove()
                end
            end

            util.BlastDamage(tgt, tgt, pos, GetConVar("randomat_texplode_radius"):GetInt(), 10000)

            effectdata:SetStart(pos + Vector(0,0,10))
            effectdata:SetOrigin(pos + Vector(0,0,10))
            effectdata:SetScale(1)

            util.Effect("HelicopterMegaBomb", effectdata)
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatTraitorExplode")
end

function EVENT:Condition()
    local t = 0
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:Alive() and (v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_DETRAITOR) then
            t = t+1
        end
    end

    if t > 1 then
        return true
    else
        return false
    end
end

Randomat:register(EVENT)