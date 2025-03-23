local EVENT = {}

CreateConVar("randomat_ransom_traitorsonly", 0, FCVAR_NONE, "Whether to only target Traitors")
CreateConVar("randomat_ransom_deathtimer", 60, FCVAR_NONE, "Seconds a player has to buy something before they die", 10, 180)

EVENT.Title = "Ransomat"
EVENT.id = "ransom"
EVENT.Description = "Choose a random person with a buy menu and force them to buy an item from the shop or else they die"
EVENT.StartSecret  = true
EVENT.Categories = {"biased_innocent", "biased", "moderateimpact"}

local function CanBuy(ply, traitorsonly)
    if not IsValid(ply) then return false end

    if traitorsonly then
        return Randomat:IsTraitorTeam(ply) and ply:GetCredits() > 0
    end
    return Randomat:CanUseShop(ply) and ply:GetCredits() > 0
end

function EVENT:Begin()
    local traitorsonly = GetConVar("randomat_ransom_traitorsonly"):GetBool()
    local target
    -- Find a random player to target
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        if CanBuy(ply, traitorsonly) then
            target = ply
            break
        end
    end

    -- Break if no players found, shouldn't happen thanks to the pre-condition check
    if not target then
        return
    end

    local time = GetConVar("randomat_ransom_deathtimer"):GetInt()
    -- Alert the player they are on a timer
    timer.Create("RdmtRansomNotify", 5, 1, function()
        Randomat:PrintMessage(target, MSG_PRINTBOTH, "Buy something in " .. time .. " seconds or you will die!")

        -- Kill the player after a set time
        timer.Create("RdmtRansomKill", time, 1, function()
            if not IsValid(target) or not target:Alive() or target:IsSpec() then return end
            target:Kill()
        end)

        -- Remove the timer if they bought something
        self:AddHook("TTTOrderedEquipment", function(ply, itme, is_item, fromrdmt)
            if ply ~= target or fromrdmt then return end

            timer.Remove("RdmtRansomKill")
            Randomat:PrintMessage(ply, MSG_PRINTBOTH, "You live... for now!")
        end)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) or not IsValid(target) or victim ~= target then return end
        timer.Remove("RdmtRansomKill")
    end)
end

function EVENT:End()
    timer.Remove("RdmtRansomNotify")
    timer.Remove("RdmtRansomKill")
end

function EVENT:Condition()
    -- "Secret" makes this event kill the target without warning
    if Randomat:IsEventActive("secret") then return false end

    local traitorsonly = GetConVar("randomat_ransom_traitorsonly"):GetBool()
    -- Don't run this event if there aren't any players who are able to buy
    for _, ply in pairs(self:GetAlivePlayers()) do
        if CanBuy(ply, traitorsonly) then
            return true
        end
    end
    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"deathtimer"}) do
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
    for _, v in ipairs({"traitorsonly"}) do
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
