local EVENT = {}

EVENT.Title = "The 'bar has been raised!"
EVENT.Description = "Increases the damage and push force of the crowbar"
EVENT.id = "crowbar"
EVENT.SingleUse = false
EVENT.Categories = {"smallimpact"}

CreateConVar("randomat_crowbar_damage", 2.5, FCVAR_NONE, "Damage multiplier for the crowbar", 1.1, 3.0)
CreateConVar("randomat_crowbar_push", 20, FCVAR_NONE, "Push force multiplier for the crowbar", 5, 50)

local original_push = nil
function EVENT:Begin()
    if original_push == nil then
        original_push = GetConVar("ttt_crowbar_pushforce"):GetInt()
    end
    local current_push = GetConVar("ttt_crowbar_pushforce"):GetInt()
    RunConsoleCommand("ttt_crowbar_pushforce", current_push * GetConVar("randomat_crowbar_push"):GetFloat())

    local damage = GetConVar("randomat_crowbar_damage"):GetFloat()
    for _, v in player.Iterator() do
        for _, wep in ipairs(v:GetWeapons()) do
            if wep:GetClass() == "weapon_zm_improvised" then
                if wep.Primary.OriginalDamage == nil then
                    wep.Primary.OriginalDamage = wep.Primary.Damage
                end
                wep.Primary.Damage = wep.Primary.Damage * damage
            end
        end
    end
end

function EVENT:End()
    if original_push ~= nil then
        RunConsoleCommand("ttt_crowbar_pushforce", original_push)
    end
    for _, v in player.Iterator() do
        for _, wep in ipairs(v:GetWeapons()) do
            if wep:GetClass() == "weapon_zm_improvised" and wep.Primary.OriginalDamage ~= nil then
                wep.Primary.Damage = wep.Primary.OriginalDamage
            end
        end
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"damage", "push"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "damage" and 1 or 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)