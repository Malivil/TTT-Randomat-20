local EVENT = {}

CreateConVar("randomat_ransom_traitorsonly", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to only target Traitors")
CreateConVar("randomat_ransom_deathtimer", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds a player has to buy something before they die", 10, 180)

EVENT.Title = "Ransomat"
EVENT.id = "ransom"
EVENT.Description = "Choose a random person with a buy menu and force them to buy an item from the shop or else they die"
EVENT.StartSecret  = true

local function CanBuy(ply)
    if GetConVar("randomat_ransom_traitorsonly"):GetBool() then
        return (ply:GetRole() == ROLE_TRAITOR or (CR_VERSION and ply:IsTraitorTeam())) and ply:GetCredits() > 0
    end
    return ply:IsValid() and Randomat:IsShopRole(ply) and ply:GetCredits() > 0
end

function EVENT:Begin()
    local p
    -- build a list of eligible players to target
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        if GetConVar("randomat_ransom_traitorsonly"):GetBool() then
            if ply:IsValid() and Randomat:IsTraitorTeam(ply) and ply:GetCredits() > 0 then
                p = ply
                break
            end
        elseif CanBuy(ply) then
            p = ply
            break
        end
    end
    -- break if no players found, shouldn't happen thanks to self:Condition
    if not p then
        return
    end

    local time = GetConVar("randomat_ransom_deathtimer"):GetInt()
    -- alert the player they are on a timer
    timer.Create("RdmtRansomedNotify",3,1, function()
        p:PrintMessage(HUD_PRINTTALK, "Buy something in "..time.." seconds or you will die!")
        p:PrintMessage(HUD_PRINTCENTER, "Buy something in "..time.." seconds or you will die!")
    end)
    -- kill the player after a set time
    timer.Create("RdmtTimeToBuy",time,1, function()
        p:Kill()
    end)
    -- remove the timer if they bought something
    hook.Add("TTTOrderedEquipment", "RandomatRansomEquiptment", function()
        timer.Remove("RdmtRansomedNotify")
        timer.Remove("RdmtTimeToBuy")
        p:PrintMessage(HUD_PRINTTALK, "You live for now!")
        p:PrintMessage(HUD_PRINTCENTER, "You live for now!")
    end)
    SendFullStateUpdate()
end

function EVENT:End()
    timer.Remove("RdmtRansomedNotify")
    timer.Remove("RdmtTimeToBuy")
end

function EVENT:Condition()
    -- Don't run this event if there aren't any players who are able to buy
    for _, ply in pairs(self:GetAlivePlayers(true)) do
        if CanBuy(ply) then
            return true
        end
    end
    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"DeathTimer"}) do
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
    for _, v in ipairs({"TraitorsOnly"}) do
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