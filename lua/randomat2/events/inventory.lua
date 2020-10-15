local EVENT = {}

EVENT.Title = "Taking Inventory"
EVENT.id = "inventory"

CreateConVar("randomat_inventory_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between inventory swaps")

local function HandleWeapons(ply, weapons, from_killer)
    local had_brainwash = ply:HasWeapon("weapon_hyp_brainwash")
    local active_class = nil
    local active_kind = WEAPON_UNARMED
    if IsValid(ply:GetActiveWeapon()) then
        active_class = WEPS.GetClass(ply:GetActiveWeapon())
        active_kind = WEPS.TypeForWeapon(active_class)
    end
    ply:StripWeapons()

    for _, v in ipairs(weapons) do
        ply:Give(WEPS.GetClass(v))
        ply:SetFOV(0, 0.2)
    end

    -- Have zombies keep their claws and hypnotists keep their brainwashing device
    if ply:IsZombie() then
        ply:Give("weapon_zom_claws")
    elseif had_brainwash then
        ply:Give("weapon_hyp_brainwash")
    end

    -- If the player that swapped to this player was a killer then they no longer have a crowbar
    if from_killer then
        ply:Give("weapon_zm_improvised")
    end

    -- Immediately switch to unarmed to we don't show other players our potentially-illegal first weapon (e.g. Killer's knife)
    ply:SelectWeapon("weapon_ttt_unarmed")

    -- Try to find the correct weapon to select so the transition is less jarring
    local select_class = nil
    for _, w in ipairs(ply:GetWeapons()) do
        local w_class = WEPS.GetClass(w)
        local w_kind = WEPS.TypeForWeapon(w_class)
        if (active_class ~= nil and w_class == active_class) or w_kind == active_kind then
            select_class = w_class
        end
    end

    -- Only try to select a weapon if one was found
    if select_class ~= nil then
        -- Delay seems to be necessary to reliably change weapons after having them all added
        timer.Simple(0.25, function()
            ply:SelectWeapon(select_class)
        end)
    end
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
        HandleWeapons(ply1, ply2:GetWeapons(), ply2:IsKiller())
        HandleWeapons(ply2, ply1weps, ply1:IsKiller())
    end)
end

function EVENT:End()
    timer.Remove("RdmtInventoryTimer")
end

Randomat:register(EVENT)