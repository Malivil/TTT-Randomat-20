-- Event Tracking
local show_count = CreateClientConVar("cl_randomat_show_count", "0", true, false, "Whether to show the active Randomat count on the HUD", 0, 1)

Randomat.ActiveEvents = Randomat.ActiveEvents or {}

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
end)

local function ClearActiveEvents()
    table.Empty(Randomat.ActiveEvents)
    Randomat.ActiveEvents = {}
end

hook.Add("TTTEndRound", "RandomatEventTrackingEndRound", ClearActiveEvents)
hook.Add("TTTPrepareRound", "RandomatEventTrackingPrepareRound", ClearActiveEvents)
hook.Add("ShutDown", "RandomatEventTrackingMapChange", ClearActiveEvents)

hook.Add("Initialize", "RandomatEventTrackingInitialize", function()
    LANG.AddToLanguage("english", "rdmt_count_hud", "{count} Randomat events active")
end)

local icon_tex = Material("icon16/rdmt.png")
hook.Add("TTTHUDInfoPaint", "RandomatEventTrackingHUDInfoPaint", function(client, label_left, label_top, active_labels)
    if not show_count:GetBool() then return end
    if not GetGlobalBool("ttt_randomat_allow_client_list", false) then return end

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

hook.Add("TTTSettingsTabs", "RandomatEventTrackingTTTSettingsTabs", function(dtabs)
    if not GetGlobalBool("ttt_randomat_allow_client_list", false) then return end
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
        dsettings:CheckBox("Show active Randomat count on UI", "cl_randomat_show_count")
        drdmt:AddItem(dsettings)
    end

    -- Active Events section
    local dactive = vgui.Create("DForm", drdmt)
    dactive:SetName("Active Randomat Events")
    dactive:SetExpanded(false)
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

-- Weapon/Item Names
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

-- Player Speed
local current_mults = {}
local current_mults_withweapon = {}
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

net.Receive("RdmtRemoveSpeedMultiplier", function()
    local key = net.ReadString()
    current_mults[key] = nil
    current_mults_withweapon[key] = nil
end)

net.Receive("RdmtRemoveSpeedMultipliers", function()
    local key = net.ReadString()
    for k, _ in pairs(current_mults) do
        if string.StartWith(k, key) then
            current_mults[k] = nil
        end
    end
    for k, _ in pairs(current_mults_withweapon) do
        if string.StartWith(k, key) then
            current_mults_withweapon[k] = nil
        end
    end
end)

hook.Add("TTTSpeedMultiplier", "RdmtSpeedModifier", function(ply, mults)
    if ply ~= LocalPlayer() or not ply:Alive() or ply:IsSpec() then return end

    -- Apply all of these that are valid
    for _, m in pairs(current_mults) do
        if m ~= nil then
            table.insert(mults, m)
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