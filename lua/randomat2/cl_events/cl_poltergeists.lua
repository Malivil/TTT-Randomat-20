local plymeta = FindMetaTable("Player")
if not plymeta then return end

local EVENT = {}
EVENT.id = "poltergeists"

local oldCanUseTraitorButton = nil
local function SetupOverride()
    if oldCanUseTraitorButton then return end
    oldCanUseTraitorButton = plymeta.CanUseTraitorButton

    -- Let dead players use traitor buttons
    plymeta.CanUseTraitorButton = function(ply, active_only)
        return not ply:Alive() or ply:IsSpec() or oldCanUseTraitorButton(ply, active_only)
    end

    local client = LocalPlayer()
    -- Render the traitor buttons for dead players
    hook.Add("HUDPaint", "RdmtPoltergeistsHUDPaint", function()
        if not IsValid(client) or (client:Alive() and not client:IsSpec()) then return end

        TBHUD:Draw(client)
    end)

    -- Let dead players activate focused traitor buttons
    hook.Add("PlayerBindPress", "RdmtPoltergeistsPlayerBindPress", function(ply, bind, pressed)
        if not IsValid(ply) or (ply:Alive() and not ply:IsSpec()) then return end

        if bind == "+use" and pressed and TBHUD:PlayerIsFocused() then
            return TBHUD:UseFocused()
        end
    end)
end

EVENT.Begin = SetupOverride

function EVENT:End()
    if oldCanUseTraitorButton then
        plymeta.CanUseTraitorButton = oldCanUseTraitorButton
        oldCanUseTraitorButton = nil
    end
    hook.Remove("HUDPaint", "RdmtPoltergeistsHUDPaint")
    hook.Remove("PlayerBindPress", "RdmtPoltergeistsPlayerBindPress")
end

Randomat:register(EVENT)

hook.Add("InitPostEntity", "RdmtPoltergeistsReady", SetupOverride)