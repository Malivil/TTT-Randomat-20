-- Player Effects
function Randomat:HandlePlayerSmoke(client, pred)
    for _, v in ipairs(player.GetAll()) do
        if pred(v) then
            if not v.RdmtSmokeEmitter then v.RdmtSmokeEmitter = ParticleEmitter(v:GetPos()) end
            if not v.RdmtSmokeNextPart then v.RdmtSmokeNextPart = CurTime() end
            local pos = v:GetPos() + Vector(0, 0, 30)
            if v.RdmtSmokeNextPart < CurTime() then
                if client:GetPos():Distance(pos) <= 3000 then
                    v.RdmtSmokeEmitter:SetPos(pos)
                    v.RdmtSmokeNextPart = CurTime() + math.Rand(0.003, 0.01)
                    local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
                    local particle = v.RdmtSmokeEmitter:Add("particle/snow.vmt", v:LocalToWorld(vec))
                    particle:SetVelocity(Vector(0, 0, 4) + VectorRand() * 3)
                    particle:SetDieTime(math.Rand(0.5, 2))
                    particle:SetStartAlpha(math.random(150, 220))
                    particle:SetEndAlpha(0)
                    local size = math.random(4, 7)
                    particle:SetStartSize(size)
                    particle:SetEndSize(size + 1)
                    particle:SetRoll(0)
                    particle:SetRollDelta(0)
                    particle:SetColor(0, 0, 0)
                end
            end
        else
            if v.RdmtSmokeEmitter then
                v.RdmtSmokeEmitter:Finish()
                v.RdmtSmokeEmitter = nil
            end
        end
    end
end

-- UI Functions
local Tex_Corner8 = surface.GetTextureID("gui/corner8")
function Randomat:RoundedMeter(bs, x, y, w, h, color)
    surface.SetDrawColor(color:Unpack())

    surface.DrawRect(x + bs, y, w - bs * 2, h)
    surface.DrawRect(x, y + bs, bs, h - bs * 2)

    surface.SetTexture(Tex_Corner8)
    surface.DrawTexturedRectRotated(x + bs / 2, y + bs / 2, bs, bs, 0)
    surface.DrawTexturedRectRotated(x + bs / 2, y + h - bs / 2, bs, bs, 90)

    if w > 14 then
        surface.DrawRect(x + w - bs, y + bs, bs, h - bs * 2)
        surface.DrawTexturedRectRotated(x + w - bs / 2, y + bs / 2, bs, bs, 270)
        surface.DrawTexturedRectRotated(x + w - bs / 2, y + h - bs / 2, bs, bs, 180)
    else
        surface.DrawRect(x + math.max(w - bs, bs), y, bs / 2, h)
    end
end

function Randomat:PaintBar(r, x, y, w, h, colors, value)
    -- Background
    -- slightly enlarged to make a subtle border
    draw.RoundedBox(8, x - 1, y - 1, w + 2, h + 2, colors.background)

    -- Fill
    local width = w * math.Clamp(value, 0, 1)

    if width > 0 then
        Randomat:RoundedMeter(r, x, y, width, h, colors.fill)
    end
end