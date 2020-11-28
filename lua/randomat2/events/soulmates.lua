local EVENT = {}

EVENT.Title = ""
EVENT.id = "soulmates"
EVENT.AltTitle = "Soulmates"

CreateConVar("randomat_soulmates_affectall", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether everyone should have a soulmate")
CreateConVar("randomat_soulmates_sharedhealth", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether soulmates should have shared health")

local ply1 = {}
local ply1_health = {}
local ply2 = {}
local ply2_health = {}

local function SetSharedHealth(i, shared_health)
    ply1[i]:SetHealth(shared_health)
    ply1_health[i] = shared_health
    ply2[i]:SetHealth(shared_health)
    ply2_health[i] = shared_health
end

local function InitializeSharedHealth(i)
    ply1[i]:SetMaxHealth(200)
    ply2[i]:SetMaxHealth(200)

    local shared_health = ply1_health[i] + ply2_health[i]
    SetSharedHealth(i, shared_health)
end

function EVENT:Begin()
    ply1 = {}
    ply1_health = {}
    ply2 = {}
    ply2_health = {}

    local x = 0
    for _, v in pairs(self:GetAlivePlayers(true)) do
        x = x+1
        if x % 2 == 0 then
            print("Adding " .. v:Nick() .. " to 1")
            table.insert(ply1, v)
            table.insert(ply1_health, v:Health())
        else
            print("Adding " .. v:Nick() .. " to 2")
            table.insert(ply2, v)
            table.insert(ply2_health, v:Health())
        end
    end

    local size = 1
    if GetConVar("randomat_soulmates_affectall"):GetBool() then
        size = #ply2
        Randomat:EventNotifySilent("Soulmates")

        print("Checking " .. size .. " players")
        for i = 1, #ply2 do
            print("Checking " .. ply1[i]:Nick() .. " and " .. ply2[i]:Nick())
            ply1[i]:PrintMessage(HUD_PRINTTALK, "Your soulmate is "..ply2[i]:Nick())
            ply2[i]:PrintMessage(HUD_PRINTTALK, "Your soulmate is "..ply1[i]:Nick())
            ply1[i]:PrintMessage(HUD_PRINTCENTER, "Your soulmate is "..ply2[i]:Nick())
            ply2[i]:PrintMessage(HUD_PRINTCENTER, "Your soulmate is "..ply1[i]:Nick())

            if GetConVar("randomat_soulmates_sharedhealth"):GetBool() then
                InitializeSharedHealth(i)
            end
        end

        if ply1[#ply2+1] then
            ply1[#ply2+1]:PrintMessage(HUD_PRINTTALK, "You have no soulmate :(")
            ply1[#ply2+1]:PrintMessage(HUD_PRINTCENTER, "You have no soulmate :(")
        end
    else
        if GetConVar("randomat_soulmates_sharedhealth"):GetBool() then
            InitializeSharedHealth(1)
        end
        Randomat:EventNotifySilent(ply1[1]:Nick().." and "..ply2[1]:Nick().." are now soulmates.")
    end

    timer.Create("RdmtLinkTimer", 0.1, 0, function()
        for i = 1, size do
            if not ply1[i]:Alive() and ply2[i]:Alive() then
                ply2[i]:Kill()
            elseif not ply2[i]:Alive() and ply1[i]:Alive() then
                ply1[i]:Kill()
            elseif GetConVar("randomat_soulmates_sharedhealth"):GetBool() then
                if ply1[i]:Health() ~= ply1_health[i] or ply2[i]:Health() ~= ply2_health[i] then
                    -- Calculate how much each player's health has changed
                    local ply1_diff = ply1[i]:Health() - ply1_health[i]
                    local ply2_diff = ply2[i]:Health() - ply2_health[i]
                    -- Calculate the new shared health based on both diffs
                    local total_diff = ply1_diff + ply2_diff
                    local total_health = ply1_health[1] + total_diff

                    -- Set and save the changed health
                    SetSharedHealth(i, total_health)
                end
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtLinkTimer")
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in pairs({"affectall", "sharedhealth"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return {}, checks, {}
end

Randomat:register(EVENT)