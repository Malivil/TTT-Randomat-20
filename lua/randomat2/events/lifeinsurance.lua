local EVENT = {}

local lifeinsurance_first_traitor = CreateConVar("randomat_lifeinsurance_first_traitor", 0, FCVAR_NONE, "Whether only first traitor death pays", 0, 1)
local lifeinsurance_first_per_player = CreateConVar("randomat_lifeinsurance_first_per_player", 1, FCVAR_NONE, "Whether only first death per player pays", 0, 1)
local lifeinsurance_payment = CreateConVar("randomat_lifeinsurance_payment", 3, FCVAR_NONE, "Amount of credits to pay", 1, 10)

EVENT.Title = "Life Insurance"
EVENT.Description = "Traitors get credits when one of their teammates is killed"
EVENT.id = "lifeinsurance"
EVENT.Categories = {"biased_traitor", "biased", "deathtrigger", "moderateimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description = Randomat:GetRolePluralString(ROLE_TRAITOR) .. " get credits when one of their teammates is killed"
end

function EVENT:Begin()
    self:AddHook("PostPlayerDeath", function(ply)
        if not IsPlayer(ply) then return end
        if not Randomat:IsTraitorTeam(ply) then return end
        if ply.RdmtLifeInsurancePaid and lifeinsurance_first_per_player:GetBool() then return end

        ply.RdmtLifeInsurancePaid = true

        for _, p in ipairs(self:GetAlivePlayers()) do
            if Randomat:IsTraitorTeam(p) then
                local credits = lifeinsurance_payment:GetInt()
                p:AddCredits(credits)

                Randomat:PrintMessage(p, MSG_PRINTBOTH, "Congratulations! You have been awarded an insurance payout of " .. credits .. " credits due to the death of " .. ply:Nick() .. "!")
            end
        end

        if lifeinsurance_first_traitor:GetBool() then
            self:RemoveHook("PostPlayerDeath")
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"payment"}) do
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
    for _, v in ipairs({"first_traitor", "first_per_player"}) do
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