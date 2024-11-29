local plymeta = FindMetaTable("Player")
if not plymeta then return end

local EVENT = {}

EVENT.Title = "Poltergeists"
EVENT.Description = "Allows dead players to see and activate traitor traps"
EVENT.id = "poltergeists"
EVENT.Categories = {"spectator", "moderateimpact"}

local oldCanUseTraitorButton = nil

function EVENT:Begin()
    if oldCanUseTraitorButton then return end
    oldCanUseTraitorButton = plymeta.CanUseTraitorButton

    -- Let dead players use traitor buttons
    plymeta.CanUseTraitorButton = function(ply, active_only)
        return not ply:Alive() or ply:IsSpec() or oldCanUseTraitorButton(ply, active_only)
    end
end

function EVENT:End()
    if oldCanUseTraitorButton then
        plymeta.CanUseTraitorButton = oldCanUseTraitorButton
        oldCanUseTraitorButton = nil
    end
end

function EVENT:Condition()
    -- Only run this if we can overwrite the function that makes it all work and there are traitor buttons on this map
    return type(plymeta.CanUseTraitorButton) == "function" and #ents.FindByClass("ttt_traitor_button") > 0
end

Randomat:register(EVENT)