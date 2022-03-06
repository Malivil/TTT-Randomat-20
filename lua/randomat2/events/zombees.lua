local EVENT = {}

CreateConVar("randomat_zombees_count", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of bees spawned per player", 1, 10)

EVENT.Title = "Zom-Bees!"
EVENT.Description = "Spawns bees who spread zombiism to their victims"
EVENT.id = "zombees"
EVENT.Categories = {"rolechange", "biased", "largeimpact"}

function EVENT:Begin()
    Randomat:SilentTriggerEvent("bees", self.owner, Color(70, 100, 25, 255), GetConVar("randomat_zombees_count"):GetInt())
    Randomat:SilentTriggerEvent("grave", self.owner, "npc_manhack")
end

function EVENT:Condition()
    return Randomat:CanEventRun("bees") and Randomat:CanEventRun("grave")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"count"}) do
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