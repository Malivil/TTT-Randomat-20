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
            player = data.Entity
        elseif IsPlayer(data.Entity:GetOwner()) then
            player = data.Entity:GetOwner()
        end
        local volume = (data.SoundLevel / 75) * (data.Volume / 0.5)

        local pos = data.Pos
        if IsValid(data.Entity) and not pos then
            pos = data.Entity:GetPos()
        end
        if not pos then return end

        net.Start("RdmtEcholocationServerSound")
        net.WriteVector(pos)
        net.WriteFloat(volume)
        net.WritePlayer(player)
        net.Broadcast()
    end)
end

Randomat:register(EVENT)