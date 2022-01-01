net.Receive("OppositeDayBegin", function()
    local hardmode = net.ReadBool()
    hook.Add("StartCommand", "RdmtOppositeCommandHook", function(ply, cmd)
        -- Make the player move the opposite direction
        cmd:SetForwardMove(-cmd:GetForwardMove())
        cmd:SetSideMove(-cmd:GetSideMove())

        -- Attack reloads, reload attacks
        if cmd:KeyDown(IN_ATTACK) then
            cmd:RemoveKey(IN_ATTACK)
            cmd:SetButtons(cmd:GetButtons() + IN_RELOAD)
        elseif cmd:KeyDown(IN_RELOAD) then
            cmd:RemoveKey(IN_RELOAD)
            cmd:SetButtons(cmd:GetButtons() + IN_ATTACK)
        -- If hard mode is enabled then reverse jump and duck too
        elseif hardmode then
            if cmd:KeyDown(IN_JUMP) then
                cmd:RemoveKey(IN_JUMP)
                cmd:SetButtons(cmd:GetButtons() + IN_DUCK)
            elseif cmd:KeyDown(IN_DUCK) then
                cmd:RemoveKey(IN_DUCK)
                cmd:SetButtons(cmd:GetButtons() + IN_JUMP)
            end
        end
    end)

    -- Override the sprint key so players can sprint forward while holding the back key
    hook.Add("TTTSprintKey", "RdmtOppositeSprintKeyHook", function(ply)
        return IN_BACK
    end)
end)

net.Receive("OppositeDayEnd", function()
    hook.Remove("StartCommand", "RdmtOppositeCommandHook")
    hook.Remove("TTTSprintKey", "RdmtOppositeSprintKeyHook")
end)