local EVENT = {}
EVENT.id = "fov"

function EVENT:Begin()
    if not IsValid(Randomat.Client) then return end
    if not Randomat.Client.GetActiveWeapon then return end

    local weap = Randomat.Client:GetActiveWeapon()
    if not IsValid(weap) or not weap.GetIronsights or not weap:GetIronsights() then return end

    weap:SetIronsights(false)
    Randomat.Client:SetFOV(0, 0)
end

Randomat:register(EVENT)