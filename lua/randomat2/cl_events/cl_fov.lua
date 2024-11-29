local EVENT = {}
EVENT.id = "fov"

function EVENT:Begin()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    if not client.GetActiveWeapon then return end

    local weap = client:GetActiveWeapon()
    if not IsValid(weap) or not weap.GetIronsights or not weap:GetIronsights() then return end

    weap:SetIronsights(false)
    client:SetFOV(0, 0)
end

Randomat:register(EVENT)