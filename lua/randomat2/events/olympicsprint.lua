local EVENT = {}

util.AddNetworkString("RdmtOlympicSprintBegin")
util.AddNetworkString("RdmtOlympicSprintEnd")

EVENT.Title = "Olympic Sprint"
EVENT.AltTitle = "Infinite Sprint"
EVENT.Description = "Disables sprint stamina consumption, allowing players to sprint forever"
EVENT.id = "olympicsprint"
EVENT.Categories = {"smallimpact"}

function EVENT:Begin()
    net.Start("RdmtOlympicSprintBegin")
    net.Broadcast()

    self:AddHook("TTTSprintStaminaPost", function()
        -- Infinite sprint through fixed infinite stamina
        return 100
    end)
end

function EVENT:End()
    net.Start("RdmtOlympicSprintEnd")
    net.Broadcast()
end

function EVENT:Condition()
    -- Check that this variable exists by double negating
    -- We can't just return the variable directly because it's not a boolean
    -- The "TTTSprintStaminaPost" hook is only available in the new CR
    local is_new_cr = not not CR_VERSION
    -- If the enabled convar doesn't exist we assume sprint exists
    local has_sprint = not ConVarExists("ttt_sprint_enabled") or GetConVar("ttt_sprint_enabled"):GetBool()

    -- Don't run this while Run For Your Life is running because then we can't actually track if someone is sprinting...
    return is_new_cr and has_sprint and not Randomat:IsEventActive("runforyourlife")
end

Randomat:register(EVENT)