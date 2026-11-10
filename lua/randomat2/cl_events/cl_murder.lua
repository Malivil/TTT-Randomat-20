local CamEnd3D   = cam.End3D
local CamIgnoreZ = cam.IgnoreZ
local CamStart3D = cam.Start3D

local DrawGetFontHeight = draw.GetFontHeight
local DrawNoTexture     = draw.NoTexture
local DrawRoundedBox    = draw.RoundedBox
local DrawSimpleText    = draw.SimpleText

local EntsFindByClass = ents.FindByClass

local GUIEnableScreenClicker = gui.EnableScreenClicker
local GUIIsGameUIVisible     = gui.IsGameUIVisible

local HaloAdd = halo.Add

local InputGetCursorPos  = input.GetCursorPos
local InputLookupBinding = input.LookupBinding
local InputSetCursorPos  = input.SetCursorPos

local MathCeil   = math.ceil
local MathClamp  = math.Clamp
local MathCos    = math.cos
local MathMax    = math.max
local MathMin    = math.min
local MathRad    = math.rad
local MathRandom = math.random
local MathSin    = math.sin
local MathSqrt   = math.sqrt

local NetReadTable = net.ReadTable

local RenderFogColor           = render.FogColor
local RenderFogEnd             = render.FogEnd
local RenderFogMaxDensity      = render.FogMaxDensity
local RenderFogMode            = render.FogMode
local RenderFogStart           = render.FogStart
local RenderSetBlend           = render.SetBlend
local RenderSetColorModulation = render.SetColorModulation

local StringUpper         = string.upper
local SurfaceDrawLine     = surface.DrawLine
local SurfaceDrawPoly     = surface.DrawPoly
local SurfaceDrawRect     = surface.DrawRect
local SurfaceSetDrawColor = surface.SetDrawColor

local TableInsert = table.insert

local UtilTraceLine = util.TraceLine

local scrW = ScrW()
local scrH = ScrH()

local originalStartPopupFunction = nil

local baseFontSize = MathCeil(scrH / 15)
surface.CreateFont("Rdmt_Murder_Large", {
    font      = "coolvetica",
    size      = baseFontSize,
    weight    = 500,
    antialias = true
})

surface.CreateFont("Rdmt_Murder_Small", {
    font      = "coolvetica",
    size      = MathCeil(baseFontSize * 0.56),
    weight    = 100,
    antialias = true
})

surface.CreateFont("testfont_cs", {
    font      = "Counter-Strike",
    size      = baseFontSize,
    weight    = 0,
    antialias = true,
    additive  = true,
    custom    = true
})

local lootNeededConVar
local bystanderSprintConVar
local murdererSprintConVar
local carrySlownessConVar

local EVENT = {}
EVENT.id = "murder"

local introBlackTime = 5
local introFadeTime  = 7

local colours = {
    bystander = Color(20, 120, 255),
    murderer  = Color(190, 20, 20),
    hasGun    = Color(120, 70, 245),
    lootHalo  = Color(0, 220, 0),
    knifeHalo = Color(220, 0, 0),
    gunHalo   = Color(0, 0, 255),
    flBgOn    = Color(0, 0, 0, 240),
    flBgOff   = Color(5, 5, 5, 180),
    flChgOn   = Color(50, 180, 220, 240),
    flChgOff  = Color(50, 180, 220, 180),
    mustKill  = Color(130, 130, 130, 255)
}

local taunts = {
    {"Help", "Yell for help", "help"},
    {"Funny", "Bit of a joke", "funny"},
    {"Scream", "Like a little girl", "scream"},
    {"Morose", "Feel the sadness", "morose"}
}

local introStart     = 0
local lookedAtPlayer = nil
local lookStartTime  = 0
local blindStartTime = nil
local tauntMenuOpen  = false
local deathScreenEnd = 0
local playerRagdoll  = nil

local function IsMurderer(ply)
    return ply:GetRole() == ROLE_TRAITOR
end

local function VectorToColour(vec, alpha)
    return Color(vec.x * 255, vec.y * 255, vec.z * 255, alpha or 255)
end

