Randomat.Events = Randomat.Events or {}
Randomat.ActiveEvents = Randomat.ActiveEvents or {}

--[[
 Event Registration
]]--

function Randomat:register(tbl)
    local id = tbl.id or tbl.Id
    tbl.Id = id
    tbl.id = id
    Randomat.Events[id] = tbl

    if type(tbl.Initialize) == "function" then
        tbl:Initialize()
    end
end

function Randomat:unregister(id)
    if not Randomat.Events[id] then return end
    Randomat.Events[id] = nil
end

--[[
 Event Tracking
]]--

local show_count = CreateClientConVar("cl_randomat_show_active", "1", true, false, "Whether to show the active Randomat count on the HUD", 0, 1)

local allow_client_list = GetConVar("ttt_randomat_allow_client_list")

local function EndEvent(evt)
    if not evt then return end

    local function End()
        if type(evt.End) ~= "function" then return end
        evt:End()
    end
    local function Catch(err)
        ErrorNoHalt("WARNING: Randomat event '" .. evt.Id .. "' caused an error when it was being Ended. Please report to the addon developer with the following error:\n", err, "\n")
    end
    xpcall(End, Catch)
end

net.Receive("RdmtEventBegin", function()
    local id = net.ReadString()
    local title = net.ReadString()
    local desc = net.ReadString()
    table.insert(Randomat.ActiveEvents, {
        id = id,
        Id = id,
        title = title,
        desc = desc
    })

    local event = Randomat.Events[id]
    if not event then return end

    if type(event.Begin) == "function" then
        event:Begin()
    end
end)

net.Receive("RdmtEventEnd", function()
    local id = net.ReadString()
    -- Remove the first instance of this event from the list
    for i, e in ipairs(Randomat.ActiveEvents) do
        if e.id == id then
            table.remove(Randomat.ActiveEvents, i)
            break
        end
    end

    EndEvent(Randomat.Events[id])
end)

local function ClearActiveEvents()
    table.Empty(Randomat.ActiveEvents)
    Randomat.ActiveEvents = {}
end

hook.Add("TTTEndRound", "RandomatEndRound", ClearActiveEvents)
hook.Add("TTTPrepareRound", "RandomatPrepareRound", function()
    -- End ALL events rather than just active ones to prevent some event effects which maintain over map changes
    for _, v in pairs(Randomat.Events) do
        EndEvent(v)
    end
    ClearActiveEvents()
end)
hook.Add("ShutDown", "RandomatMapChange", ClearActiveEvents)

hook.Add("Initialize", "RandomatEventTrackingInitialize", function()
    LANG.AddToLanguage("english", "rdmt_count_hud", "{count} Randomat events active")
end)

