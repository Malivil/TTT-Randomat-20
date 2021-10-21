local last_hurt_time = CurTime()
local last_sprint_meter = 100

local function IsSprinting(ply)
    local sprintMeter = ply:GetNWFloat("sprintMeter", 100)
    local sprinting = false
    if sprintMeter < last_sprint_meter then
        sprinting = true
    end

    last_sprint_meter = sprintMeter
    return sprinting
end

net.Receive("RandomatRunForYourLifeStart", function()
    local ply = LocalPlayer()
    if ply == nil or not IsValid(ply) then return end

    local delay = net.ReadFloat()
    hook.Add("Think", ply:Nick() .. "RunForYourLifeThink", function()
        if ply == nil or not IsValid(ply) or not ply:Alive() then return end
        if Randomat:ShouldActLikeJester(ply) then return end

        if (last_hurt_time + delay) < CurTime() and IsSprinting(ply) then
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