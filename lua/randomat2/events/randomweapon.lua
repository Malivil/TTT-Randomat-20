local EVENT = {}

EVENT.Title = "Try your best..."
EVENT.Description = "Gives each player a random pistol and main weapon that they cannot drop"
EVENT.id = "randomweapon"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"item", "largeimpact"}

function EVENT:Begin()
    local tbl1 = {}
    local tbl2 = {}

    for _, wep in RandomPairs(weapons.GetList()) do
        if wep.AutoSpawnable and wep.Kind == WEAPON_HEAVY then
            table.insert(tbl1, wep)
        end

        if wep.AutoSpawnable and wep.Kind == WEAPON_PISTOL then
            table.insert(tbl2, wep)
        end
    end

    for _, ply in ipairs(self:GetAlivePlayers()) do
        self:HandleWeaponAddAndSelect(ply, function(active_class, active_kind)
            for _, wep in ipairs(ply:GetWeapons()) do
                if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL then
                    ply:StripWeapon(wep:GetClass())
                end
            end

            -- Reset FOV to unscope weapons if they were possibly scoped in
            if active_kind == WEAPON_HEAVY or active_kind == WEAPON_PISTOL then
                ply:SetFOV(0, 0.2)
            end

            local rdmwep1 = table.Random(tbl1)
            local rdmwep2 = table.Random(tbl2)

            local wep1 = ply:Give(rdmwep1.ClassName)
            local wep2 = ply:Give(rdmwep2.ClassName)

            wep1.AllowDrop = false
            wep2.AllowDrop = false
        end)
    end
end

Randomat:register(EVENT)