local EVENT = {}

CreateConVar("randomat_texplode_timer", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The time before the traitor explodes", 1, 120)
CreateConVar("randomat_texplode_radius", 600, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Radius of the traitor explosion", 50, 1000)

EVENT.Title = ""
EVENT.AltTitle = "A traitor will explode in " .. GetConVar("randomat_texplode_timer"):GetInt() .. " seconds!"
EVENT.ExtDescription = "Chooses a random traitor to explode after a configurable time"
EVENT.id = "texplode"
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

function EVENT:Begin()
    local explodetimer = GetConVar("randomat_texplode_timer"):GetInt()
    Randomat:EventNotifySilent("A traitor will explode in " .. explodetimer .. " seconds!")

    local x = 0
    local tgt = nil
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        if Randomat:IsTraitorTeam(ply) then
            if tgt == nil then
                tgt = ply
                tgt:PrintMessage(HUD_PRINTTALK, "You have been chosen to explode. Watch out, and stay close to innocents.")
            else
                ply:PrintMessage(HUD_PRINTTALK, tgt:Nick() .. " has been chosen to explode. Be careful.")
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
            local pos = nil
            local target_string = "traitor"
            if tgt:Alive() then
                pos = tgt:GetPos()
            else
                local body = tgt.server_ragdoll or tgt:GetRagdollEntity()
                if IsValid(body) then
                    pos = body:GetPos()
                    body:Remove()
                    target_string = "traitor's corpse"
                end
            end

            if pos == nil then
                self:SmallNotify("The traitor's body bomb was destroyed before it could explode! Phew. .. ")
                return
            end

            self:SmallNotify("The " .. target_string .. " has exploded!")
            tgt:EmitSound(Sound("ambient/explosions/explode_4.wav"))
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
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsTraitorTeam(v) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "radius"}) do
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