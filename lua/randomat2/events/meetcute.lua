local EVENT = {}

local meetcute_distance = CreateConVar("randomat_meetcute_distance", 1400, FCVAR_NONE, "The distance to be considered 'touching'", 250, 5000)
local meetcute_swap_delay = CreateConVar("randomat_meetcute_swap_delay", 5, FCVAR_NONE, "Minimum delay between swaps", 1, 60)

EVENT.Title = "Meet Cute"
EVENT.Description = "Causes players who collide while sprinting to swap inventories"
EVENT.id = "meetcute"
EVENT.Categories = {"item", "smallimpact"}

function EVENT:Begin()
    for _, p in ipairs(self:GetPlayers()) do
        p:SetCustomCollisionCheck(true)
    end

    local sprint_state = {}
    self:AddHook("TTTSpeedMultiplier", function(ply, mults, sprinting)
        if not IsPlayer(ply) then return end
        sprint_state[ply:SteamID64()] = sprinting
    end)

    local distance = meetcute_distance:GetInt()
    local swap_delay = meetcute_swap_delay:GetInt()
    local last_swap = {}
    self:AddHook("ShouldCollide", function(ent1, ent2)
        if not IsPlayer(ent1) then return end
        if not IsPlayer(ent2) then return end

        local ent1_sid64 = ent1:SteamID64()
        local ent2_sid64 = ent2:SteamID64()
        -- Both players have to be sprinting
        if not sprint_state[ent1_sid64] or not sprint_state[ent2_sid64] then return end

        -- and they have to be close enough to at least look like they are touching
        if ent1:GetPos():DistToSqr(ent2:GetPos()) > distance then return end

        -- Don't swap if either player already swapped recently
        if last_swap[ent1_sid64] and (CurTime() - last_swap[ent1_sid64]) < swap_delay then return end
        if last_swap[ent2_sid64] and (CurTime() - last_swap[ent2_sid64]) < swap_delay then return end

        -- Save this time so they don't get swapped again too soon
        last_swap[ent1_sid64] = CurTime()
        last_swap[ent2_sid64] = CurTime()

        local ent1weps = ent1:GetWeapons()
        self:SwapWeapons(ent1, ent2:GetWeapons())
        self:SwapWeapons(ent2, ent1weps)
    end)
end

function EVENT:End()
    for _, p in ipairs(self:GetPlayers()) do
        p:SetCustomCollisionCheck(false)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"distance", "swap_delay"}) do
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