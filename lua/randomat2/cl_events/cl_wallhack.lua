local halo = halo
local hook = hook

local PlayerIterator = player.Iterator

local EVENT = {}
EVENT.id = "wallhack"

local function IsTargetHighlighted(ply, target)
    return ply.IsTargetHighlighted and ply:IsTargetHighlighted(target)
end

function EVENT:Begin()
    local client = LocalPlayer()
    hook.Add("PreDrawHalos", "RdmtWallhackHalos", function()
        local alivePlys = {}
        for k, v in PlayerIterator() do
            if v:Alive() and not v:IsSpec() and not IsTargetHighlighted(client, v) then
                alivePlys[k] = v
            end
        end

        halo.Add(alivePlys, Color(0, 255, 0), 0, 0, 1, true, true)
    end)
end

function EVENT:End()
    hook.Remove("PreDrawHalos", "RdmtWallhackHalos")
end

Randomat:register(EVENT)