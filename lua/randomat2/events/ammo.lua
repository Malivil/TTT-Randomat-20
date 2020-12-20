local EVENT = {}

EVENT.Title = "Infinite Ammo!"
EVENT.id = "ammo"

CreateConVar("randomat_ammo_affectbuymenu", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether it gives buy menu weapons infinite ammo too.")

function EVENT:Begin()
    self:AddHook("Think", function()
        for _, v in pairs(self:GetAlivePlayers()) do
            if not v:GetActiveWeapon().CanBuy or GetConVar("randomat_ammo_affectbuymenu"):GetBool() then
                v:GetActiveWeapon():SetClip1(v:GetActiveWeapon().Primary.ClipSize)
            end
        end
    end)
end

function EVENT:Condition()
    return not Randomat:IsEventActive("reload") and not Randomat:IsEventActive("prophunt") and not Randomat:IsEventActive("harpoon") and not Randomat:IsEventActive("slam")
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in pairs({"affectbuymenu"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return {}, checks
end

Randomat:register(EVENT)