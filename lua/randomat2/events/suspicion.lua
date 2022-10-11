local EVENT = {}

CreateConVar("randomat_suspicion_chance", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The chance of the player being a Jester", 0, 100)

EVENT.Title = ""
EVENT.Description = "Changes a random player to either a jester or a traitor"
EVENT.id = "suspicion"
EVENT.AltTitle = "A player is acting suspicious"
EVENT.SingleUse = false
EVENT.Categories = {"rolechange", "moderateimpact"}

function EVENT:Begin()
    -- Update this in case the role names have been changed
    EVENT.Description = "Changes a random player to either " .. Randomat:GetRoleExtendedString(ROLE_JESTER):lower() .. " or " .. Randomat:GetRoleExtendedString(ROLE_TRAITOR):lower()

    local traitor = {}
    local suspicionply = nil

    for _, v in ipairs(self:GetAlivePlayers(true)) do
        if Randomat:IsTraitorTeam(v, true) then
            table.insert(traitor, v)
            if suspicionply == nil then
                suspicionply = v
            end
        elseif Randomat:IsInnocentTeam(v, true) then
            suspicionply = v
        elseif suspicionply == nil and not Randomat:IsDetectiveLike(v) then
            suspicionply = v
        end
    end

    if suspicionply ~= nil then
        if not self.Silent then
            Randomat:EventNotifySilent(suspicionply:Nick() .. " is acting suspicious...")
        end

        if math.random(1,100) <= GetConVar("randomat_suspicion_chance"):GetInt() then
            Randomat:SetRole(suspicionply, ROLE_JESTER)
            suspicionply:SetCredits(0)
            local role_string = Randomat:GetRoleExtendedString(ROLE_JESTER):lower()
            for _, v in ipairs(traitor) do
                v:PrintMessage(HUD_PRINTCENTER, suspicionply:Nick() .. " is " .. role_string)
                v:PrintMessage(HUD_PRINTTALK, suspicionply:Nick() .. " is " .. role_string)
            end
        else
            Randomat:SetRole(suspicionply, ROLE_TRAITOR)
            local role_string = Randomat:GetRoleExtendedString(ROLE_TRAITOR):lower()
            for _, v in ipairs(traitor) do
                v:PrintMessage(HUD_PRINTCENTER, suspicionply:Nick() .. " is " .. role_string)
                v:PrintMessage(HUD_PRINTTALK, suspicionply:Nick() .. " is " .. role_string)
            end
        end
        SendFullStateUpdate()
    end
end

function EVENT:Condition()
    local has_innocent = false
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsJesterTeam(v) then
            return false
        elseif Randomat:IsInnocentTeam(v, true) then
            has_innocent = true
        end
    end
    return has_innocent
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"chance"}) do
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