local EVENT = {}

CreateConVar("randomat_harpoon_timer", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given harpoons")
CreateConVar("randomat_harpoon_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")
CreateConVar("randomat_harpoon_weaponid", "ttt_m9k_harpoon", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")


EVENT.Title = "Harpooooooooooooooooooooon!!"
EVENT.id = "harpoon"

function EVENT:Begin()
    timer.Create("RandomatPoonTimer", GetConVar("randomat_harpoon_timer"):GetInt(), 0, function()
        for i, ply in pairs(self:GetAlivePlayers(true)) do
            if table.Count(ply:GetWeapons()) ~= 1 or (table.Count(ply:GetWeapons()) == 1 and ply:GetActiveWeapon():GetClass() ~= "ttt_m9k_harpoon") then
                if GetConVar("randomat_harpoon_strip"):GetBool() then
                    ply:StripWeapons()
                end
                ply:Give(GetConVar("randomat_harpoon_weaponid"):GetString())
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatPoonTimer")
end

Randomat:register(EVENT)