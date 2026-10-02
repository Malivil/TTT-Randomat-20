local EVENT = {}
EVENT.id = "echolocation"

local maskColor = Color(0, 0, 0, 0)
local sphereSteps = 12

local soundWaves = {}
local lastFrame
local client

net.Receive("RdmtEcholocationServerSound", function()
    local pos = net.ReadVector()
    local volume = net.ReadFloat()
    local player = player.GetBySteamID64(net.ReadString())

    local volumeMod = 0.5
    if player then
        volumeMod = 2
    end
    volume = math.min(volume * volumeMod, volumeMod)
    table.insert(soundWaves, {
        ["pos"] = pos,
        ["volume"] = volume,
        ["player"] = player,
        ["distance"] = 0
    })
end)

function EVENT:Begin()
    soundWaves = {}
    lastFrame = CurTime()

    self:AddHook("EntityEmitSound", function(data)
        local player = false
        local volumeMod = 0.5
        if IsPlayer(data.Entity) then
            player = data.Entity
            volumeMod = 2
        elseif IsPlayer(data.Entity:GetOwner()) then
            player = data.Entity:GetOwner()
            volumeMod = 2
        end

        local volume = (data.SoundLevel / 75) * (data.Volume / 0.5)

        local pos = data.Pos
        if IsValid(data.Entity) and not pos then
            pos = data.Entity:GetPos()
        end

        volume = math.min(volume * volumeMod, volumeMod)
        if pos then
            table.insert(soundWaves, {
                ["pos"] = pos,
                ["volume"] = volume,
                ["player"] = player,
                ["distance"] = 0
            })
        end
    end)

    self:AddHook("PostDrawTranslucentRenderables", function()
        if not client then client = LocalPlayer() end

        local camPos = client:EyePos()
        local camAngle = client:EyeAngles()
        local camNormal = camAngle:Forward()

        local currentTime = CurTime()

        render.SetStencilEnable(true)
        render.SetStencilTestMask(0x1C)
        render.SetStencilWriteMask(0x1C)
        render.ClearStencil()
        render.SetColorMaterial()
        render.SetStencilReferenceValue(1)

        local alphaMod = 128
        if client:IsActive() then
            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
            cam.IgnoreZ(true)
            render.DrawQuadEasy(camPos + camNormal * 10, -camNormal, 10000, 10000, COLOR_BLACK, camAngle.roll)
            cam.IgnoreZ(false)
            alphaMod = 64
        end

        for i = #soundWaves, 1, -1 do
            local wave = soundWaves[i]
            render.ClearStencil()

            local color = COLOR_WHITE
            if wave.player then
                color = wave.player:GetNWVector("PlayerColor", Vector(1, 1, 1)):ToColor()
            end

            local radius = wave.distance
            local thickness = wave.volume * 15
            if thickness > radius then
                thickness = radius
            end

            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
            render.SetStencilZFailOperation(STENCILOPERATION_INVERT)
            render.DrawSphere(wave.pos, -radius, sphereSteps, sphereSteps, maskColor)
            render.DrawSphere(wave.pos, radius, sphereSteps, sphereSteps, maskColor)
            render.DrawSphere(wave.pos, -radius - thickness, sphereSteps, sphereSteps, maskColor)
            render.DrawSphere(wave.pos, radius + thickness, sphereSteps, sphereSteps, maskColor)

            render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
            render.DrawSphere(wave.pos, radius + 0.25, sphereSteps, sphereSteps, maskColor)

            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
            cam.IgnoreZ(true)
            render.DrawQuadEasy(camPos + camNormal * 10, -camNormal, 10000, 10000, ColorAlpha(color, wave.volume * alphaMod), camAngle.roll)
            cam.IgnoreZ(false)

            wave.distance = wave.distance + ((currentTime - lastFrame) * 300)
            wave.volume = wave.volume - ((currentTime - lastFrame) / 2)
            if wave.volume <= 0 then
                table.remove(soundWaves, i)
            end
        end

        render.SetStencilEnable(false)
        lastFrame = currentTime
    end)

    self:AddHook("HUDPaint", function()
        if not client then client = LocalPlayer() end
        if not client:IsActive() then return end
        LocalPlayer():DrawViewModel(false)
    end)

    self:AddHook("TTTTargetIDPlayerBlockIcon", function(_, cli)
        if not cli:IsActive() then return end
        return true
    end)
end

function EVENT:End()
    soundWaves = {}
end

Randomat:register(EVENT)