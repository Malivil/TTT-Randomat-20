local EVENT = {}
EVENT.id = "tunnelvision"

local viewPct
local function DrawCircle(x, y, radius, seg)
    local cir = {}
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
    end
    surface.DrawPoly(cir)
end

local function DrawScreen(startTime, final, duration, out, onEnd)
    -- Reset everything to known good
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(0)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()

    -- Enable stencils
    render.SetStencilEnable(true)
    -- Set everything up so it draws to the stencil buffer instead of the screen
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)

    draw.NoTexture()
    surface.SetDrawColor(COLOR_WHITE)
    local pct
    if not out then
        pct = math.min(final, (CurTime() - startTime) / duration)
        if pct >= final and type(onEnd) == "function" then
            onEnd()
        end
    else
        pct = math.max(final, viewPct - ((CurTime() - startTime) / duration))
        if pct <= final and type(onEnd) == "function" then
            onEnd()
        end
    end
    DrawCircle(ScrW() / 2, ScrH() / 2, ScrH() - (ScrH() * pct), 100)

    -- Only draw things that are not in the stencil buffer
    render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)

        -- Draw the background
    surface.SetDrawColor(COLOR_BLACK)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Let everything render normally again
    render.SetStencilEnable(false)
end

function EVENT:End()
    local hookTable = hook.GetTable()
    if not hookTable["HUDPaint"] or not hookTable["HUDPaint"]["RdmtTunnelVisionHUDPaint"] then return end

    -- Fade out the tunnel vision
    local startTime = CurTime()
    hook.Add("HUDPaint", "RdmtTunnelVisionHUDPaint", function()
        DrawScreen(startTime, 0, 10, true, function()
            hook.Remove("HUDPaint", "RdmtTunnelVisionHUDPaint")
            viewPct = nil
        end)
    end)
end

Randomat:register(EVENT)

net.Receive("TriggerTunnelVision", function()
    viewPct = (100 - net.ReadUInt(7)) / 100
    local startTime = CurTime()
    -- Fade in the tunnel vision
    hook.Add("HUDPaint", "RdmtTunnelVisionHUDPaint", function()
        DrawScreen(startTime, viewPct, 10)
    end)
end)