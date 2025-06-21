local EVENT = {}

EVENT.Title = "Mathracer"
EVENT.Description = "Type the answer to each equation in chat within the configurable amount of time OR DIE!"
EVENT.id = "mathracer"
EVENT.Categories = {"gamemode", "largeimpact"}

CreateConVar("randomat_mathracer_timer", 15, FCVAR_NONE, "The amount of time players have to solve each equation", 5, 60)
CreateConVar("randomat_mathracer_kill_wrong", 1, FCVAR_NONE, "Whether to kill players who type the wrong answer")

local operations = {
    add = {
        symbol = "+",
        left = "addend",
        right = "addend",
        calc = function(a, b) return a + b end
    },
    sub = {
        symbol = "-",
        left = "minuend",
        right = "subtrahend",
        calc = function(a, b) return a - b end
    },
    mul = {
        symbol = "×",
        left = "factor",
        right = "factor",
        calc = function(a, b) return a * b end
    },
    div = {
        symbol = "÷",
        left = "dividend",
        right = "divisor",
        calc = function(a, b) return a / b end
    }
}

local parentheses = {
    base = {add = false, sub = false, mul = false, div = false},
    addend = {add = false, sub = true, mul = false, div = false},
    minuend = {add = false, sub = true, mul = false, div = false},
    subtrahend = {add = true, sub = true, mul = false, div = false},
    factor = {add = true, sub = true, mul = false, div = true},
    dividend = {add = true, sub = true, mul = false, div = true},
    divisor = {add = true, sub = true, mul = true, div = true}
}

local iteration
local difficulty_options

