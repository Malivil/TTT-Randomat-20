local EVENT = {}

CreateConVar("randomat_trexvision_reveal_time", 5, FCVAR_NONE, "How long to reveal a player who shoots their gun", 0, 30)

EVENT.Title = "T-Rex Vision"
EVENT.Description = "Your vision is now based on movement"
EVENT.id = "trexvision"
EVENT.Categories = {"biased_innocent", "biased", "moderateimpact"}

local MathAbs = math.abs
local MathRound = math.Round

local function IsTooSlow(crouching, prone, vel)
    local min = 100
    if prone then min = 35
    elseif crouching then min = 40 end
    return MathRound(MathAbs(vel)) < min
end

local function SetPlayerInvisible(ply)
    if ply:GetObserverMode() ~= OBS_MODE_NONE then return end

    Randomat:SetPlayerInvisible(ply)
    ply:DrawWorldModel(false)
end

local function SetPlayerVisible(ply)
    if ply:GetObserverMode() ~= OBS_MODE_NONE then return end

    Randomat:SetPlayerVisible(ply)
    ply:DrawWorldModel(true)
end

function EVENT:Begin()
    for _, p in ipairs(self:GetAlivePlayers()) do
        SetPlayerInvisible(p)
    end

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
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

        local crouching = ply:Crouching()
        local prone = ply.IsProne and ply:IsProne()

        -- If this player is in a vehicle, use the velocity of the vehicle instead
        local vel = mv:GetVelocity()
        local in_vehicle, parent = Randomat:IsPlayerInVehicle(ply)
        if in_vehicle then
            vel = parent:GetVelocity()
            crouching = false
            prone = false
        end

        if not ply:GetNWBool("RdmtTRexVisionRevealed", false) and IsTooSlow(crouching, prone, vel.x) and IsTooSlow(crouching, prone, vel.y) and IsTooSlow(crouching, prone, vel.z) then
            SetPlayerInvisible(ply)
        else
            SetPlayerVisible(ply)
        end
    end)
end

function EVENT:End()
    for _, p in player.Iterator() do
        SetPlayerVisible(p)
        timer.Remove("RdmtTRexVisionRevealTimer_" .. p:Nick())
    end
end

function EVENT:Condition()
    -- Don't run this event if there are zombies because it makes their role basically impossible
    -- Don't both running the check if zombies don't exist though
    if ROLE_ZOMBIE ~= -1 then
        for _, v in player.Iterator() do
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