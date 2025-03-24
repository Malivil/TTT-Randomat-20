local EVENT = {}

util.AddNetworkString("RdmtSpecBuffBegin")
util.AddNetworkString("RdmtSpecBuffEnd")
util.AddNetworkString("RdmtSpecBuffHealStart")
util.AddNetworkString("RdmtSpecBuffHealEnd")

CreateConVar("randomat_specbuff_charge_time", 60, FCVAR_NONE, "How many seconds it takes to charge to full power", 10, 120)
CreateConVar("randomat_specbuff_heal_power", 75, FCVAR_NONE, "The amount of power to heal the target", 1, 100)
CreateConVar("randomat_specbuff_heal_amount", 10, FCVAR_NONE, "The amount of to heal the target", 1, 100)
CreateConVar("randomat_specbuff_fast_power", 35, FCVAR_NONE, "The amount of power to make the target faster", 1, 100)
CreateConVar("randomat_specbuff_fast_factor", 1.3, FCVAR_NONE, "The speed factor for target when fast", 1.1, 2)
CreateConVar("randomat_specbuff_fast_timer", 3, FCVAR_NONE, "How long the effect lasts", 1, 60)
CreateConVar("randomat_specbuff_slow_power", 35, FCVAR_NONE, "The amount of power to slow the target", 1, 100)
CreateConVar("randomat_specbuff_slow_factor", 0.7, FCVAR_NONE, "The speed factor for target when slow", 0.1, 0.9)
CreateConVar("randomat_specbuff_slow_timer", 3, FCVAR_NONE, "How long the effect lasts", 1, 60)
CreateConVar("randomat_specbuff_slap_power", 75, FCVAR_NONE, "The amount of power to slap the target", 1, 100)
CreateConVar("randomat_specbuff_slap_force", 500, FCVAR_NONE, "How hard to slap the target", 250, 1000)

EVENT.Title = "Paranormal Activity"
EVENT.Description = "Allows the dead to buff or debuff their targets"
EVENT.id = "specbuff"
EVENT.Type = {EVENT_TYPE_SPECTATOR_UI, EVENT_TYPE_SMOKING}
EVENT.Categories = {"spectator", "largeimpact"}

