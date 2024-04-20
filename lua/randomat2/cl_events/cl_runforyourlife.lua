local last_hurt_time = CurTime()
local last_stamina = 100

net.Receive("RandomatRunForYourLifeStart", function()
    local delay = net.ReadFloat()
    hook.Add("TTTSprintStaminaPost", "RdmtRunForYourLifeTTTSprintStaminaPost", function(ply, stamina, sprintTimer, consumption)
        if ply == nil or not IsValid(ply) or not ply:Alive() then return end
        if Randomat:ShouldActLikeJester(ply) then return end
        if stamina < last_stamina and (last_hurt_time + delay) < CurTime() then
            last_hurt_time = CurTime()
            net.Start("RandomatRunForYourLifeDamage")
            net.WritePlayer(ply)
            net.WriteFloat(last_hurt_time)
            net.SendToServer()
        end
        last_stamina = stamina
    end)
end)

net.Receive("RandomatRunForYourLifeEnd", function()
    hook.Remove("TTTSprintStaminaPost", "RdmtRunForYourLifeTTTSprintStaminaPost")
end)