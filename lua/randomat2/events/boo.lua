local EVENT = {}

util.AddNetworkString("RdmtBooBegin")
util.AddNetworkString("RdmtBooEnd")

CreateConVar("randomat_boo_charge_time", 30, FCVAR_NONE, "How many seconds it takes to charge the next attack", 10, 120)
CreateConVar("randomat_boo_ghost_time", 5, FCVAR_NONE, "How many seconds the ghost lasts", 1, 30)

EVENT.Title = "Boo!"
EVENT.Description = "Allows dead players to scare their target and make them drop their weapon"
EVENT.id = "boo"
EVENT.Type = EVENT_TYPE_SPECTATOR_UI
EVENT.Categories = {"spectator", "moderateimpact"}

local timers = {}
local ghosts = {}
function EVENT:Begin()
    timers = {}
    ghosts = {}
    for _, p in player.Iterator() do
        p:SetNWInt("RdmtBooPower", 0)
        if not p:Alive() or p:IsSpec() then
            net.Start("RdmtBooBegin")
            net.Send(p)
        end
    end

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        net.Start("RdmtBooEnd")
        net.Send(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        net.Start("RdmtBooBegin")
        net.Send(victim)
    end)

    local ghost_time = GetConVar("randomat_boo_ghost_time"):GetInt()
    self:AddHook("KeyPress", function(ply, key)
        if key == IN_JUMP and ply:GetNWInt("RdmtBooPower", 0) == 100 then
            local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil
            if IsPlayer(target) then
                -- Reset the player's power
                ply:SetNWInt("RdmtBooPower", 0)

                -- Make the target drop their weapon
                target:DropWeapon()
                -- Reset FOV to unscope
                target:SetFOV(0, 0.2)

                -- Create and deploy ghost
                local ghost = ents.Create("npc_kleiner")
                ghost:SetModel(ply:GetModel())

                local pos = target:GetPos()
                local ang = target:GetAngles()
                ghost:SetPos(pos + ang:Forward() * 40)
                ghost:SetAngles(-ang)
                ghost:SetNotSolid(true)
                ghost:SetColor(Color(245, 245, 245, 100))
                ghost:SetRenderMode(RENDERMODE_GLOW)
                ghost:AddFlags(FL_NOTARGET)
                ghost:Spawn()
                table.insert(ghosts, ghost)

                Randomat:PrintMessage(target, MSG_PRINTCENTER, "Boo!")

                -- Keep track of the ghost timer
                local id = "RdmtBooGhostTimer_" .. ply:SteamID64() .. "_" .. target:SteamID64()
                timers[id] = true

                -- Remove ghost after the timer
                timer.Create(id, ghost_time, 1, function()
                    if IsValid(ghost) then
                        ghost:Remove()
                    end
                end)
            end
        end
    end)

    local tick = GetConVar("randomat_boo_charge_time"):GetInt() / 100
    timer.Create("RdmtBooPowerTimer", tick, 0, function()
        for _, p in ipairs(self:GetDeadPlayers(false, true)) do
            local power = p:GetNWInt("RdmtBooPower", 0)
            if power < 100 then
                p:SetNWInt("RdmtBooPower", power + 1)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtBooPowerTimer")
    for id, _ in pairs(timers) do
        timer.Remove(id)
    end
    for _, ghost in ipairs(ghosts) do
        if IsValid(ghost) then
            ghost:Remove()
        end
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"charge_time", "ghost_time"}) do
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