local timers = {}
local slow_players = {}
local fast_players = {}
function EVENT:Begin()
    local heal_power = GetConVar("randomat_specbuff_heal_power"):GetInt()
    local heal_amount = GetConVar("randomat_specbuff_heal_amount"):GetInt()
    local fast_power = GetConVar("randomat_specbuff_fast_power"):GetInt()
    local fast_factor = GetConVar("randomat_specbuff_fast_factor"):GetFloat()
    local fast_timer = GetConVar("randomat_specbuff_fast_timer"):GetInt()
    local slow_power = GetConVar("randomat_specbuff_slow_power"):GetInt()
    local slow_factor = GetConVar("randomat_specbuff_slow_factor"):GetFloat()
    local slow_timer = GetConVar("randomat_specbuff_slow_timer"):GetInt()
    local slap_power = 0
    local slap_force = GetConVar("randomat_specbuff_slap_force"):GetInt()
    if ULib and ULib.slap then
        slap_power = GetConVar("randomat_specbuff_slap_power"):GetInt()
    end

    timers = {}
    slow_players = {}
    fast_players = {}
    for _, p in player.Iterator() do
        p:SetNWInt("RdmtSpecBuffPower", 0)
        if not p:Alive() or p:IsSpec() then
            net.Start("RdmtSpecBuffBegin")
            net.WriteUInt(heal_power, 8)
            net.WriteUInt(fast_power, 8)
            net.WriteUInt(slow_power, 8)
            net.WriteUInt(slap_power, 8)
            net.Send(p)
        end
    end

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        net.Start("RdmtSpecBuffEnd")
        net.Send(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        net.Start("RdmtSpecBuffBegin")
        net.WriteUInt(heal_power, 8)
        net.WriteUInt(fast_power, 8)
        net.WriteUInt(slow_power, 8)
        net.WriteUInt(slap_power, 8)
        net.Send(victim)
    end)

    self:AddHook("KeyPress", function(ply, key)
        local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil
        if not IsPlayer(target) then return end

        local target_sid = target:SteamID64()
        local ply_sid = ply:SteamID64()
        local power = ply:GetNWInt("RdmtSpecBuffPower", 0)
        local spent = 0
        local verb
        if key == IN_FORWARD and power >= fast_power then
            local timer_id = "RdmtSpecBuffFastTimer_" .. ply_sid .. "_" .. target_sid
            if timer.Exists(timer_id) then return end

            timers[timer_id] = true

            local speed_id = "RdmtSpecBuffFastSpeed_" .. ply_sid .. "_" .. target_sid
            net.Start("RdmtSetSpeedMultiplier")
            net.WriteFloat(fast_factor)
            net.WriteString(speed_id)
            net.Send(target)

            if not fast_players[target_sid] then
                fast_players[target_sid] = 0
            end
            fast_players[target_sid] = fast_players[target_sid] + 1

            timer.Create(timer_id, fast_timer, 1, function()
                timer.Remove(timer_id)
                net.Start("RdmtRemoveSpeedMultiplier")
                net.WriteString(speed_id)
                net.Send(target)

                fast_players[target_sid] = fast_players[target_sid] - 1
            end)

            spent = fast_power
            verb = "hastened"
        elseif key == IN_BACK and power >= slow_power then
            local timer_id = "RdmtSpecBuffSlowTimer_" .. ply_sid .. "_" .. target_sid
            if timer.Exists(timer_id) then return end

            timers[timer_id] = true

            local speed_id = "RdmtSpecBuffSlowSpeed_" .. ply_sid .. "_" .. target_sid
            net.Start("RdmtSetSpeedMultiplier")
            net.WriteFloat(slow_factor)
            net.WriteString(speed_id)
            net.Send(target)

            if not slow_players[target_sid] then
                slow_players[target_sid] = 0
            end
            slow_players[target_sid] = slow_players[target_sid] + 1

            timer.Create(timer_id, slow_timer, 1, function()
                timer.Remove(timer_id)
                net.Start("RdmtRemoveSpeedMultiplier")
                net.WriteString(speed_id)
                net.Send(target)

                slow_players[target_sid] = slow_players[target_sid] - 1
            end)

            spent = slow_power
            verb = "slowed"
        elseif key == IN_MOVELEFT and power >= heal_power then
            local timer_id = "RdmtSpecBuffHealTimer_" .. ply_sid .. "_" .. target_sid
            if timer.Exists(timer_id) then return end

            timers[timer_id] = true

            net.Start("RdmtSpecBuffHealStart")
            net.WriteUInt64(target:SteamID64())
            net.Broadcast()

            timer.Create(timer_id, 1, heal_amount, function()
                if target:Alive() and not target:IsSpec() then
                    local hp = target:Health()
                    if hp < target:GetMaxHealth() then
                        target:SetHealth(hp + 1)
                    end
                end
            end)

            timers[timer_id .. "_Smoke"] = true
            timer.Create(timer_id .. "_Smoke", heal_amount, 1, function()
                timer.Remove(timer_id)
                timer.Remove(timer_id .. "_Smoke")
                net.Start("RdmtSpecBuffHealEnd")
                net.WriteUInt64(target:SteamID64())
                net.Broadcast()
            end)

            spent = heal_power
            verb = "healed"
        elseif key == IN_MOVERIGHT and power >= slap_power then
            ULib.slap(target, 0, slap_force, spent)
            spent = slap_power
            verb = "slapped"
        end

        if spent > 0 then
            Randomat:PrintMessage(ply, MSG_PRINTBOTH, "You have " .. verb .. " your target, " .. target:Nick())
            Randomat:PrintMessage(target, MSG_PRINTBOTH, "A ghost has " .. verb .. " you")

            -- Update the player's power
            ply:SetNWInt("RdmtSpecBuffPower", power - spent)
        end
    end)

    self:AddHook("TTTSpeedMultiplier", function(ply, mults)
        if not ply:Alive() or ply:IsSpec() then return end
        local sid = ply:SteamID64()
        local speed_factor = 1
        if slow_players[sid] and slow_players[sid] > 0 then
            speed_factor = speed_factor * (slow_factor * slow_players[sid])
        end
        if fast_players[sid] and fast_players[sid] > 0 then
            speed_factor = speed_factor * (fast_factor * fast_players[sid])
        end

        if speed_factor ~= 1 then
            table.insert(mults, speed_factor)
        end
    end)

    local tick = GetConVar("randomat_specbuff_charge_time"):GetInt() / 100
    timer.Create("RdmtSpecBuffPowerTimer", tick, 0, function()
        for _, p in ipairs(self:GetDeadPlayers(false, true)) do
            local power = p:GetNWInt("RdmtSpecBuffPower", 0)
            if power < 100 then
                p:SetNWInt("RdmtSpecBuffPower", power + 1)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtSpecBuffPowerTimer")
    for id, _ in pairs(timers) do
        timer.Remove(id)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"charge_time", "heal_power", "heal_amount", "fast_power", "fast_timer", "slow_power", "slow_timer", "slap_power", "slap_force"}) do
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
    for _, v in ipairs({"fast_factor", "slow_factor"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 1
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)