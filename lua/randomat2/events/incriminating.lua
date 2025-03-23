local EVENT = {}

CreateConVar("randomat_incriminating_timer_min", 3, FCVAR_NONE, "The minimum time before the message is sent", 1, 120)
CreateConVar("randomat_incriminating_timer_max", 10, FCVAR_NONE, "The maximum time before the message is sent", 1, 120)
CreateConVar("randomat_incriminating_mistake_chance", 0.2, FCVAR_NONE, "The chance that an \"oops\" message is sent", 0, 1)

EVENT.Title = "Incriminating Evidence"
EVENT.Description = "Forces a random player to say something incriminating without their knowledge"
EVENT.id = "incriminating"
EVENT.StartSecret = true
EVENT.SingleUse = false
EVENT.Categories = {"smallimpact"}

util.AddNetworkString("RdmtIncriminatingMessage")

local new_round_tmpl = {}
table.insert(new_round_tmpl, "finally")
table.insert(new_round_tmpl, "{traitor} finally")

local start_tmpl = {}
table.insert(start_tmpl, "this map has a good sniper spot")
table.insert(start_tmpl, "we should get the {detective} first")
table.insert(start_tmpl, "save your credits for the trap")
table.insert(start_tmpl, "watch out for %PLAYER%")
table.insert(start_tmpl, "%PLAYER% is a {jester}")
table.insert(start_tmpl, "careful, %PLAYER% is a {jester}")
table.insert(start_tmpl, "follow me")
table.insert(start_tmpl, "follow my lead")
table.insert(start_tmpl, "{i'm} gonna try to get %PLAYER% quick")
table.insert(start_tmpl, "buy a {weapon}")
table.insert(start_tmpl, "{i'm} not the {glitch}")
table.insert(start_tmpl, "i think %PLAYER% is the {glitch}")
table.insert(start_tmpl, "did you type in chat?")
table.insert(start_tmpl, "who uses traitor chat?")

local mid_tmpl = {}
table.insert(mid_tmpl, "come here so we can double kill")
table.insert(mid_tmpl, "c4 at the tester")

local end_tmpl = {}
table.insert(end_tmpl, "just kill the {detective} already")
table.insert(end_tmpl, "why haven't we won yet?")
table.insert(end_tmpl, "{i'm} out of credits")

local mid_end_tmpl = {}
table.insert(mid_end_tmpl, "hey, gimme a credit")
table.insert(mid_end_tmpl, "quick, kill %PLAYER%")
table.insert(mid_end_tmpl, "how is %PLAYER% still alive?")
table.insert(mid_end_tmpl, "watch out, gonna use a {weapon}")
table.insert(mid_end_tmpl, "have {you} killed anyone yet?")
table.insert(mid_end_tmpl, "where can {i} put this body?")
table.insert(mid_end_tmpl, "hey, this body has credits on it")
table.insert(mid_end_tmpl, "do {you} have any credits left?")
table.insert(mid_end_tmpl, "got any heal stuff?")
table.insert(mid_end_tmpl, "how do {you} get out of the {traitor} room?")
table.insert(mid_end_tmpl, "did they see you?")
table.insert(mid_end_tmpl, "how did they not see that!?")
table.insert(mid_end_tmpl, "did he not see you? {lol}")
table.insert(mid_end_tmpl, "yea, over here")
table.insert(mid_end_tmpl, "do {you} have radar?")
table.insert(mid_end_tmpl, "buy a radar")
table.insert(mid_end_tmpl, "kill someone already!")
table.insert(mid_end_tmpl, "{i'm} carrying us right now")

local mistakes = {}
table.insert(mistakes, "{oops} wrong chat")
table.insert(mistakes, "uhh... {oops}")
table.insert(mistakes, "<.<")
table.insert(mistakes, "ignore that!")

local weapons_options = {}
table.insert(weapons_options, "thing")
table.insert(weapons_options, "c4")

local function SendMessage(message, target)
    net.Start("RdmtIncriminatingMessage")
    net.WriteString(message)
    net.WritePlayer(target)
    net.Send(GetPlayerFilter(function(p) return p ~= target end))
