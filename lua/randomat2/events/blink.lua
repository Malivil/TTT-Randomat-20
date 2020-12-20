local EVENT = {}

EVENT.Title = "Don't. Blink."
EVENT.Description = "Spawns Weeping Angels that follow players around, killing them when their back is turned"
EVENT.id = "blink"

CreateConVar("randomat_blink_cap", 12, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Maximum number of Weeping Angels spawned", 0, 15)
CreateConVar("randomat_blink_delay", 0.5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Delay before Weeping Angels are spawned", 0.1, 2.0)

function EVENT:Begin()
    local cap = GetConVar("randomat_blink_cap"):GetInt()
    local plys = self:GetAlivePlayers()
    local player_index = 1
    local count = 0
    timer.Create("AngelTimer", GetConVar("randomat_blink_delay"):GetFloat(), 0, function()
        if plys[player_index] ~= nil then
            -- Get the first alive player
            local ply = plys[player_index]
            while not ply:Alive() or ply:IsSpec() do
                player_index = player_index + 1
                ply = plys[player_index]
            end

            -- Spawn an Angel if we have a cap and we haven't bypassed it
            if count < cap or cap == 0 then
                local ent = ents.Create("weepingangel")
                ent:SetPos(ply:GetAimVector())
                ent:Spawn()
                ent:Activate()

                ent:SetVictim(ply)
                ent:DropToFloor()
                count = count + 1
            end

            -- Move to the next player
            player_index = player_index + 1
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"cap", "delay"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "delay" and 1 or 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)