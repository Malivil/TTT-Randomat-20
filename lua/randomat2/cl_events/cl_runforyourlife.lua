local last_hurt_time = CurTime()
net.Receive("RandomatRunForYourLifeStart", function()
    local ply = LocalPlayer()
    if ply == nil or not IsValid(ply) then return end

    local delay = net.ReadFloat()
    hook.Add("Think", ply:Nick() .. "RunForYourLifeThink", function()
        if ply == nil or not IsValid(ply) or not ply:Alive() then return end
        if Randomat:IsJesterTeam(ply) then return end

        local mul = hook.Call("TTTPlayerSpeedModifier", GAMEMODE, ply, false, nil) or 1
        if mul > 1 and last_hurt_time + delay < CurTime() then
            last_hurt_time = CurTime()
            net.Start("RandomatRunForYourLifeDamage")
            net.WriteEntity(ply)
            net.SendToServer()
        end
    end)
end)

net.Receive("RandomatRunForYourLifeEnd", function()
    local ply = LocalPlayer()
    if ply == nil or not IsValid(ply) then return end
    hook.Remove("Think", ply:Nick() .. "RunForYourLifeThink")
end)