-- Effects
function Randomat:HandleEntitySmoke(tbl, client, pred, color, max_dist, min_size, max_size)
    if not max_dist then
        max_dist = 3000
    end

    for _, v in ipairs(tbl) do
        if pred(v) then
            if not v.RdmtSmokeEmitter then v.RdmtSmokeEmitter = ParticleEmitter(v:GetPos()) end
            if not v.RdmtSmokeNextPart then v.RdmtSmokeNextPart = CurTime() end
            local pos = v:GetPos() + Vector(0, 0, 30)
            if v.RdmtSmokeNextPart < CurTime() then
                if client:GetPos():Distance(pos) <= max_dist then
                    v.RdmtSmokeEmitter:SetPos(pos)
                    v.RdmtSmokeNextPart = CurTime() + math.Rand(0.003, 0.01)
                    local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
                    local particle = v.RdmtSmokeEmitter:Add("particle/snow.vmt", v:LocalToWorld(vec))
                    particle:SetVelocity(Vector(0, 0, 4) + VectorRand() * 3)
                    particle:SetDieTime(math.Rand(0.5, 2))
                    particle:SetStartAlpha(math.random(150, 220))
                    particle:SetEndAlpha(0)
                    local size = math.random(min_size or 4, max_size or 7)
                    particle:SetStartSize(size)
                    particle:SetEndSize(size + 1)
                    particle:SetRoll(0)
                    particle:SetRollDelta(0)
                    if color then
                        local r, g, b, _ = color:Unpack()
                        particle:SetColor(r, g, b)
                    else
                        particle:SetColor(0, 0, 0)
                    end
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

function Randomat:HandlePlayerSmoke(client, pred, color, max_dist)
    Randomat:HandleEntitySmoke(player.GetAll(), client, pred, color, max_dist)
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
    draw.RoundedBox(r, x - 1, y - 1, w + 2, h + 2, colors.background)

    -- Fill
    local width = w * math.Clamp(value, 0, 1)

    if width > 0 then
        Randomat:RoundedMeter(r, x, y, width, h, colors.fill)
    end
end

-- Weapon Functions
function Randomat:GetItemName(item, role)
    local id = tonumber(item)
    local info = GetEquipmentItemById and GetEquipmentItemById(id) or GetEquipmentItem(role, id)
    return info and LANG.TryTranslation(info.name) or item
end

function Randomat:GetWeaponName(item)
    for _, v in ipairs(weapons.GetList()) do
        if item == WEPS.GetClass(v) then
            return LANG.TryTranslation(v.PrintName)
        end
    end

    return item
end