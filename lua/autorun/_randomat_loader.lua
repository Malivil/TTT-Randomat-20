Randomat = Randomat or {}

local function AddServer(fil)
    if SERVER then include(fil) end
end

local function AddClient(fil)
    if SERVER then AddCSLuaFile(fil) end
    if CLIENT then include(fil) end
end

if SERVER then
    resource.AddSingleFile("materials/icon16/rdmt.png")
    resource.AddSingleFile("materials/icon32/copy.png")
    resource.AddSingleFile("materials/icon32/cut.png")
    resource.AddSingleFile("materials/icon32/stones.png")

    concommand.Add("ttt_randomat_disableall", function()
        for _, v in pairs(Randomat.Events) do
            GetConVar("ttt_randomat_" .. v.Id):SetBool(false)
        end
    end)

    concommand.Add("ttt_randomat_enableall", function()
        for _, v in pairs(Randomat.Events) do
            GetConVar("ttt_randomat_" .. v.Id):SetBool(true)
        end
    end)

    concommand.Add("ttt_randomat_resetweights", function()
        for _, v in pairs(Randomat.Events) do
            GetConVar("ttt_randomat_" .. v.Id .. "_weight"):SetInt(-1)
        end
    end)

    local auto = CreateConVar("ttt_randomat_auto", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the Randomat should automatically trigger on round start.")
    local auto_min_rounds = CreateConVar("ttt_randomat_auto_min_rounds", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The minimum number of completed rounds before auto-Randomat can trigger.")
    local auto_chance = CreateConVar("ttt_randomat_auto_chance", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Chance of the auto-Randomat triggering.")
    local auto_choose = CreateConVar("ttt_randomat_auto_choose", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the auto-started event is always \"choose\"")
    local auto_silent = CreateConVar("ttt_randomat_auto_silent", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the auto-started event should be silent.")
    CreateConVar("ttt_randomat_rebuyable", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether you can buy more than one Randomat.")
    CreateConVar("ttt_randomat_event_weight", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The default selection weight each event should use.", 1)
    CreateConVar("ttt_randomat_event_hint", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the Randomat should print what each event does when they start.")
    CreateConVar("ttt_randomat_event_hint_chat", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether hints should also be put in chat.")
    CreateConVar("ttt_randomat_event_history", 10, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many events to keep in history to prevent duplication.")

    hook.Add("TTTBeginRound", "AutoRandomat", function()
        local rounds_complete = Randomat:GetRoundsComplete()
        local min_rounds = auto_min_rounds:GetInt()
        local should_auto = auto:GetBool() and math.random() <= auto_chance:GetFloat() and (min_rounds <= 0 or rounds_complete >= min_rounds)
        local new_auto = hook.Call("TTTRandomatShouldAuto", nil, should_auto)
        if type(new_auto) == "boolean" then should_auto = new_auto end

        if should_auto then
            local silent = auto_silent:GetBool()
            if auto_choose:GetBool() then
                if silent then
                    Randomat:SilentTriggerEvent("choose", nil)
                else
                    Randomat:TriggerEvent("choose", nil)
                end
            else
                if silent then
                    Randomat:SilentTriggerRandomEvent(nil)
                else
                    Randomat:TriggerRandomEvent(nil)
                end
            end
        end
    end)
end

AddServer("randomat2/randomat_base.lua")
AddServer("randomat2/randomat_shared.lua")
AddClient("randomat2/randomat_shared.lua")
AddClient("randomat2/cl_common.lua")
AddClient("randomat2/cl_message.lua")
AddClient("randomat2/cl_networkstrings.lua")

local files, _ = file.Find("randomat2/events/*.lua", "LUA")
for _, fil in ipairs(files) do
    AddServer("randomat2/events/" .. fil)
end

local clientfiles, _ = file.Find("randomat2/cl_events/*.lua", "LUA")
for _, fil in ipairs(clientfiles) do
    AddClient("randomat2/cl_events/" .. fil)
end