end

local function ReplaceRandom(message, placeholder, options)
    if string.find(message, placeholder) then
        return string.Replace(message, placeholder, options[math.random(#options)])
    end
    return message
end

local function ReplacePlaceholders(tmpl)
    local message = ReplaceRandom(tmpl, "{you}", {"you", "u"})
    message = ReplaceRandom(message, "{i}", {"i", "I"})
    -- Don't worry about capitals for this one, they are only used at the start of messages
    message = ReplaceRandom(message, "{i'm}", {"i'm", "im"})
    message = ReplaceRandom(message, "{lol}", {"lol", "LOL", "lmao", "LMAO"})
    message = ReplaceRandom(message, "{oops}", {"oops", "whoops", "oopsie", "crap", "shit", "crud", "damn"})
    message = ReplaceRandom(message, "{weapon}", weapons_options)

    -- If this is defined then the role names are configurable, replace the placeholder with whatever the configured string is
    if ROLE_STRINGS_RAW then
        for r, s in pairs(ROLE_STRINGS_RAW) do
            message = string.Replace(message, "{" .. s .. "}", ROLE_STRINGS[r]:lower())
        end
    else
        -- If there are no role string lists, remove the brackets and use the string as-is
        message = string.Replace(message, "{", "")
        message = string.Replace(message, "}", "")
    end

    return message
end

local function AddRoleStrings(target, roles, messages)
    if not roles then return end

    for r, tr in pairs(roles) do
        if tr then
            if Randomat:CanRoleSpawn(r) then
                for _, tmpl in ipairs(messages) do
                    local message = string.Replace(tmpl, "{ROLE}", ROLE_STRINGS[r])
                    table.insert(target, message)
                end
            end
        end
    end
end

function EVENT:GetRandomAlivePlayer(pred)
    local alive_players = self:GetAlivePlayers(true)
    for _, p in ipairs(alive_players) do
        -- Exclude detective-like players unless there isn't anyone else to choose
        if (not pred or pred(p)) and (#alive_players == 2 or not Randomat:IsDetectiveLike(p)) then
            return p
        end
    end
end

local first_time = true
function EVENT:Begin()
    -- Only add templates the first time this is run
    if first_time then
        first_time = false

        -- Only include these if they target roles are enabled
        if Randomat:CanRoleSpawn(ROLE_SWAPPER) then
            table.insert(mid_tmpl, "i think %PLAYER% is a {swapper}")
        end
        if Randomat:CanRoleSpawn(ROLE_DEPUTY) then
            table.insert(mid_tmpl, "i think %PLAYER% is the {deputy}, kill them before they get promoted")
        end
        if Randomat:CanRoleSpawn(ROLE_IMPERSONATOR) then
            table.insert(mid_tmpl, "{im} {impersonator}, please kill {detective}")
        end

        -- Add roles as messages
        AddRoleStrings(start_tmpl, TRAITOR_ROLES, {"what does {ROLE} do again?", "what do {i} do as {ROLE} again?"})
        AddRoleStrings(start_tmpl, INDEPENDENT_ROLES, {"%PLAYER% is {ROLE}"})

        -- Add barnacle-related lines, if it exists
        if weapons.GetStored("weapon_ttt_barnacle") then
            table.insert(weapons_options, "barnacle")

            table.insert(mid_tmpl, "just put down a barnacle")
            table.insert(mid_tmpl, "barnacle in this room")
            table.insert(mid_tmpl, "watch out for barnacle")
            table.insert(mid_tmpl, "careful {i} put a barnacle here")
            table.insert(mid_tmpl, "where did {you} put that barnacle?")
            table.insert(mid_tmpl, "barnacle door")
        end

        -- Add shark trap-related lines, if it exists
        if weapons.GetStored("weapon_shark_trap") then
            table.insert(weapons_options, "shark trap")

            table.insert(mid_tmpl, "just put down a shark trap")
            table.insert(mid_tmpl, "shark trap in this room")
            table.insert(mid_tmpl, "watch out for shark trap")
            table.insert(mid_tmpl, "careful {i} put a shark trap here")
            table.insert(mid_tmpl, "where did {you} put that shark trap?")
        end

        -- Add harpoon-related lines, if it exists
        if weapons.GetStored("ttt_m9k_harpoon") or weapons.GetStored("weapon_ttt_hwapoon") then
            table.insert(mid_tmpl, "just harpooned them off the edge {lol}")
            table.insert(mid_tmpl, "harpoooon!")
            table.insert(mid_tmpl, "ha, get pooned!")
        end

        -- Donconnon-related lines, if it exists
        if weapons.GetStored("donc_swep") or weapons.GetStored("doncmk2_swep") then
            table.insert(weapons_options, "donconnon")

            table.insert(mid_tmpl, "donconnon sucks on this map")
        end

        -- Red Matter Bomb-related lines, if it exists
        if weapons.GetStored("weapon_ttt_rmgrenade") then
            table.insert(weapons_options, "red matter")

            table.insert(mid_tmpl, "throwing a red matter, don't get sucked in")
            table.insert(mid_tmpl, "back up, throwing a red matter")
            table.insert(mid_tmpl, "back up, throwing red matter")
            table.insert(mid_tmpl, "back up, red matter")
        end
    end

    -- The percent of the round that is complete is how much time has elapsed since the start of the round compared to the total amount of time the round will last
    local round_percent_complete = Randomat:GetRoundCompletePercent()
    local templates
    -- Use "new round" and "start" if <= 5% of the round has elapsed
    if round_percent_complete <= 5 then
        templates = table.Add(table.Copy(start_tmpl), new_round_tmpl)
    -- Use "start" if <=25% of the round has elapsed
    elseif round_percent_complete <= 25 then
        templates = start_tmpl
    -- Use "end" and "mid/end" if >=75% of the round has elapsed
    elseif round_percent_complete >= 75 then
        templates = table.Add(table.Copy(end_tmpl), mid_end_tmpl)
    -- Otherwise use "mid" and "mid/end"
    else
        templates = table.Add(table.Copy(mid_tmpl), mid_end_tmpl)
    end

    -- Go through all messages in template list and update all but the %PLAYER% placeholder
    local messages = {}
    for _, tmpl in ipairs(templates) do
        -- Replace placeholders
        local message = ReplacePlaceholders(tmpl)

        -- Add the message in with and without the first letter capitalized
        table.insert(messages, message)
        table.insert(messages, Randomat:Capitalize(message, true))
    end

    -- Shuffle them for more randomization
    table.Shuffle(messages)

    -- Get a random living non-Detective player
    local target = self:GetRandomAlivePlayer()
    local mistake_chance = GetConVar("randomat_incriminating_mistake_chance"):GetFloat()
    local delay_min = GetConVar("randomat_incriminating_timer_min"):GetInt()
    local delay_max = math.max(delay_min, GetConVar("randomat_incriminating_timer_max"):GetInt())
    local delay = math.random(delay_min, delay_max)
    timer.Create("IncriminatingDelay", delay, 1, function()
        local message = messages[math.random(#messages)]
        -- Replace the "%PLAYER%" placeholder
        -- Use a different placeholder for this so that the extra {'s and }'s for role names can be stripped out easily
        if string.find(message, "%PLAYER%", nil, true) then
            local found = self:GetRandomAlivePlayer(function(p) return p ~= target end)
            message = string.Replace(message, "%PLAYER%", found:Nick())
        end

        SendMessage(message, target)
        -- Sometimes send a "mistake" message
        if math.random() <= mistake_chance then
            timer.Create("IncriminatingDelayOops", 1.5 + math.random(), 1, function()
                local mistake = mistakes[math.random(#mistakes)]
                SendMessage(ReplacePlaceholders(mistake), target)
            end)
        end
    end)
end

function EVENT:End()
    timer.Remove("IncriminatingDelay")
    timer.Remove("IncriminatingDelayOops")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer_min", "timer_max", "mistake_chance"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "mistake_chance" and 2 or 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)