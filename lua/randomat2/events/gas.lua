local EVENT = {}

CreateConVar("randomat_gas_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Changes the time between grenade drops", 5, 60)
CreateConVar("randomat_gas_affectall", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set to 1 for the event to drop a grenade at everyone's feet on trigger")
CreateConVar("randomat_gas_discombob", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether discombobs drop")
CreateConVar("randomat_gas_incendiary", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether incendiaries drop")
CreateConVar("randomat_gas_smoke", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether smokes drop")

EVENT.Title = "Bad Gas"
EVENT.Description = "Drops grenades at random players feet periodically"
EVENT.id = "gas"

function EVENT:Begin()
    local potatoTable = {}
    if GetConVar("randomat_gas_discombob"):GetBool() then
        potatoTable[1] = "ttt_confgrenade_proj"
    end
    if GetConVar("randomat_gas_smoke"):GetBool() then
        potatoTable[2] = "ttt_smokegrenade_proj"
    end
    if GetConVar("randomat_gas_incendiary"):GetBool() then
        potatoTable[3] = "ttt_firegrenade_proj"
    end

    timer.Create("gastimer", GetConVar("randomat_gas_timer"):GetInt() , 0, function()
        local x = 0
        for _, ply in pairs( self:GetAlivePlayers(true)) do
            if x == 0 or GetConVar("randomat_gas_affectall"):GetBool() then
                local gren = ents.Create(potatoTable[math.random(#potatoTable)])
                if not IsValid(gren) then return end
                gren:SetPos(ply:GetPos())
                gren:SetOwner(ply)
                gren:SetThrower(ply)
                gren:SetGravity(0.4)
                gren:SetFriction(0.2)
                gren:SetElasticity(0.45)
                gren:Spawn()
                gren:PhysWake()
                gren:SetDetonateExact(1)
                x = 1
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("gastimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer"}) do
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

    local checks = {}
    for _, v in pairs({"affectall", "discombob", "incendiary", "smoke"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return sliders, checks
end

Randomat:register(EVENT)