local function ShadowText(text, font, textX, textY, colour, alignX, alignY)
    local shadowColour = Color(0, 0, 0, colour.a)

    DrawSimpleText(text, font, textX + 2, textY + 2, shadowColour, alignX, alignY)
    DrawSimpleText(text, font, textX, textY, colour, alignX, alignY)
end

local function DrawCircle(circleX, circleY, radius)
    local poly = {}
    local segments = 40

    for i = 0, segments do
        local angle = MathRad(i / segments * 360)
        TableInsert(poly, {x = circleX + MathCos(angle) * radius, y = circleY + MathSin(angle) * radius})
    end

    DrawNoTexture()
    SurfaceDrawPoly(poly)
end

-- Override role strings
local originalNameInnocent
local originalNameExtInnocent
local originalNamePluralInnocent
local originalNameTraitor
local originalNameExtTraitor
local originalNamePluralTraitor

local function OverrideRoleStrings()
    originalNameInnocent       = ROLE_STRINGS[ROLE_INNOCENT]
    originalNameExtInnocent    = ROLE_STRINGS_EXT[ROLE_INNOCENT]
    originalNamePluralInnocent = ROLE_STRINGS_PLURAL[ROLE_INNOCENT]
    originalNameTraitor        = ROLE_STRINGS[ROLE_TRAITOR]
    originalNameExtTraitor     = ROLE_STRINGS_EXT[ROLE_TRAITOR]
    originalNamePluralTraitor  = ROLE_STRINGS_PLURAL[ROLE_TRAITOR]

    ROLE_STRINGS[ROLE_INNOCENT]        = "Bystander"
    ROLE_STRINGS_EXT[ROLE_INNOCENT]    = "a Bystander"
    ROLE_STRINGS_PLURAL[ROLE_INNOCENT] = "Bystanders"
    ROLE_STRINGS[ROLE_TRAITOR]         = "Murderer"
    ROLE_STRINGS_EXT[ROLE_TRAITOR]     = "a Murderer"
    ROLE_STRINGS_PLURAL[ROLE_TRAITOR]  = "Murderers"
end

local function RestoreRoleStrings()
    if originalNameInnocent then
        ROLE_STRINGS[ROLE_INNOCENT]        = originalNameInnocent
        ROLE_STRINGS_EXT[ROLE_INNOCENT]    = originalNameExtInnocent
        ROLE_STRINGS_PLURAL[ROLE_INNOCENT] = originalNamePluralInnocent
        ROLE_STRINGS[ROLE_TRAITOR]         = originalNameTraitor
        ROLE_STRINGS_EXT[ROLE_TRAITOR]     = originalNameExtTraitor
        ROLE_STRINGS_PLURAL[ROLE_TRAITOR]  = originalNamePluralTraitor
    end

    originalNameInnocent       = nil
    originalNameExtInnocent    = nil
    originalNamePluralInnocent = nil
    originalNameTraitor        = nil
    originalNameExtTraitor     = nil
    originalNamePluralTraitor  = nil
end

------------------------------------------------------
-- Taunt menu
------------------------------------------------------

local function GetTauntSelection()
    local menuRadius       = MathMin(scrW, scrH) * 0.35
    local cursorX, cursorY = InputGetCursorPos()

    local cursorOffsetX = cursorX - scrW / 2
    local cursorOffsetY = cursorY - scrH / 2

    local distanceToCenter = MathSqrt(cursorOffsetX * cursorOffsetX + cursorOffsetY * cursorOffsetY)

    if distanceToCenter > menuRadius then return nil end

    -- Make diagonal coordinates line up with menu segments
    local diagonalX = cursorOffsetX - cursorOffsetY
    local diagonalY = cursorOffsetX + cursorOffsetY

    if diagonalX > 0 then
        -- Top segment is 1, right segment is 2
        return diagonalY < 0 and 1 or 2
    else
        -- Bottom segment is 3, left segment is 4
        return diagonalY > 0 and 3 or 4
    end
end

------------------------------------------------------
-- HUD bits
------------------------------------------------------

