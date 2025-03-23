local EVENT = {}

CreateConVar("randomat_zombees_count", 1, FCVAR_NONE, "The number of bees spawned per player", 1, 10)

EVENT.Title = "Zom-Bees!"
EVENT.Description = "Spawns bees who spread zombiism to their victims"
EVENT.id = "zombees"
EVENT.Categories = {"rolechange", "biased_zombie", "biased", "largeimpact"}

local function IsBee(ent)
    if ent:GetClass() == "npc_manhack" then
        local children = ent:GetChildren()
        if children then
            for _, c in ipairs(children) do
                if c:GetClass() == "prop_dynamic" and string.find(c:GetModel(), "bee") then
                    return true
                end
            end
        end
    end
    return false
end

function EVENT:Begin()
    Randomat:SilentTriggerEvent("bees", self.owner, Color(70, 100, 25, 255), GetConVar("randomat_zombees_count"):GetInt())
    Randomat:SilentTriggerEvent("grave", self.owner, "npc_manhack")

    local nextRelationshipUpdate = CurTime()
    self:AddHook("Think", function()
        if CurTime() < nextRelationshipUpdate then return end

        nextRelationshipUpdate = CurTime() + 0.08
        for _, ent in ipairs(ents.FindByClass("npc_manhack")) do
            if IsBee(ent) then
                for _, ply in ipairs(self:GetAlivePlayers()) do
                    if ply:IsZombie() or (ply.IsZombieAlly and ply:IsZombieAlly()) then
                        ent:AddEntityRelationship(ply, D_LI, 99)
                    elseif Randomat:IsJesterTeam(ply) then
                        ent:AddEntityRelationship(ply, D_NU, 99)
                    else
                        ent:AddEntityRelationship(ply, D_HT, 99)
                    end
                end
            end
        end
    end)
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