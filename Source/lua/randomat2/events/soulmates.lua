local EVENT = {}

EVENT.Title = ""
EVENT.id = "soulmates"
EVENT.AltTitle = "Soulmates"

CreateConVar("randomat_soulmates_affectall", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether everyone should have a soulmate")

function EVENT:Begin()
    local x = 0

    local ply1 = {}
    local ply2 = {}

    for _, v in pairs(self:GetAlivePlayers(true)) do
        x = x+1
        if math.floor(x/2) ~= x/2 then
            table.insert(ply1, v)
        else
            table.insert(ply2, v)
        end

    end

    local size = 1
    if GetConVar("randomat_soulmates_affectall"):GetBool() then
        size = #ply2
        Randomat:EventNotifySilent("Soulmates")

        for i = 1, #ply2 do
            ply1[i]:PrintMessage(HUD_PRINTTALK, "Your soulmate is "..ply2[i]:Nick())
            ply2[i]:PrintMessage(HUD_PRINTTALK, "Your soulmate is "..ply1[i]:Nick())
            ply1[i]:PrintMessage(HUD_PRINTCENTER, "Your soulmate is "..ply2[i]:Nick())
            ply2[i]:PrintMessage(HUD_PRINTCENTER, "Your soulmate is "..ply1[i]:Nick())
        end
        if ply1[#ply2+1] then
            ply1[#ply2+1]:PrintMessage(HUD_PRINTTALK, "You have no soulmate :(")
            ply1[#ply2+1]:PrintMessage(HUD_PRINTCENTER, "You have no soulmate :(")
        end
    else
        Randomat:EventNotifySilent(ply1[1]:Nick().." and "..ply2[1]:Nick().." are now soulmates.")
    end

    timer.Create("RdmtLinkTimer", 0.1, 0, function()
        for i = 1, size do
            if not ply1[i]:Alive() and ply2[i]:Alive() then
                ply2[i]:Kill()
            elseif not ply2[i]:Alive() and ply1[i]:Alive() then
                ply1[i]:Kill()
            end
        end

    end)
end

function EVENT:End()
    timer.Remove("RdmtLinkTimer")
end

Randomat:register(EVENT)