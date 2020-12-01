local function ScalePlayerHead(mult)
    local client = LocalPlayer()
    if not IsValid(client) then return end

    local boneId = client:LookupBone("ValveBiped.Bip01_Head1")
    if boneId == nil then return end

    local scale = Vector(mult, mult, mult)
    client:ManipulateBoneScale(boneId, scale)
end

net.Receive("BigHeadActivate", function()
    ScalePlayerHead(net.ReadFloat())
end)

net.Receive("BigHeadStop", function()
    ScalePlayerHead(1)
end)