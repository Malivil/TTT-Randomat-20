local EVENT = {}

EVENT.Title = "Taking Inventory"
EVENT.Description = "Swaps player inventories periodically throughout the round"
EVENT.id = "inventory"

CreateConVar("randomat_inventory_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between inventory swaps")

function EVENT:HandleWeapons(ply, weapons, from_killer)
    local had_brainwash = ply:HasWeapon("weapon_hyp_brainwash")
    self:HandleWeaponAddAndSelect(ply, function()
        ply:StripWeapons()
        -- Reset FOV to unscope
        ply:SetFOV(0, 0.2)

        for _, v in ipairs(weapons) do
            ply:Give(WEPS.GetClass(v))
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

Randomat:register(EVENT)