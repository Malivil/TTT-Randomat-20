local EVENT = {}
EVENT.id = "blind"

local function RemoveHook()
    hook.Remove("HUDPaint", "BlindPlayer")
end

function EVENT:Begin()
    local client = LocalPlayer()
    hook.Add("HUDPaint", "BlindPlayer", function()
        if IsValid(client) and client:Alive() and Randomat:IsTraitorTeam(client) then
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
    end)
end

EVENT.End = RemoveHook

Randomat:register(EVENT)

net.Receive("RdmtBlindRemove", RemoveHook)