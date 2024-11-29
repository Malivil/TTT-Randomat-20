local EVENT = {}
EVENT.id = "fogofwar"

function EVENT:End()
    hook.Remove("SetupWorldFog", "RdmtFogOfWarWorldFog")
    hook.Remove("SetupSkyboxFog", "RdmtFogOfWarSkyboxFog")
end

Randomat:register(EVENT)

net.Receive("RdmtFogOfWarBegin", function()
    local default = net.ReadFloat()
    local traitor = net.ReadFloat()
    local client = LocalPlayer()

    --Limits the player's view distance like in among us, traitors and innocents can have differing view distances (in among us, impostors typically can see further than crewmates)
    hook.Add("SetupWorldFog", "RdmtFogOfWarWorldFog", function()
        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogColor(0, 0, 0)
        render.FogMaxDensity(1)

        if Randomat:IsTraitorTeam(client) then
            render.FogStart(300 * traitor)
            render.FogEnd(600 * traitor)
        else
            render.FogStart(300 * default)
            render.FogEnd(600 * default)
        end

        return true
    end)

    --If a map has a 3D skybox, apply a fog effect to that too
    hook.Add("SetupSkyboxFog", "RdmtFogOfWarSkyboxFog", function(scale)
        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogColor(0, 0, 0)
        render.FogMaxDensity(1)

        if Randomat:IsTraitorTeam(client) then
            render.FogStart(300 * traitor * scale)
            render.FogEnd(600 * traitor * scale)
        else
            render.FogStart(300 * default * scale)
            render.FogEnd(600 * default * scale)
        end

        return true
    end)
end)