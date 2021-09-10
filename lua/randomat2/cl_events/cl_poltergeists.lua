local plymeta = FindMetaTable("Player")
if not plymeta then return end

local oldCanUseTraitorButton = nil
net.Receive("RdmtPoltergeistsBegin", function()
    if not oldCanUseTraitorButton then
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
end)

net.Receive("RdmtPoltergeistsEnd", function()
    if oldCanUseTraitorButton then
        plymeta.CanUseTraitorButton = oldCanUseTraitorButton
        oldCanUseTraitorButton = nil
    end
    hook.Remove("HUDPaint", "RdmtPoltergeistsHUDPaint")
    hook.Remove("PlayerBindPress", "RdmtPoltergeistsPlayerBindPress")
end)

hook.Add("InitPostEntity", "RdmtPoltergeistsReady", function()
    net.Start("RdmtPoltergeistsClientReady")
    net.SendToServer()
end)