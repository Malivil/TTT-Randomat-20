local EVENT = {}

EVENT.Title = "Taking Inventory"
EVENT.Description = "Swaps player inventories periodically throughout the round"
EVENT.id = "inventory"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"item", "moderateimpact"}

CreateConVar("randomat_inventory_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between inventory swaps", 5, 60)

function EVENT:Begin()
    local ply1 = nil
    local ply2 = nil
    timer.Create("RdmtInventoryTimer", GetConVar("randomat_inventory_timer"):GetInt(), 0, function()
        local x = 0
        for _, v in ipairs(self:GetAlivePlayers(true)) do
            -- Skip non-prime zombies since they only have claws
            if v:GetRole() ~= ROLE_ZOMBIE or (v.IsZombiePrime and v:IsZombiePrime()) then
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
        self:SwapWeapons(ply1, ply2:GetWeapons())
        self:SwapWeapons(ply2, ply1weps)
    end)
end

function EVENT:End()
    timer.Remove("RdmtInventoryTimer")
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