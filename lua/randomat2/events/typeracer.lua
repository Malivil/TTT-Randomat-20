local EVENT = {}

EVENT.Title = "Typeracer"
EVENT.Description = "Type each word/phrase in chat within the configurable amount of time OR DIE!"
EVENT.id = "typeracer"
EVENT.Categories = {"gamemode", "largeimpact"}

CreateConVar("randomat_typeracer_timer", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The amount of time players have to type each given word", 5, 60)
CreateConVar("randomat_typeracer_kill_wrong", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to kill players who type the word incorrectly")

local values = {}
table.insert(values, "kayak")
table.insert(values, "weird")
table.insert(values, "inept")
table.insert(values, "cheese")
table.insert(values, "banana")
table.insert(values, "rhythm")
table.insert(values, "racecar")
table.insert(values, "pharaoh")
table.insert(values, "randomat")
table.insert(values, "misspell")
table.insert(values, "tneconni")
table.insert(values, "controller")
table.insert(values, "contagious")
table.insert(values, "perplexing")
table.insert(values, "psychology")
table.insert(values, "definitely")
table.insert(values, "ameliorate")
table.insert(values, "mississippi")
table.insert(values, "connecticut")
table.insert(values, "stroopwafel")
table.insert(values, "tegucigalpa")
table.insert(values, "ouagadougou")
table.insert(values, "pterodactyl")
table.insert(values, "connoisseur")
table.insert(values, "proletariat")
table.insert(values, "intelligence")
table.insert(values, "handkerchief")
table.insert(values, "acquaintance")
table.insert(values, "perseverance")
table.insert(values, "sacrilegious")
table.insert(values, "entrepreneur")
table.insert(values, "incompetency")
table.insert(values, "massachusetts")
table.insert(values, "sophisticated")
table.insert(values, "pronunciation")
table.insert(values, "worcestershire")
table.insert(values, "defenestration")
table.insert(values, "acknowledgment")
table.insert(values, "consanguineous")
table.insert(values, "omphaloskepsis")
table.insert(values, "myrmecophilous")
table.insert(values, "phenolphthalein")
table.insert(values, "psychotomimetic")
table.insert(values, "trichotillomania")
table.insert(values, "triskaidekaphobia")
table.insert(values, "unenthusiastically")
table.insert(values, "sesquipedalophobia")
table.insert(values, "benedict cumberbatch")
table.insert(values, "internationalization")
table.insert(values, "llanfairpwllgwyngyll")
table.insert(values, "uncharacteristically")
table.insert(values, "electroencephalograph")
table.insert(values, "incomprehensibilities")
table.insert(values, "red rum, sir, is murder")
table.insert(values, "honorificabilitudinitatibus")
table.insert(values, "antidisestablishmentarianism")
table.insert(values, "floccinaucinihilipilification")
table.insert(values, "pseudopseudohypoparathyroidism")
table.insert(values, "kolmivaihekilowattituntimittari")
table.insert(values, "supercalifragilisticexpialidocious")
table.insert(values, "she sells seashells by the seashore")
table.insert(values, "the five boxing wizards jump quickly")
table.insert(values, "sphinx of black quartz, judge my vow")
table.insert(values, "the quick brown fox jumps over the lazy dog")
table.insert(values, "peter piper picked a peck of pickled peppers")
table.insert(values, "pneumonoultramicroscopicsilicovolcanoconiosis")

local custom_values_path = "randomat/typeracer.txt"
local custom_values = {}
local bucketed_values = {}

local iteration
local MIN_ITERATION = 1
local MAX_ITERATION = 10

local iteration_length_mapping = {
    [1] = function(len) return len < 10 end,
    [2] = function(len) return len < 12 end,
    [3] = function(len) return len > 5 and len < 14 end,
    [4] = function(len) return len > 7 and len < 16 end,
    [5] = function(len) return len > 9 and len < 18 end,
    [6] = function(len) return len > 11 and len < 20 end,
    [7] = function(len) return len > 13 and len < 22 end,
    [8] = function(len) return len > 15 and len < 24 end,
    [9] = function(len) return len > 17 end,
    [10] = function(len) return len > 19 end
}

local function SaveCustomValues()
    if not file.IsDir("randomat", "DATA") then
        if file.Exists("randomat", "DATA") then
            ErrorNoHalt("Item named 'randomat' already exists in garrysmod/data but it is not a directory\n")
            return
        end

        file.CreateDir("randomat")
    end

    local typeracer_data = file.Open(custom_values_path, "w", "DATA")
    for _, phrase in ipairs(custom_values) do
        typeracer_data:Write(phrase .. "\n")
    end
    typeracer_data:Close()
end

concommand.Add("randomat_typeracer_add_phrase", function(ply, cmd, args, argStr)
    local phrase = string.Trim(argStr):lower()
    if table.HasValue(custom_values, argStr) or table.HasValue(ROLE_STRINGS, argStr) then
        print("Phrase already exists: '" .. phrase .. "'")
    else
        print("Adding phrase: '" .. phrase .. "'")
        table.insert(custom_values, phrase)
    end
    SaveCustomValues()
end)
concommand.Add("randomat_typeracer_remove_phrase", function(ply, cmd, args, argStr)
    local phrase = string.Trim(argStr):lower()
    if table.HasValue(custom_values, argStr) then
        print("Removing phrase: '" .. phrase .. "'")
        table.RemoveByValue(custom_values, argStr)
    else
        print("Phrase not found: '" .. phrase .. "'")
    end
    SaveCustomValues()
end)
concommand.Add("randomat_typeracer_list_phrases", function(ply, cmd, args, argStr)
    print("Custom Phrases:")
    PrintTable(custom_values)
end)

-- Read custom values out of the file on the disk
if file.Exists(custom_values_path, "DATA") then
    local typeracer_data = file.Open(custom_values_path, "r", "DATA")
    while not typeracer_data:EndOfFile() do
        local line = string.Trim(typeracer_data:ReadLine()):lower()
        if not table.HasValue(values, line) then
            table.insert(custom_values, line)
        end
    end
    typeracer_data:Close()
end

local last_words = {}
local max_last_words = 5
function EVENT:ChooseWord(first, quiz_time)
    -- Get the word based on the current iteration so difficulty scales over time
    iteration = math.Clamp(iteration + 1, MIN_ITERATION, MAX_ITERATION)
    local bucket_values = bucketed_values[iteration]

    -- Make sure we don't choose the same word multiple times
    local chosen
    repeat
        chosen = bucket_values[math.random(1, #bucket_values)]
    until not table.HasValue(last_words, chosen)
    table.insert(last_words, chosen)

    -- Make sure we only keep a short history
    while #last_words > max_last_words do
        table.remove(last_words, 1)
    end

    -- Let everyone know what the word is
    local message = "The " .. (first and "first" or "next") .. " word/phrase is: " .. chosen
    local time = math.Round(quiz_time * 0.66)
    self:SmallNotify(message, time)

    return chosen
end

function EVENT:Begin()
    iteration = 0

    -- Only add to the values arrays the first time
    if table.Count(bucketed_values) == 0 then
        -- Add all the role names
        if ROLE_STRINGS then
            for _, r in ipairs(ROLE_STRINGS) do
                table.insert(values, r:lower())
            end
        end

        -- Add all player names without special characters
        for _, p in ipairs(player.GetAll()) do
            local nick = p:Nick():lower()
            if not nick:match("%W") then
                table.insert(values, nick)
            end
        end

        -- Add custom values to the defaults
        if #custom_values > 0 then
            values = table.Add(values, custom_values)
        end

        -- Initialize the buckets
        for i = MIN_ITERATION, MAX_ITERATION do
            bucketed_values[i] = {}
        end

        -- Put values in the buckets based on their lengths
        for _, v in ipairs(values) do
            local len = #v
            for i, pred in pairs(iteration_length_mapping) do
                if pred(len) then
                    table.insert(bucketed_values[i], v)
                end
            end
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
        local chosen = self:ChooseWord(true, time)

        self:AddHook("PlayerSay", function(ply, text, team_only)
            if not IsValid(ply) or ply:IsSpec() then return end

            local sid64 = ply:SteamID64()
            if team_only or safe[sid64] then return end
            if text:lower() == chosen then
                ply:PrintMessage(HUD_PRINTTALK, "You're safe!")
                Randomat:Notify("You're safe!", nil, ply)
                safe[sid64] = true
                return ""
            else
                ply:PrintMessage(HUD_PRINTTALK, "WRONG!")
                Randomat:Notify("WRONG!", nil, ply)
                if kill_wrong then
                    ply:Kill()
                end
            end
        end)

        timer.Create("RdmtTypeRacerTimer", time, 0, function()
            -- Kill everyone who hasn't answered the prompt correctly yet
            for _, p in ipairs(self:GetAlivePlayers()) do
                if not safe[p:SteamID64()] then
                    p:PrintMessage(HUD_PRINTTALK, "Time's up!")
                    Randomat:Notify("Time's up!", nil, p)
                    p:Kill()
                end
            end

            table.Empty(safe)
            chosen = self:ChooseWord(false, time)
        end)
    end)
end

function EVENT:End()
    timer.Remove("RdmtTypeRacerDelay")
    timer.Remove("RdmtTypeRacerTimer")
end

-- "Secret" causes this event to essentially just kill everyone, since they can't see the prompts
function EVENT:Condition()
    return not Randomat:IsEventActive("secret")
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