function EVENT:GenerateEquationNode(type)
    local operation = difficulty_options["operations"][math.random(#difficulty_options["operations"])]
    return {
        left = {
            value = false,
            type = operations[operation]["left"]
        },
        right = {
            value = false,
            type = operations[operation]["right"]
        },
        operation = operation,
        parentheses = parentheses[type][operation]
    }
end

function EVENT:GenerateEquationTree(iterations, tree)
    if iterations == 0 then
        return tree
    else
        if tree then
            local node = tree
            local side = math.random() < 0.5 and "left" or "right"
            while node[side]["value"] do
                node = node[side]["value"]
                side = math.random() < 0.5 and "left" or "right"
            end
            node[side]["value"] = self:GenerateEquationNode(node[side]["type"])
            return self:GenerateEquationTree(iterations - 1, tree)
        else
            return self:GenerateEquationTree(iterations - 1, self:GenerateEquationNode("base"))
        end
    end
end

function EVENT:IsValidAnswer(answer)
    if answer == math.huge then return false end
    if answer == -math.huge then return false end
    if answer ~= math.floor(answer) then return false end
    if answer < difficulty_options["answerLowerBound"] then return false end
    if answer > difficulty_options["answerUpperBound"] then return false end
    return true
end

function EVENT:SolveEquationTree(tree)
    if tree["left"]["value"] then
        tree["left"] = self:SolveEquationTree(tree["left"]["value"])
    else
        if (difficulty_options["termLowerBound"] < 0) then
            if (math.random() < difficulty_options["negativeChance"]) then
                tree["left"]["value"] = math.random(difficulty_options["termLowerBound"], -1)
            else
                tree["left"]["value"] = math.random(0 ,difficulty_options["termUpperBound"])
            end
        else
            tree["left"]["value"] = math.random(difficulty_options["termLowerBound"], difficulty_options["termUpperBound"])
        end
        tree["left"]["equation"] = tree["left"]["value"]
        if tree["left"]["value"] < 0 then
            tree["left"]["equation"] = "(" .. tree["left"]["equation"] .. ")"
        end
    end

    if tree["right"]["value"] then
        tree["right"] = self:SolveEquationTree(tree["right"]["value"])
    else
        if difficulty_options["termLowerBound"] < 0 then
            if (math.random() < difficulty_options["negativeChance"]) then
                tree["right"]["value"] = math.random(difficulty_options["termLowerBound"], -1)
            else
                tree["right"]["value"] = math.random(0 ,difficulty_options["termUpperBound"])
            end
        else
            tree["right"]["value"] = math.random(difficulty_options["termLowerBound"], difficulty_options["termUpperBound"])
        end
        tree["right"]["equation"] = tree["right"]["value"]
        if tree["right"]["value"] < 0 then
            tree["right"]["equation"] = "(" .. tree["right"]["equation"] .. ")"
        end
    end

    if tree["left"] == false or tree["right"] == false then return false end

    local answer = operations[tree["operation"]]["calc"](tree["left"]["value"], tree["right"]["value"])
    if not self:IsValidAnswer(answer) then return false end

    local equation = tree["left"]["equation"] .. operations[tree["operation"]]["symbol"] .. tree["right"]["equation"]
    if (tree["parentheses"]) then
        equation = "(" .. equation .. ")"
    end

    return {
        value = math.floor(answer),
        equation = equation
    }
end

function EVENT:GenerateEquation(first, time)
    iteration = iteration + 1
    if (iteration == 2) then
        difficulty_options["terms"] = 3
    elseif (iteration == 3) then
        difficulty_options["termUpperBound"] = 12
    elseif (iteration == 4) then
        difficulty_options["termLowerBound"] = -12
        difficulty_options["answerLowerBound"] = -100
    elseif (iteration == 5) then
        difficulty_options["terms"] = 4
    elseif (iteration == 6) then
        difficulty_options["answerLowerBound"] = -500
        difficulty_options["answerUpperBound"] = 500
    elseif (iteration == 7) then
        difficulty_options["termLowerBound"] = -15
        difficulty_options["termUpperBound"] = 15
    elseif (iteration == 8) then
        difficulty_options["terms"] = 5
    elseif (iteration == 9) then
        difficulty_options["negativeChance"] = 0.33
        difficulty_options["answerLowerBound"] = -1000
        difficulty_options["answerUpperBound"] = 1000
    elseif (iteration >= 10 and iteration % 2 == 0) then
        difficulty_options["terms"] = difficulty_options["terms"] + 1
    end

    local equation = self:SolveEquationTree(self:GenerateEquationTree(difficulty_options["terms"] - 1))
    while equation == false do
        equation = self:SolveEquationTree(self:GenerateEquationTree(difficulty_options["terms"] - 1))
    end

    local message = "The " .. (first and "first" or "next") .. " equation is: " .. equation["equation"]
    self:SmallNotify(message, time)
    for _, p in player.Iterator() do
        p:PrintMessage(HUD_PRINTTALK, message)
    end

    if (equation["value"] == -0) then return 0 end
    return equation["value"]
end

function EVENT:BeforeEventTrigger(ply, options, ...)
    local time = GetConVar("randomat_mathracer_timer"):GetInt()
    local kill_wrong = GetConVar("randomat_mathracer_kill_wrong"):GetBool()
    local description = "Type the answer to each equation in chat within " .. time .. " seconds OR DIE!"
    if kill_wrong then
        description = description .. " Wrong answers also mean death!"
    end
    self.Description = description
end

function EVENT:Begin()
    iteration = 0
    difficulty_options = {
        terms = 2,
        operations = {"add", "sub", "mul", "div"},
        negativeChance = 0.25,
        termLowerBound = 0,
        termUpperBound = 10,
        answerLowerBound = 0,
        answerUpperBound = 100
    }

    local time = GetConVar("randomat_mathracer_timer"):GetInt()
    local kill_wrong = GetConVar("randomat_mathracer_kill_wrong"):GetBool()

    timer.Create("RdmtMathRacerDelay", time, 1, function()
        local safe = {}
        local answer = self:GenerateEquation(true, time)

        self:AddHook("PlayerSay", function(ply, text, team_only)
            if not IsValid(ply) or ply:IsSpec() then return end

            local sid64 = ply:SteamID64()
            if safe[sid64] then return end
            if text == tostring(answer) then
                ply:PrintMessage(HUD_PRINTTALK, "You're safe!")
                Randomat:Notify("You're safe!", nil, ply)
                safe[sid64] = true
                return ""
            else
                if kill_wrong then
                    local message = "WRONG! The correct answer is " .. answer
                    ply:PrintMessage(HUD_PRINTTALK, message)
                    Randomat:Notify(message, nil, ply)
                    ply:Kill()
                else
                    ply:PrintMessage(HUD_PRINTTALK, "WRONG!")
                    Randomat:Notify("WRONG!", nil, ply)
                end
            end
        end)

        timer.Create("RdmtMathRacerTimer", time, 0, function()
            -- Kill everyone who hasn't answered the prompt correctly yet
            for _, p in ipairs(self:GetAlivePlayers()) do
                if not safe[p:SteamID64()] then
                    local message = "Time's up! The correct answer was " .. answer
                    p:PrintMessage(HUD_PRINTTALK, message)
                    Randomat:Notify(message, nil, p)
                    p:Kill()
                end

            end

            table.Empty(safe)
            answer = self:GenerateEquation(false, time)
        end)
    end)
end

function EVENT:End()
    timer.Remove("RdmtMathRacerDelay")
    timer.Remove("RdmtMathRacerTimer")
end

-- "Secret" causes this event to essentially just kill everyone, since they can't see the prompts
-- "Typeracer" also essentially kills everyone because answering either the maths or spelling question correctly will incorrectly answer the other
function EVENT:Condition()
    return not (Randomat:IsEventActive("secret") or Randomat:IsEventActive("typeracer"))
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