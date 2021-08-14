local EVENT = {}

util.AddNetworkString("RdmtSmokeSignalsBegin")
util.AddNetworkString("RdmtSmokeSignalsAdd")
util.AddNetworkString("RdmtSmokeSignalsRemove")
util.AddNetworkString("RdmtSmokeSignalsEnd")

CreateConVar("randomat_smoke_charge_time", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many seconds it takes to charge the next attack", 10, 120)
CreateConVar("randomat_smoke_time", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many seconds the smoke lasts", 1, 30)

EVENT.Title = "Smoke Signals"
EVENT.Description = "Allows dead players to envelope their target in smoke"
EVENT.id = "smoke"
EVENT.Type = EVENT_TYPE_SPECTATOR_UI

local timers = {}
function EVENT:Begin()
    timers = {}
    for _, p in ipairs(player.GetAll()) do
        p:SetNWInt("RdmtSmokeSignalsPower", 0)
        if not p:Alive() or p:IsSpec() then
            net.Start("RdmtSmokeSignalsBegin")
            net.Send(p)
        end
    end

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        net.Start("RdmtSmokeSignalsEnd")
        net.Send(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        net.Start("RdmtSmokeSignalsBegin")
        net.Send(victim)
    end)

    local time = GetConVar("randomat_smoke_time"):GetInt()
    self:AddHook("KeyPress", function(ply, key)
        if key == IN_JUMP and ply:GetNWInt("RdmtSmokeSignalsPower", 0) == 100 then
            local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil
            if IsValid(target) and target:IsPlayer() then
                -- Reset the player's power
                ply:SetNWInt("RdmtSmokeSignalsPower", 0)

                -- Start the target smoking
                net.Start("RdmtSmokeSignalsAdd")
                net.WriteString(target:SteamID64())
                net.Broadcast()

                -- Keep track of the smoke timer
                local id = "RdmtSmokeSignalsSmokeTimer_" .. ply:SteamID64() .. "_" .. target:SteamID64()
                timers[id] = true

                -- Remove smoke after the timer
                timer.Create(id, time, 1, function()
                    net.Start("RdmtSmokeSignalsRemove")
                    net.WriteString(target:SteamID64())
                    net.Broadcast()
                end)
            end
        end
    end)

    local tick = GetConVar("randomat_smoke_charge_time"):GetInt() / 100
    timer.Create("RdmtSmokeSignalsPowerTimer", tick, 0, function()
        for _, p in ipairs(self:GetDeadPlayers()) do
            local power = p:GetNWInt("RdmtSmokeSignalsPower", 0)
            if power < 100 then
                p:SetNWInt("RdmtSmokeSignalsPower", power + 1)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtSmokeSignalsPowerTimer")
    for id, _ in pairs(timers) do
        timer.Remove(id)
    end
    net.Start("RdmtSmokeSignalsEnd")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"charge_time", "time"}) do
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