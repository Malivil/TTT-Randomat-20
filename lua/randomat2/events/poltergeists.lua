local plymeta = FindMetaTable("Player")
if not plymeta then return end

local EVENT = {}

util.AddNetworkString("RdmtPoltergeistsBegin")
util.AddNetworkString("RdmtPoltergeistsEnd")
util.AddNetworkString("RdmtPoltergeistsClientReady")

EVENT.Title = "Poltergeists"
EVENT.Description = "Allows dead players to see and activate traitor traps"
EVENT.id = "poltergeists"

local oldCanUseTraitorButton = nil

function EVENT:Begin()
    if not oldCanUseTraitorButton then
        oldCanUseTraitorButton = plymeta.CanUseTraitorButton

        -- Let dead players use traitor buttons
        plymeta.CanUseTraitorButton = function(ply, active_only)
            return not ply:Alive() or ply:IsSpec() or oldCanUseTraitorButton(ply, active_only)
        end
    end

    net.Start("RdmtPoltergeistsBegin")
    net.Broadcast()

    -- This handles the case where a client loads in after the event has already started
    -- It requires this back-and-forth because only the client knows when it's fully loaded
    -- and only the server knows if the event is running already.
    net.Receive("RdmtPoltergeistsClientReady", function()
        local ply = net.ReadEntity()
        net.Start("RdmtPoltergeistsBegin")
        net.Send(ply)
    end)
end

function EVENT:End()
    if oldCanUseTraitorButton then
        plymeta.CanUseTraitorButton = oldCanUseTraitorButton
        oldCanUseTraitorButton = nil
    end

    net.Start("RdmtPoltergeistsEnd")
    net.Broadcast()
end

function EVENT:Condition()
    -- Only run this if we can overwrite the function that makes it all work
    return type(plymeta.CanUseTraitorButton) == "function"
end

Randomat:register(EVENT)