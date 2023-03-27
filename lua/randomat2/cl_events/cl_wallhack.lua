local halo = halo
local hook = hook
local net = net

local GetAllPlayers = player.GetAll

local function IsTargetHighlighted(ply, target)
    return ply.IsTargetHighlighted and ply:IsTargetHighlighted(target)
end

net.Receive("RdmtWallhackStart", function()
    local client = LocalPlayer()
    hook.Add("PreDrawHalos", "RdmtWallhackHalos", function()
        local alivePlys = {}
        for k, v in ipairs(GetAllPlayers()) do
            if v:Alive() and not v:IsSpec() and not IsTargetHighlighted(client, v) then
                alivePlys[k] = v
            end
        end

        halo.Add(alivePlys, Color(0, 255, 0), 0, 0, 1, true, true)
    end)
end)

net.Receive("RdmtWallhackEnd", function()
    hook.Remove("PreDrawHalos", "RdmtWallhackHalos")
end)