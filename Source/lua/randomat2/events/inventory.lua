local EVENT = {}

EVENT.Title = "Taking Inventory"
EVENT.id = "inventory"

CreateConVar("randomat_inventory_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between inventory swaps")

function EVENT:Begin()
    local ply1 = nil
    local ply2 = nil
    timer.Create("RdmtInventoryTimer", GetConVar("randomat_inventory_timer"):GetInt(), 0, function()
        local x = 0
        for _, v in pairs(self:GetAlivePlayers(true)) do
            -- Skip non-prime zombies since they only have claws
            if v:GetRole() ~= ROLE_ZOMBIE or v:IsZombiePrime() then
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
        ply1:StripWeapons()
        -- Have zombies keep their claws
        if ply1:GetRole() == ROLE_ZOMBIE then
            ply1:Give("weapon_zom_claws")
        end

        for _, v in pairs(ply2:GetWeapons()) do
            ply1:Give(v.ClassName)
            ply1:SetFOV(0, 0.2)
        end

        ply2:StripWeapons()
        -- Have zombies keep their claws
        if ply2:GetRole() == ROLE_ZOMBIE then
            ply2:Give("weapon_zom_claws")
        end

        for _, v in pairs(ply1weps) do
            ply2:Give(v.ClassName)
            ply2:SetFOV(0, 0.2)
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtInventoryTimer")
end

Randomat:register(EVENT)