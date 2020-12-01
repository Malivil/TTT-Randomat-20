local function ScalePlayerHeads(mult)
    for _, p in pairs(player.GetAll()) do
        local boneId = p:LookupBone("ValveBiped.Bip01_Head1")
        if boneId == nil then return end

        local scale = Vector(mult, mult, mult)
        p:ManipulateBoneScale(boneId, scale)
    end
end

net.Receive("BigHeadActivate", function()
    ScalePlayerHeads(net.ReadFloat())
end)

net.Receive("BigHeadStop", function()
    ScalePlayerHeads(1)
end)