local EVENT = {}

CreateConVar("randomat_huntingseason_delay", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The delay before the player changes", 1, 60)
CreateConVar("randomat_huntingseason_show_name", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show the target player's name in the event title", 1, 60)

EVENT.Title = ""
EVENT.AltTitle = "It's hunting season!"
EVENT.Description = "Randomly turns a vanilla Innocent into an active Loot Goblin"
EVENT.id = "huntingseason"
EVENT.Categories = {"biased_innocent", "mediumimpact"}

local transform_timer_default = nil
local transform_timer_default_max = nil

function EVENT:Begin()
    -- Update this in case the role names have been changed
    EVENT.Description = "Randomly turns a vanilla " .. Randomat:GetRoleString(ROLE_INNOCENT) .. " into an active " .. Randomat:GetRoleString(ROLE_LOOTGOBLIN)

    -- Change the transform time min and max to match the event convar
    local tranform_delay = GetConVar("randomat_huntingseason_delay"):GetInt()
    local transform_timer = GetConVar("ttt_lootgoblin_activation_timer")
    transform_timer_default = transform_timer:GetInt()
    transform_timer:SetInt(tranform_delay)

    local transform_timer_max = GetConVar("ttt_lootgoblin_activation_timer_max")
    transform_timer_default_max = transform_timer_max:GetInt()
    transform_timer_max:SetInt(tranform_delay)

    -- Choose a random vanilla innocent to transform
    timer.Create("RdmtHuntingSeason", 0.1, 1, function()
        local innocents = {}
        for _, p in ipairs(self:GetAlivePlayers(true)) do
            if p:IsInnocent() then
                table.insert(innocents, p)
            end
        end

        local target = innocents[math.random(#innocents)]
        Randomat:SetRole(target, ROLE_LOOTGOBLIN)
        SendFullStateUpdate()

        -- Update the title to include the player's name if we're configured to do so
        if GetConVar("randomat_huntingseason_show_name"):GetBool() then
            self.AltTitle = "It's " .. target:Nick() .. " hunting season!"
        else
            self.AltTitle = "It's hunting season!"
        end

        if not self.Silent then
            Randomat:EventNotifySilent(self.AltTitle)
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtHuntingSeason")

    if transform_timer_default ~= nil then
        GetConVar("ttt_lootgoblin_activation_timer"):SetInt(transform_timer_default)
        transform_timer_default = nil
    end

    if transform_timer_default_max ~= nil then
        GetConVar("ttt_lootgoblin_activation_timer_max"):SetInt(transform_timer_default_max)
        transform_timer_default_max = nil
    end
end

function EVENT:Condition()
    -- The Loot Goblin role is only available in the new CR
    if not CR_VERSION then return false end

    local vanilla_innocent = 0
    local innocent = 0
    for _, p in ipairs(player.GetAll()) do
        -- Don't run if there is already a Loot Goblin this round
        if p:IsLootGoblin() then
            return false
        -- Count the living innocents
        elseif Randomat:IsInnocentTeam(p) and p:Alive() and not p:IsSpec() then
            innocent = innocent + 1
            if p:IsInnocent() then
                vanilla_innocent = vanilla_innocent + 1
            end
        end
    end

    -- Only run this if we have a vanilla Innocent and they aren't the last one on their team
    return vanilla_innocent > 0 and innocent > vanilla_innocent
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"delay"}) do
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
    for _, v in ipairs({"show_name"}) do
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