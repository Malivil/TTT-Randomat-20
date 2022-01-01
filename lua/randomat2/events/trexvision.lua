local EVENT = {}

util.AddNetworkString("RdmtTRexVisionBegin")
util.AddNetworkString("RdmtTRexVisionEnd")

CreateConVar("randomat_trexvision_reveal_time", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long to reveal a player who shoots their gun", 0, 30)

EVENT.Title = "T-Rex Vision"
EVENT.Description = "Your vision is now based on movement"
EVENT.id = "trexvision"

local function IsTooSlow(crouching, val)
    local min = 100
    if crouching then min = 40 end
    return math.Round(math.abs(val)) < min
end

local function SetPlayerInvisible(ply)
    Randomat:SetPlayerInvisible(ply)
    ply:DrawWorldModel(false)
end

local function SetPlayerVisible(ply)
    Randomat:SetPlayerVisible(ply)
    ply:DrawWorldModel(true)
end

function EVENT:Begin()
    net.Start("RdmtTRexVisionBegin")
    net.Broadcast()

    for _, p in ipairs(self:GetAlivePlayers()) do
        SetPlayerInvisible(p)
    end

    self:AddHook("PlayerSpawn", function(ply)
        SetPlayerInvisible(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        SetPlayerVisible(victim)
    end)

    self:AddHook("EntityFireBullets", function(entity, data)
        if not IsPlayer(entity) then return end
        if not Randomat:IsPlayerInvisible(entity) then return end

        local reveal_time = GetConVar("randomat_trexvision_reveal_time"):GetInt()
        if reveal_time <= 0 then return end

        entity:SetNWBool("RdmtTRexVisionRevealed", true)
        timer.Create("RdmtTRexVisionRevealTimer_" .. entity:Nick(), reveal_time, 1, function()
            entity:SetNWBool("RdmtTRexVisionRevealed", false)
        end)
    end)

    self:AddHook("FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end

        local vel = mv:GetVelocity()
        local crouching = ply:Crouching()
        if not ply:GetNWBool("RdmtTRexVisionRevealed", false) and IsTooSlow(crouching, vel.x) and IsTooSlow(crouching, vel.y) and IsTooSlow(crouching, vel.z) then
            SetPlayerInvisible(ply)
        else
            SetPlayerVisible(ply)
        end
    end)
end

function EVENT:End()
    net.Start("RdmtTRexVisionEnd")
    net.Broadcast()

    for _, p in ipairs(player.GetAll()) do
        SetPlayerVisible(p)
        timer.Remove("RdmtTRexVisionRevealTimer_" .. p:Nick())
    end
end

function EVENT:Condition()
    -- Don't run this event if there are zombies because it makes their role basically impossible
    -- Don't both running the check if zombies don't exist though
    if ROLE_ZOMBIE ~= -1 then
        for _, v in ipairs(player.GetAll()) do
            if v:GetRole() == ROLE_ZOMBIE then
                return false
            end
        end
    end
    return true
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"reveal_time"}) do
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