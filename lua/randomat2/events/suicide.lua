local EVENT = {}

EVENT.Title = "So that's it. What, we're some kind of suicide squad?"
EVENT.Description = "Gives everyone a detonator for a random other player. When that detonator is used, the target player is exploded"
EVENT.AltTitle = "Detonators"
EVENT.id = "suicide"
EVENT.Categories = {"biased", "moderateimpact"}

function EVENT:Begin()
    local plysize = 0
    local plylist = {}

    for _, v in ipairs(self:GetAlivePlayers(true)) do
        plysize = plysize + 1

        plylist[plysize] = {}
        plylist[plysize]["ply"] = v
        plylist[plysize]["tgt"] = v
    end

    for k, _ in pairs(plylist) do
        if plysize > 1 and k < plysize then
            plylist[k]["tgt"] = plylist[k+1]["ply"]
        elseif plysize > 1 then
            plylist[k]["tgt"] = plylist[1]["ply"]
        end

        local ply = plylist[k]["ply"]
        local target = plylist[k]["tgt"]
        timer.Create("RandomatDetTimer_" .. ply:SteamID64(), 1, 5, function()
            ply:PrintMessage(HUD_PRINTCENTER, "You have a detonator for "..target:Nick())
        end)

        -- Delay this
        timer.Simple(0.1, function()
            ply:PrintMessage(HUD_PRINTTALK, "You have a detonator for "..target:Nick())
        end)

        for _, wep in pairs(ply:GetWeapons()) do
            if wep.Kind == WEAPON_EQUIP2 then
                ply:StripWeapon(wep:GetClass())
            end
        end

        local det = ply:Give("weapon_ttt_randomatdet")
        if det then
            det.Target = target
        end
    end
end

function PlayerDetonate(owner, ply)
    if not Randomat:ShouldActLikeJester(owner) then
        local pos = nil
        if ply:Alive() then
            pos = ply:GetPos()
        else
            local body = ply.server_ragdoll or ply:GetRagdollEntity()
            if IsValid(body) then
                pos = body:GetPos()
                body:Remove()
            end
        end

        if pos ~= nil then
            local explode = ents.Create("env_explosion")
            explode:SetPos(pos)
            explode:SetOwner(owner)
            explode:Spawn()
            explode:SetKeyValue("iMagnitude", "230")
            explode:Fire("Explode", 0,0)
            explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
        end
    end
    for _, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, owner:Nick().." has detonated "..ply:Nick())
    end
end

function EVENT:End()
    for _, v in ipairs(player.GetAll()) do
        timer.Remove("RandomatDetTimer_" .. v:SteamID64())
    end
end

Randomat:register(EVENT)