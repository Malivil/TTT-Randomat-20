local EVENT = {}

CreateConVar("randomat_doubleedge_interval", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often (in seconds) to heal self-damage", 1, 60)
CreateConVar("randomat_doubleedge_amount", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How much self-damage to heal per interval", 1, 20)

EVENT.Title = "Double-Edged Sword"
EVENT.Description = "Reflects 1/2 of the damage you do back on yourself, but you also heal self-damage slowly"
EVENT.id = "doubleedge"

local self_damage = {}
local last_heal = {}

function EVENT:Begin()
    for _, v in ipairs(self:GetAlivePlayers()) do
        self_damage[v:SteamID64()] = 0
        last_heal[v:SteamID64()] = nil
    end

    local interval = GetConVar("randomat_doubleedge_interval"):GetInt()
    local amount = GetConVar("randomat_doubleedge_amount"):GetInt()
    self:AddHook("Think", function()
        for sid, dmg in pairs(self_damage) do
            if dmg > 0 and (last_heal[sid] == nil or (CurTime() - last_heal[sid]) > interval) then
                local ply = player.GetBySteamID64(sid)
                if IsValid(ply) and ply:Alive() then
                    -- Heal whichever is less, the tick amount or the damage left
                    local heal = math.min(dmg, amount)
                    local hp = ply:Health()
                    local newhp = hp + heal
                    ply:SetHealth(newhp)

                    -- Update the heal tracking
                    last_heal[sid] = CurTime()
                    self_damage[sid] = dmg - heal
                end
            end
        end
    end)

    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        local att = dmginfo:GetAttacker()
        if not IsValid(att) or not att:IsPlayer() then return end
        local dmg = dmginfo:GetDamage()

        -- Save self damage
        if ent == att then
            self_damage[att:SteamID64()] = self_damage[att:SteamID64()] + dmg
        -- Scale the damage done by half and save that
        else
            local scaled_dmg = math.floor(dmg / 2)
            local health = att:Health() - scaled_dmg

            -- If they don't have enough health, just kill them
            if health <= 0 then
                att:Kill()
            -- Otherwise hurt them and keep track of how much
            else
                self_damage[att:SteamID64()] = self_damage[att:SteamID64()] + scaled_dmg
                att:SetHealth(health)
            end
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        self_damage[ply:SteamID64()] = 0
        last_heal[ply:SteamID64()] = nil
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"interval", "amount"}) do
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