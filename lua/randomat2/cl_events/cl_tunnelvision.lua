local EVENT = {}
EVENT.id = "tunnelvision"

function EVENT:End()
    hook.Remove("HUDPaint", "RdmtTunnelVisionHUDPaint")
end

Randomat:register(EVENT)

local function DrawCircle(x, y, radius, seg)
    local cir = {}
    for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
	end
    surface.DrawPoly(cir)
end

net.Receive("TriggerTunnelVision", function()
    local viewpct = 100 - net.ReadUInt(7)
    local client = LocalPlayer()
    hook.Add("HUDPaint", "RdmtTunnelVisionHUDPaint", function()
        if not IsValid(client) or not client:Alive() or client:IsSpec() then return end

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
        DrawCircle(ScrW() / 2, ScrH() / 2, ScrH() - (ScrH() * (viewpct / 100)), 100)

        -- Only draw things that are not in the stencil buffer
        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        render.SetStencilFailOperation(STENCIL_KEEP)

         -- Draw the background
        surface.SetDrawColor(COLOR_BLACK)
        surface.DrawRect(0, 0, ScrW(), ScrH())

        -- Let everything render normally again
        render.SetStencilEnable(false)
    end)
end)