local EVENT = {}

EVENT.Title = "Gun Game"
EVENT.Description = "Periodically gives players random weapons that would normally be found throughout the map"
EVENT.id = "gungame"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"item", "moderateimpact"}

CreateConVar("randomat_gungame_timer", 5, FCVAR_NONE, "Time between weapon changes", 5, 60)

function EVENT:Begin()
    local weps = {}
    for _, ent in ents.Iterator() do
        if ent.Base == "weapon_tttbase" and ent.AutoSpawnable then
            ent:Remove()
        end
    end
    for _, wep in ipairs(weapons.GetList()) do
        if wep.AutoSpawnable and (wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL) then
            table.insert(weps, wep)
        end
    end
    timer.Create("RdmtWeaponShuffle", GetConVar("randomat_gungame_timer"):GetInt(), 0, function()
        for _, v in player.Iterator() do
            local ac = false
            if v:GetActiveWeapon().Kind == WEAPON_HEAVY or v:GetActiveWeapon().Kind == WEAPON_PISTOL then
                ac = true
            end
            for _, wep in ipairs(v:GetWeapons()) do
                if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL then
                    v:StripWeapon(wep.ClassName)
                end
            end
            local wepGiven = weps[math.random(#weps)]
            v:Give(wepGiven.ClassName)
            -- Reset FOV to unscope
            v:SetFOV(0, 0.2)

            if ac then
                v:SelectWeapon(wepGiven.ClassName)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtWeaponShuffle")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)