local icon_tex = Material("icon16/rdmt.png")
hook.Add("TTTHUDInfoPaint", "RandomatEventTrackingHUDInfoPaint", function(client, label_left, label_top, active_labels)
    if not show_count:GetBool() then return end
    if not allow_client_list:GetBool() then return end

    surface.SetFont("TabLarge")
    surface.SetTextColor(255, 255, 255, 230)

    local text = LANG.GetParamTranslation("rdmt_count_hud", { count = #Randomat.ActiveEvents })
    local _, h = surface.GetTextSize(text)

    -- Move this up based on how many other labels here are
    if active_labels then
        label_top = label_top + (20 * #active_labels)
    else
        label_top = label_top + 20
    end

    local icon_x, icon_y = 16, 16
    surface.SetMaterial(icon_tex)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(label_left, ScrH() - label_top - icon_y, icon_x, icon_y)

    label_left = label_left + 20
    surface.SetTextPos(label_left, ScrH() - label_top - h)
    surface.DrawText(text)

    -- Track that the label was added so others can position accurately
    if active_labels then
        table.insert(active_labels, "rdmt_count")
    end
end)

local expandState = false
hook.Add("TTTSettingsTabs", "RandomatEventTrackingTTTSettingsTabs", function(dtabs)
    if not allow_client_list:GetBool() then return end
    local padding = dtabs:GetPadding()
    padding = padding * 2

    local drdmt = vgui.Create("DPanelList", dtabs)
    drdmt:StretchToParent(0, 0, padding, 0)
    drdmt:EnableVerticalScrollbar()
    drdmt:SetPadding(10)
    drdmt:SetSpacing(10)

    -- Settings section -- only show when there is actually a setting to use (e.g. new CR for TTT only)
    if CR_VERSION then
        local dsettings = vgui.Create("DForm", drdmt)
        dsettings:SetName("Randomat Client Settings")
        dsettings:CheckBox("Show active Randomat count on UI", "cl_randomat_show_active")
        drdmt:AddItem(dsettings)
    end

    -- Active Events section
    local dactive = vgui.Create("DForm", drdmt)
    dactive:SetName("Active Randomat Events")
    dactive:SetExpanded(expandState)
    -- Keep track of the expanded state so you don't have to open it multiple times
    dactive.OnToggle = function(panel, state)
        expandState = state
    end
    drdmt:AddItem(dactive)

    local dactivecount = vgui.Create("DLabel", dactive)
    dactivecount:SetText("Active Randomat Count: " .. #Randomat.ActiveEvents)
    dactivecount:SetTextColor(Color(0, 0, 0, 255))
    dactive:AddItem(dactivecount)

    for i, e in ipairs(Randomat.ActiveEvents) do
        local dtitle = vgui.Create("DLabel", dactive)
        dtitle:SetFont("DermaDefaultBold")
        dtitle:SetText(i .. ". " .. e.title)
        dtitle:SetTextColor(Color(0, 0, 0, 255))
        dactive:AddItem(dtitle)

        if #e.desc > 0 then
            local ddesc = vgui.Create("DLabel", dactive)
            ddesc:SetText(e.desc)
            ddesc:SetTextColor(Color(0, 0, 0, 255))
            dactive:AddItem(ddesc)
        end
    end

    dtabs:AddSheet("Randomat", drdmt, "icon16/rdmt.png", false, false, "Randomat Settings and Info")
end)

--[[
 Weapon/Item Names
]]--

net.Receive("alerteventtrigger", function()
    local event = net.ReadString()
    local item = net.ReadString()
    local role_string = net.ReadString()
    local is_item = net.ReadUInt(32)
    local role = net.ReadInt(16)
    local name
    if is_item == 0 then
        name = Randomat:GetWeaponName(item)
    else
        name = Randomat:GetItemName(item, role)
    end

    net.Start("AlertTriggerFinal")
    net.WriteString(event)
    net.WriteString(name)
    net.WriteString(role_string)
    net.SendToServer()
end)

--[[
 Player Speed
]]--

local current_mults = {}
local current_mults_withweapon = {}
local current_mults_sprinting = {}
net.Receive("RdmtSetSpeedMultiplier", function()
    local mult = net.ReadFloat()
    local key = net.ReadString()
    current_mults[key] = mult
end)

net.Receive("RdmtSetSpeedMultiplier_WithWeapon", function()
    local mult = net.ReadFloat()
    local key = net.ReadString()
    local wep_class = net.ReadString()
    current_mults_withweapon[key] = {
        wep_class = wep_class,
        mult = mult
    }
end)

net.Receive("RdmtSetSpeedMultiplier_Sprinting", function()
    local mult = net.ReadFloat()
    local key = net.ReadString()
    current_mults_sprinting[key] = mult
end)

net.Receive("RdmtRemoveSpeedMultiplier", function()
    local key = net.ReadString()
    current_mults[key] = nil
    current_mults_withweapon[key] = nil
    current_mults_sprinting[key] = nil
end)

net.Receive("RdmtRemoveSpeedMultipliers", function()
    local key = net.ReadString()
    for k, _ in pairs(current_mults) do
        if string.StartsWith(k, key) then
            current_mults[k] = nil
        end
    end
    for k, _ in pairs(current_mults_withweapon) do
        if string.StartsWith(k, key) then
            current_mults_withweapon[k] = nil
        end
    end
    for k, _ in pairs(current_mults_sprinting) do
        if string.StartsWith(k, key) then
            current_mults_sprinting[k] = nil
        end
    end
end)

local localPlayer = nil
hook.Add("TTTSpeedMultiplier", "RdmtSpeedModifier", function(ply, mults, sprinting)
    -- Cache this
    if not localPlayer then
        localPlayer = LocalPlayer()
    end
    if ply ~= localPlayer or not ply:Alive() or ply:IsSpec() then return end

    -- Apply all of these that are valid
    for _, m in pairs(current_mults) do
        if m ~= nil then
            table.insert(mults, m)
        end
    end

    -- Apply all of these that are valid when the player is sprinting
    if sprinting then
        for _, m in pairs(current_mults_sprinting) do
            if m ~= nil then
                table.insert(mults, m)
            end
        end
    end

    -- Apply all of these that are valid and have a weapon that matches the specific class
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then
        local wep_class = wep:GetClass()
        for _, m in pairs(current_mults_withweapon) do
            if m ~= nil and wep_class == m.wep_class then
                table.insert(mults, m.mult)
            end
        end
    end
end)

--[[
 Effects
]]--

function Randomat:HandleEntitySmoke(tbl, client, pred, color, max_dist, min_size, max_size)
    if not max_dist then max_dist = 3000 end
    if not min_size then min_size = 4 end
    if not max_size then max_size = 7 end

    for _, v in ipairs(tbl) do
        if pred(v) then
            if not v.RdmtSmokeEmitter then v.RdmtSmokeEmitter = ParticleEmitter(v:GetPos()) end
            if not v.RdmtSmokeNextPart then v.RdmtSmokeNextPart = CurTime() end
            local pos = v:GetPos() + Vector(0, 0, 30)
            if v.RdmtSmokeNextPart < CurTime() and client:GetPos():Distance(pos) <= max_dist then
                v.RdmtSmokeEmitter:SetPos(pos)
                v.RdmtSmokeNextPart = CurTime() + math.Rand(0.003, 0.01)
                local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
                local particle = v.RdmtSmokeEmitter:Add("particle/snow.vmt", v:LocalToWorld(vec))
                particle:SetVelocity(Vector(0, 0, 4) + VectorRand() * 3)
                particle:SetDieTime(math.Rand(0.5, 2))
                particle:SetStartAlpha(math.random(150, 220))
                particle:SetEndAlpha(0)
                local size = math.random(min_size, max_size)
                particle:SetStartSize(size)
                particle:SetEndSize(size + 1)
                particle:SetRoll(0)
                particle:SetRollDelta(0)
                if color then
                    local smokeColor = color
                    if type(color) == "function" then
                        smokeColor = color(v) or Color(0, 0, 0)
                    end

                    local r, g, b, _ = smokeColor:Unpack()
                    particle:SetColor(r, g, b)
                else
                    particle:SetColor(0, 0, 0)
                end
            end
        elseif v.RdmtSmokeEmitter then
            v.RdmtSmokeEmitter:Finish()
            v.RdmtSmokeEmitter = nil
        end
    end
end

function Randomat:HandlePlayerSmoke(client, pred, color, max_dist)
    Randomat:HandleEntitySmoke(player.GetAll(), client, pred, color, max_dist)
end

--[[
 UI Functions
]]--

local tex_corner8 = surface.GetTextureID("gui/corner8")
function Randomat:RoundedMeter(bs, x, y, w, h, color)
    surface.SetDrawColor(color:Unpack())

    surface.DrawRect(x + bs, y, w - bs * 2, h)
    surface.DrawRect(x, y + bs, bs, h - bs * 2)

    surface.SetTexture(tex_corner8)
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

--[[
 Weapon Functions
]]--

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