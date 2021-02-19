local EVENT = {}

EVENT.Title = "Taking Inventory"
EVENT.Description = "Swaps player inventories periodically throughout the round"
EVENT.id = "inventory"

CreateConVar("randomat_inventory_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between inventory swaps", 5, 60)

function EVENT:HandleWeapons(ply, weapons, from_killer)
    local had_brainwash = ply:HasWeapon("weapon_hyp_brainwash")
    local had_scanner = ply:HasWeapon("weapon_ttt_wtester")
    self:HandleWeaponAddAndSelect(ply, function()
        ply:StripWeapons()
        -- Reset FOV to unscope
        ply:SetFOV(0, 0.2)

        -- Have Zombies keep their claws, Hypnotists keep their brainwashing device, and Detective/Detraitors keep their DNA Scanners
        if ply:IsZombie() then
            ply:Give("weapon_zom_claws")
        elseif had_brainwash then
            ply:Give("weapon_hyp_brainwash")
        elseif had_scanner then
            ply:Give("weapon_ttt_wtester")
        end

        -- If the player that swapped to this player was a killer then they no longer have a crowbar
        if from_killer then
            ply:Give("weapon_zm_improvised")
        end

        -- Handle inventory weapons last to make sure the roles get their specials
        for _, v in ipairs(weapons) do
            local wep_class = WEPS.GetClass(v)
            -- Don't give players the detective's tester
            if wep_class ~= "weapon_ttt_wtester" then
                ply:Give(wep_class)
            end
        end

        -- Immediately switch to unarmed to we don't show other players our potentially-illegal first weapon (e.g. Killer's knife)
        ply:SelectWeapon("weapon_ttt_unarmed")
    end)
end

function EVENT:Begin()
    local ply1 = nil
    local ply2 = nil
    timer.Create("RdmtInventoryTimer", GetConVar("randomat_inventory_timer"):GetInt(), 0, function()
        local x = 0
        for _, v in pairs(self:GetAlivePlayers(true)) do
            -- Skip non-prime zombies since they only have claws
            if not v:IsZombie() or v:IsZombiePrime() then
                x = x + 1
                if x == 1 then
                    ply1 = v
                elseif x == 2 then
                    ply2 = v
                end
            end
        end

        if ply1 == nil or ply2 == nil then return end

        local ply1weps = ply1:GetWeapons()
        self:HandleWeapons(ply1, ply2:GetWeapons(), ply2:IsKiller())
        self:HandleWeapons(ply2, ply1weps, ply1:IsKiller())
    end)
end

function EVENT:End()
    timer.Remove("RdmtInventoryTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer"}) do
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