local EVENT = {}

CreateConVar("randomat_harpoon_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given harpoons")
CreateConVar("randomat_harpoon_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")
CreateConVar("randomat_harpoon_weaponid", "ttt_m9k_harpoon", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")


EVENT.Title = "Harpooooooooooooooooooooon!!"
EVENT.id = "harpoon"

function EVENT:Begin()
    timer.Create("RandomatPoonTimer", GetConVar("randomat_harpoon_timer"):GetInt(), 0, function()
        local weaponid = GetConVar("randomat_harpoon_weaponid"):GetString()
        for _, ply in pairs(self:GetAlivePlayers(true)) do
            for _, wep in pairs(ply:GetWeapons()) do
                local weaponclass = WEPS.GetClass(wep)
                if weaponclass ~= weaponid then
                    ply:StripWeapon(weaponclass)
                end
            end

            if not ply:HasWeapon(weaponid) then
                ply:Give(weaponid)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatPoonTimer")
end

Randomat:register(EVENT)