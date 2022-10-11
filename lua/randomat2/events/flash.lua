local EVENT = {}

CreateConVar("randomat_flash_scale", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The percentage the speed should increase", 1, 100)

EVENT.Title = ""
EVENT.AltTitle = "Everything is as fast as Flash now! (" .. GetConVar("randomat_flash_scale"):GetInt() .. "% faster)"
EVENT.Description = "Causes everything (movement, firing speed, timers, etc.) to run faster than normal"
EVENT.id = "flash"
EVENT.SingleUse = false
EVENT.Categories = {"moderateimpact"}

function EVENT:Begin()
    if not self.Silent then
        Randomat:EventNotifySilent("Everything is as fast as Flash now! (" .. GetConVar("randomat_flash_scale"):GetInt() .. "% faster)")
    end

    local ts = game.GetTimeScale()
    game.SetTimeScale(ts + GetConVar("randomat_flash_scale"):GetInt()/100)
end

function EVENT:End()
    game.SetTimeScale(1)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"scale"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)