local EVENT = {}

EVENT.Title = "Echolocation"
EVENT.Description = "You can only navigate by sound"
EVENT.id = "echolocation"
EVENT.Categories = {"fun", "largeimpact"}

util.AddNetworkString("RdmtEcholocationServerSound")

function EVENT:Begin()
    self:AddHook("EntityEmitSound", function(data)
        local player = ""
        if IsPlayer(data.Entity) then
            player = data.Entity:SteamID64()
        elseif IsPlayer(data.Entity:GetOwner()) then
            player = data.Entity:GetOwner():SteamID64()
        end
        local volume = (data.SoundLevel / 75) * (data.Volume / 0.5)

        local pos = data.Pos
        if IsValid(data.Entity) and not pos then
            pos = data.Entity:GetPos()
        end

        if pos then
            net.Start("RdmtEcholocationServerSound")
            net.WriteVector(pos)
            net.WriteFloat(volume)
            net.WriteString(player)
            net.Broadcast()
        end
    end)
end

Randomat:register(EVENT)