local tkPhrase = nil
local tkPhrases = {
    {"... don't do that"},
    {"I bet you enjoyed it, didn't you?"},
    {"They were only one day from retirement!"},
    {"Well, this is awkward.", "For you."},
    {"Et tu, Brutè?"},
    {"I'm sure they deserved it"},
    {"God forbid you have hobbies, eh?"},
    {"I won't tell anyone, don't worry"},
    {"Weird flex but OK"},
    {"Good job, champ."},
    {"Outstanding work."},
    {"Congratulations.", "You absolute doughnut."},
    {"I admire your confidence, if nothing else"},
    {"Your parents must be so proud."},
    {"This is going on your permanent record"},
    {"Their dog will never understand :("},
    {"You've become the very thing you swore to destroy"},
    {"This is why we can't have nice things"},
    {"It's treason, then"},
    {"... blood for the Blood God?"},
    {"Use this time to get your story straight"},
    {"That wasn't very polite"},
    {"To shreds, you say?"},
    {"I'm not mad, just disappointed"},
}

-- Black intro screen and role info/player blindness
local function DrawOverlay()
    local client = LocalPlayer()
    if not IsValid(client) then return end

    local timePassed = CurTime() - introStart
    if timePassed < introBlackTime + introFadeTime then
        local alpha     = timePassed < introBlackTime and 255 or 255 * (1 - (timePassed - introBlackTime) / introFadeTime)
        local textAlpha = timePassed < 1 and alpha * timePassed or alpha
        -- Otherwise text lingers way longer than the black background
        if alpha ~= 255 then textAlpha = MathMax(0, alpha - 150) end

        DrawRoundedBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha))

        if client:Alive() and not client:IsSpec() then
            local title    = nil
            local subtitle = nil
            local lines    = nil
            local colour   = nil

            if IsMurderer(client) then
                title = "You are a Murderer"
                lines = {"Kill all Bystanders", "Don't get caught"}
                colour = colours.murderer
            elseif client:HasWeapon("weapon_ttt_randomatmurderrevolver") then
                title = "You are a Bystander"
                subtitle = "with a secret weapon"
                lines = {"There is a Murderer on the loose", "Find and kill them"}
                colour = colours.bystander
            else
                title = "You are a Bystander"
                lines = {"There is a Murderer on the loose", "Don't get killed", "", "Collect " .. lootNeededConVar:GetInt() .. " loot to get a gun"}
                colour = colours.bystander
            end

            colour = Color(colour.r, colour.g, colour.b, textAlpha)
            ShadowText(title, "Rdmt_Murder_Large", scrW / 2, scrH * 0.25, colour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if subtitle then
                ShadowText(subtitle, "Rdmt_Murder_Small", scrW / 2, scrH * 0.25 + DrawGetFontHeight("Rdmt_Murder_Large") * 0.7, Color(colours.hasGun.r, colours.hasGun.g, colours.hasGun.b, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            local line_height = DrawGetFontHeight("Rdmt_Murder_Small")
            for i, line in ipairs(lines) do
                ShadowText(line, "Rdmt_Murder_Small", scrW / 2, scrH * 0.75 + (i - 1) * line_height, colour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    -- Player blindness
    local remaining = client:GetNWFloat("Rdmt_Murder_BlindEndTime", 0) - CurTime()

    if remaining > 0 then
        if not blindStartTime then
            blindStartTime = CurTime()
            tkPhrase = tkPhrases[MathRandom(#tkPhrases)]
        end

        local fraction = MathClamp(CurTime() - blindStartTime, 0, 1) * MathClamp(remaining, 0, 1)
        local alpha = 254 * fraction

        local textAlpha = 255
        if alpha ~= 254 then textAlpha = MathMax(0, alpha - 150) end

        DrawRoundedBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha))

        local colour = Color(colours.bystander.r, colours.bystander.g, colours.bystander.b, textAlpha)
        ShadowText("You killed an innocent Bystander!", "Rdmt_Murder_Large", scrW / 2, scrH * 0.25, colour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        for i, line in ipairs(tkPhrase) do
            ShadowText(line, "Rdmt_Murder_Small", scrW / 2, (scrH * 0.25) + DrawGetFontHeight("Rdmt_Murder_Large") + DrawGetFontHeight("Rdmt_Murder_Small") * (i - 1), colour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else
        blindStartTime = nil
    end
end

local function DrawHUD()
    local client = LocalPlayer()
    if not IsValid(client) or not client:Alive() or client:IsSpec() then return end

    local roleColour  = IsMurderer(client) and colours.murderer or colours.bystander

    -- Player health circle
    local hudSize       = scrW * 0.07
    local hudX          = 20 + hudSize / 2
    local hudY          = scrH - 20 - hudSize / 2
    local clientColour  = VectorToColour(client:GetNWVector("Rdmt_Murder_Colour", Vector(1, 1, 1)))

    -- Grey ring around the outside
    SurfaceSetDrawColor(80, 80, 80, 255)
    DrawCircle(hudX, hudY, hudSize / 2)

    -- Black health bit background
    SurfaceSetDrawColor(0, 0, 0, 255)
    DrawCircle(hudX, hudY, hudSize * 0.48)

    -- Coloured health bit
    SurfaceSetDrawColor(clientColour)
    DrawCircle(hudX, hudY, MathClamp(client:Health(), 0, 100) / 100 * hudSize * 0.48)

    -- Loot collected
    ShadowText(tostring(client:GetNWInt("Rdmt_Murder_LootCollected", 0)), "Rdmt_Murder_Large", hudX, hudY + 2, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Player name
    local playerNameX = hudX
    local playerNameY = hudY - hudSize / 2 - 4

    local clientName = client:GetNWString("Rdmt_Murder_Name", "")
    ShadowText(clientName, "Rdmt_Murder_Small", playerNameX, playerNameY, clientColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    local charge = client:GetNWFloat("Rdmt_Murder_FlashlightCharge", 1)
    local flashlightW = 153
    local flashlightH = 32
    local flashlightX = hudX + hudSize / 2 + 20
    local flashlightY = hudY + hudSize / 2 - flashlightH - 5
    local border      = 5

    if charge < 1 then
        local bgColour  = client:FlashlightIsOn() and colours.flBgOn or colours.flBgOff
        local chgColour = client:FlashlightIsOn() and colours.flChgOn or colours.flChgOff
        SurfaceSetDrawColor(bgColour.r, bgColour.g, bgColour.b, bgColour.a)
        SurfaceDrawRect(flashlightX, flashlightY, flashlightW, flashlightH)
        SurfaceSetDrawColor(chgColour.r, chgColour.g, chgColour.b, chgColour.a)
        SurfaceDrawRect(flashlightX + border, flashlightY + border, (flashlightW - border * 2) * charge, flashlightH - border * 2)
    end

    -- Role name
    local roleX = scrW - 20
    local roleY = scrH - 3
    local roleName = IsMurderer(client) and "Murderer" or "Bystander"

    ShadowText(roleName, "Rdmt_Murder_Large", roleX, roleY, roleColour, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

    -- Round timer
    local timerX = hudX
    local timerY = playerNameY - 40

    local roundTimeRemaining = util.SimpleTime(MathMax(0, GetGlobalFloat("ttt_round_end", 0) - CurTime()), "%02i:%02i")
    ShadowText(roundTimeRemaining, "Rdmt_Murder_Small", timerX, timerY, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    -- Nametags
    local eyePos = client:EyePos()
    local tr     = UtilTraceLine({
        start  = eyePos,
        endpos = eyePos + client:GetAimVector() * 500,
        filter = client,
        mask   = MASK_SHOT
    })
    local hitEnt = tr.Entity

    if IsValid(hitEnt) and hitEnt:IsPlayer() and hitEnt:Alive() then
        lookedAtPlayer = hitEnt
        lookStartTime  = CurTime()
    end

    local nameTextY = scrH / 2 + 80

    -- Show name while looking at another player, then when looking away show for 1 second, then fade out over 2 seconds
    local lookTime = CurTime() - lookStartTime
    if IsValid(lookedAtPlayer) and lookTime < 3 then
        local playerName   = lookedAtPlayer:GetNWString("Rdmt_Murder_Name", "")
        local alphaMult    = lookTime < 1 and 1 or (1 - (lookTime - 1) / 2)
        local playerColour = VectorToColour(lookedAtPlayer:GetNWVector("Rdmt_Murder_Colour", Vector(1, 1, 1)), alphaMult * 255)

        ShadowText(playerName, "Rdmt_Murder_Small", scrW / 2, nameTextY, playerColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Draw our own corpse name
    if IsValid(hitEnt) and hitEnt:GetClass() == "prop_ragdoll" and tr.HitPos:Distance(tr.StartPos) < 100 then
        local corpseName = hitEnt:GetNWString("Rdmt_Murder_Name", "Unknown")
        local corpseColour = VectorToColour(hitEnt:GetNWVector("Rdmt_Murder_Colour", Vector(1, 1, 1)))

        ShadowText(corpseName, "Rdmt_Murder_Large", scrW / 2, nameTextY, corpseColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        ShadowText("Corpse", "Rdmt_Murder_Small", scrW / 2, nameTextY + DrawGetFontHeight("Rdmt_Murder_Large") * 0.7, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Show disguise hint when a Murderer looks at a corpse
    if IsMurderer(client) and IsValid(hitEnt) and hitEnt:GetClass() == "prop_ragdoll" and tr.HitPos:Distance(tr.StartPos) < 80 then
        local rag_name = hitEnt:GetNWString("Rdmt_Murder_Name", "")

        if rag_name ~= client:GetNWString("Rdmt_Murder_Name", "") or hitEnt:GetNWVector("Rdmt_Murder_Colour") ~= client:GetNWVector("Rdmt_Murder_Colour") then
            local disguiseHintY = nameTextY + DrawGetFontHeight("Rdmt_Murder_Large") * 1.4
            local useKey        = StringUpper(InputLookupBinding("+use"))

            ShadowText("[" .. useKey .. "] Disguise as " .. rag_name .. " for 1 loot", "Rdmt_Murder_Small", scrW / 2, disguiseHintY, colours.murderer, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- Warn a Murderer that they're revealed if they haven't killed in too long
    if client:GetNWBool("Rdmt_Murder_Fog", false) then
        ShadowText("Your evil presence is showing", "Rdmt_Murder_Large", scrW / 2, scrH - 100, colours.murderer, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        ShadowText("Kill someone to hide", "Rdmt_Murder_Small", scrW / 2, scrH - 20, colours.mustKill, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end

    -- Draw taunt menu
    if tauntMenuOpen then
        local tauntMenuRadius = MathMin(scrW, scrH) * 0.35

        local circleX  = scrW / 2
        local circleY  = scrH / 2
        local selected = GetTauntSelection()

        SurfaceSetDrawColor(20, 20, 20, selected and 170 or 180)
        DrawCircle(circleX, circleY, tauntMenuRadius)

        local tauntDividerOffset = MathSqrt((tauntMenuRadius * tauntMenuRadius) / 2)
        SurfaceSetDrawColor(50, 50, 50, 255)
        SurfaceDrawLine(circleX, circleY, circleX + tauntDividerOffset, circleY + tauntDividerOffset)
        SurfaceDrawLine(circleX, circleY, circleX + tauntDividerOffset, circleY - tauntDividerOffset)
        SurfaceDrawLine(circleX, circleY, circleX - tauntDividerOffset, circleY + tauntDividerOffset)
        SurfaceDrawLine(circleX, circleY, circleX - tauntDividerOffset, circleY - tauntDividerOffset)

        for i, taunt in ipairs(taunts) do
            local centre = -math.pi / 2 + (i - 1) * (math.pi / 2)

            -- Highlight the part the cursor is in
            if selected == i then
                local poly = {{x = circleX, y = circleY}}

                for step = 0, 12 do
                    local angle = centre - math.pi / 4 + (math.pi / 2) * (step / 12)
                    TableInsert(poly, {x = circleX + MathCos(angle) * tauntMenuRadius, y = circleY + MathSin(angle) * tauntMenuRadius})
                end

                SurfaceSetDrawColor(20, 120, 255, 120)
                DrawNoTexture()
                SurfaceDrawPoly(poly)
            end

            local colour = (selected == nil or selected == i) and COLOR_WHITE or Color(200, 200, 200)
            local textX = circleX + MathCos(centre) * tauntMenuRadius * 0.6
            local textY = circleY + MathSin(centre) * tauntMenuRadius * 0.6

            local textOffsetY = i <= 2 and 40 or 35

            ShadowText(taunt[1], "Rdmt_Murder_Large", textX, textY - 10, colour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            ShadowText(taunt[2], "Rdmt_Murder_Small", textX, textY + textOffsetY, colour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

local function SetFog(scale)
    RenderFogMode(MATERIAL_FOG_LINEAR)
    RenderFogColor(20, 20, 20)
    RenderFogMaxDensity(0.95)
    RenderFogStart(50 * scale)
    RenderFogEnd(500 * scale)
    return true
end

local playerLoot = {}

net.Receive("Rdmt_Murder_LootSync", function()
    playerLoot = NetReadTable()
end)

net.Receive("Rdmt_Murder_Dead", function()
    deathScreenEnd = CurTime() + 5
    playerRagdoll = net.ReadEntity()
end)

------------------------------------------------------
-- Actual event
------------------------------------------------------

function EVENT:Begin()
    lootNeededConVar      = GetConVar("randomat_murder_loot_needed")
    bystanderSprintConVar = GetConVar("randomat_murder_bystander_sprint")
    murdererSprintConVar  = GetConVar("randomat_murder_murderer_sprint")
    carrySlownessConVar   = GetConVar("randomat_murder_carry_slow")

    local override = {
        invnext = true,
        invprev = true,
    }
    for i = 1, 4 do override["slot" .. i] = true end

    self:AddHook("PlayerBindPress", function( ply, bind, pressed )
        if pressed and override[bind] then return false end
    end )

    local toHide = {
        ["TTTInfoPanel"] = true,
        ["TTTTargetID"]  = true,
        ["TTTMStack"]    = true,
        ["TTTWSwitch"]   = true
    }

    self:AddHook("HUDShouldDraw", function(elementName)
        if toHide[elementName] then
            return false
        end
    end)

    -- Store the original "ttt_cl_startpopup" function
    local concommands = concommand.GetTable()
    originalStartPopupFunction = concommands["ttt_cl_startpopup"]
    concommand.Add("ttt_cl_startpopup", function() end)

self:AddHook("PreDrawHalos", function()
    local client = LocalPlayer()
    if not IsValid(client) or not client:Alive() or client:IsSpec() then return end

    local haloedProps  = {}
    local haloedKnives = {}
    local haloedGuns   = {}
    local eyePos = client:EyePos()

    local haloCandidates = {}

    -- Add player's loot props
    for _, lootProp in ipairs(playerLoot) do
        if IsValid(lootProp) then
            TableInsert(haloCandidates, lootProp)
        end
    end

    -- Add dropped knives
    for _, wep in ipairs(EntsFindByClass("weapon_ttt_randomatmurderknife")) do
        if IsValid(wep) then
            TableInsert(haloCandidates, wep)
        end
    end

    -- Add thrown knives for Murderers
        for _, wep in ipairs(EntsFindByClass("ttt_randomat_murderknife")) do
            if IsValid(wep) then
                TableInsert(haloCandidates, wep)
            end
        end

    -- Add dropped revolvers
    for _, wep in ipairs(EntsFindByClass("weapon_ttt_randomatmurderrevolver")) do
        if IsValid(wep) and not IsValid(wep:GetOwner()) then
            TableInsert(haloCandidates, wep)
        end
    end

    -- Check whether they're visible
    for _, ent in ipairs(haloCandidates) do
        local center = ent:WorldSpaceCenter()
        local visible = true

        local tr = UtilTraceLine({
            start  = eyePos,
            endpos = center,
            filter = {client, ent},
            mask   = MASK_VISIBLE_AND_NPCS
        })

        if tr.Fraction < 1.0 then
            visible = false
        end

        local class = ent:GetClass()
        if visible then
            if class == "weapon_ttt_randomatmurderknife" or class == "ttt_randomat_murderknife" then
                TableInsert(haloedKnives, ent)
            elseif class == "weapon_ttt_randomatmurderrevolver" then
                TableInsert(haloedGuns, ent)
            else
                TableInsert(haloedProps, ent)
            end
        end
    end

    -- Draw halos for visible props
    if #haloedProps > 0 then
        HaloAdd(haloedProps, colours.lootHalo, 5, 5, 5, true, false)
    end

    -- Draw halos for visible knives
    if #haloedKnives > 0 then
        HaloAdd(haloedKnives, colours.knifeHalo, 5, 5, 5, true, false)
    end

    -- Draw halos for visible guns
    if #haloedGuns > 0 then
        HaloAdd(haloedGuns, colours.gunHalo, 5, 5, 5, true, false)
    end
end)

    introStart     = CurTime()
    lookedAtPlayer = nil
    blindStartTime = nil

    OverrideRoleStrings()

    self:AddHook("HUDPaint", DrawHUD)
    self:AddHook("DrawOverlay", DrawOverlay)

    -- Death effect (black screen + ragdoll model over the top)
    self:AddHook("RenderScreenspaceEffects", function()
        if CurTime() >= deathScreenEnd then return end

        SurfaceSetDrawColor(0, 0, 0, 255)
        SurfaceDrawRect(-1, -1, scrW + 2, scrH + 2)

        RenderSetColorModulation(1, 1, 1)
        RenderSetBlend(1)

        if IsValid(playerRagdoll) then
            CamStart3D(EyePos(), EyeAngles(), LocalPlayer():GetFOV())
            CamIgnoreZ(true)

            playerRagdoll:DrawModel()

            CamIgnoreZ(false)
            CamEnd3D()
        end
    end)

    self:AddHook("SetupWorldFog", function()
        local client = LocalPlayer()
        if not (IsValid(client) and client:Alive() and client:GetNWBool("Rdmt_Murder_Fog", false)) then return end

        return SetFog(1)
    end)

    self:AddHook("SetupSkyboxFog", function(scale)
        local client = LocalPlayer()
        if not (IsValid(client) and client:Alive() and client:GetNWBool("Rdmt_Murder_Fog", false)) then return end

        return SetFog(scale)
    end)

    -- Murderer smoke if they haven't killed in too long
    self:AddHook("TTTShouldPlayerSmoke", function(v, client, shouldSmoke, smokeColor, smokeParticle, smokeOffset)
        if v:GetNWBool("Rdmt_Murder_Fog", false) then
            return true, Color(0, 0, 0)
        end
    end)

    self:AddHook("HUDDrawTargetID", function()
        return false
    end)

    self:AddHook("TTTSpeedMultiplier", function(ply, mults, sprinting)
        if ply:GetNWString("Rdmt_Murder_Name", "") == "" then return end
        if sprinting then
            local mult = IsMurderer(ply) and murdererSprintConVar:GetFloat() or bystanderSprintConVar:GetFloat()
            TableInsert(mults, mult)
        end
        if ply:GetNWBool("Rdmt_Murder_Carrying", false) then
            TableInsert(mults, 1 - carrySlownessConVar:GetFloat())
        end
    end)

    self:AddHook("OnContextMenuOpen", function()
        return false
    end)

    -- Hold the taunt key to open the menu...
    self:AddHook("PlayerButtonDown", function(ply, button)
        if button ~= KEY_R then return end
        if tauntMenuOpen or ply:IsTyping() or not ply:Alive() or GUIIsGameUIVisible() then return end

        tauntMenuOpen = true
        GUIEnableScreenClicker(true)
        InputSetCursorPos(scrW / 2, scrH / 2)
    end)

    -- ... let go to select
    self:AddHook("PlayerButtonUp", function(ply, button)
        if not tauntMenuOpen or button ~= KEY_R then return end

        local selected = GetTauntSelection()
        if selected then
            net.Start("Rdmt_Murder_Taunt")
                net.WriteString(taunts[selected][3])
            net.SendToServer()
        end

        if not tauntMenuOpen then return end
        tauntMenuOpen = false
        GUIEnableScreenClicker(false)
    end)
end

function EVENT:End()
    if originalStartPopupFunction then
        concommand.Add("ttt_cl_startpopup", originalStartPopupFunction)
        originalStartPopupFunction = nil
    end

    if not tauntMenuOpen then return end
    tauntMenuOpen = false
    GUIEnableScreenClicker(false)

    RestoreRoleStrings()

    lookedAtPlayer = nil
    blindStartTime = nil
    playerLoot     = {}
end

Randomat:register(EVENT)
