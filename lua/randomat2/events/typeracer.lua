local EVENT = {}

EVENT.Title = "Typeracer"
EVENT.Description = "Type each word/phrase in chat within the configurable amount of time OR DIE!"
EVENT.id = "typeracer"

CreateConVar("randomat_typeracer_timer", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The amount of time players have to type each given word", 5, 60)
CreateConVar("randomat_typeracer_kill_wrong", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to kill players who type the word incorrectly")

local values = {}
table.insert(values, "cheese")
table.insert(values, "randomat")
table.insert(values, "racecar")
table.insert(values, "kayak")
table.insert(values, "banana")
table.insert(values, "mississippi")
table.insert(values, "massachusetts")
table.insert(values, "worcestershire")
table.insert(values, "controller")
table.insert(values, "the quick brown fox jumps over the lazy dog")
table.insert(values, "peter piper picked a peck of pickled peppers")
table.insert(values, "red rum, sir, is murder")
table.insert(values, "she sells seashells by the seashore")
table.insert(values, "supercalifragilisticexpialidocious")
table.insert(values, "unenthusiastically")
table.insert(values, "defenestration")
table.insert(values, "contagious")
table.insert(values, "sophisticated")
table.insert(values, "perplexing")
table.insert(values, "misspell")
table.insert(values, "pharaoh")
table.insert(values, "weird")
table.insert(values, "intelligence")
table.insert(values, "pronunciation")
table.insert(values, "handkerchief")

function EVENT:ChooseWord(first)
    local chosen = values[math.random(1, #values)]

    -- Let everyone know what the word is
    local message = "The " .. (first and "first" or "next") .. " word/phrase is: " .. chosen
    for _, p in ipairs(self:GetAlivePlayers()) do
        p:PrintMessage(HUD_PRINTTALK, message)
    end
    self:SmallNotify(message)

    return chosen
end

function EVENT:Begin()
    if ROLE_STRINGS then
        for _, r in ipairs(ROLE_STRINGS) do
            table.insert(values, r)
        end
    end

    local time = GetConVar("randomat_typeracer_timer"):GetInt()
    local kill_wrong = GetConVar("randomat_typeracer_kill_wrong"):GetBool()
    local description = "Type each word/phrase in chat within " .. time .. " seconds OR DIE!"
    if kill_wrong then
        description = description .. " Wrong answers also mean death!"
    end
    self.Description = description

    timer.Create("RdmtTypeRacerDelay", time, 1, function()
        local safe = {}
        local chosen = self:ChooseWord(true)

        self:AddHook("PlayerSay", function(ply, text, team_only)
            if not IsValid(ply) or ply:IsSpec() then return end
            if team_only then return end
            if text:lower() == chosen then
                ply:PrintMessage(HUD_PRINTTALK, "You're safe!")
                ply:PrintMessage(HUD_PRINTCENTER, "You're safe!")
                safe[ply:SteamID64()] = true
            else
                ply:PrintMessage(HUD_PRINTTALK, "WRONG!")
                ply:PrintMessage(HUD_PRINTCENTER, "WRONG!")
                if kill_wrong then
                    ply:Kill()
                end
            end
            return true
        end)

        timer.Create("RdmtTypeRacerTimer", time, 0, function()
            -- Kill everyone who hasn't answered the prompt correctly yet
            for _, p in ipairs(self:GetAlivePlayers()) do
                if not safe[p:SteamID64()] then
                    p:PrintMessage(HUD_PRINTTALK, "Time's up!")
                    p:PrintMessage(HUD_PRINTCENTER, "Time's up!")
                    p:Kill()
                end
            end

            table.Empty(safe)
            chosen = self:ChooseWord()
        end)
    end)
end

function EVENT:End()
    timer.Remove("RdmtTypeRacerDelay")
    timer.Remove("RdmtTypeRacerTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer"}) do
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

    local checks = {}
    for _, v in ipairs({"kill_wrong"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return sliders, checks
end

Randomat:register(EVENT)