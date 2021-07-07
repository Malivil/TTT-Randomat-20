Randomat = Randomat or {}

local function AddServer(fil)
    if SERVER then include(fil) end
end

local function AddClient(fil)
    if SERVER then AddCSLuaFile(fil) end
    if CLIENT then include(fil) end
end

AddServer("randomat2/randomat_base.lua")
AddServer("randomat2/randomat_shared.lua")
AddClient("randomat2/randomat_shared.lua")
AddClient("randomat2/cl_message.lua")
AddClient("randomat2/cl_networkstrings.lua")

if SERVER then
    resource.AddSingleFile("materials/icon32/copy.png")
    resource.AddSingleFile("materials/icon32/cut.png")
    resource.AddSingleFile("materials/icon32/stones.png")

    concommand.Add("ttt_randomat_disableall", function()
        for _, v in pairs(Randomat.Events) do
            GetConVar("ttt_randomat_"..v.Id):SetBool(false)
        end
    end)

    concommand.Add("ttt_randomat_enableall", function()
        for _, v in pairs(Randomat.Events) do
            GetConVar("ttt_randomat_"..v.Id):SetBool(true)
        end
    end)

    concommand.Add("ttt_randomat_resetweights", function()
        for _, v in pairs(Randomat.Events) do
            GetConVar("ttt_randomat_"..v.Id.."_weight"):SetInt(-1)
        end
    end)

    CreateConVar("ttt_randomat_auto", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the Randomat should automatically trigger on round start.")
    CreateConVar("ttt_randomat_auto_chance", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Chance of the auto-Randomat triggering.")
    CreateConVar("ttt_randomat_rebuyable", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether you can buy more than one Randomat.")
    CreateConVar("ttt_randomat_event_weight", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The default selection weight each event should use.", 1)
    CreateConVar("ttt_randomat_event_hint", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the Randomat should print what each event does when they start.")
    CreateConVar("ttt_randomat_event_hint_chat", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether hints should also be put in chat.")

    hook.Add("TTTBeginRound", "AutoRandomat", function()
        if GetConVar("ttt_randomat_auto"):GetBool() and math.random() <= GetConVar("ttt_randomat_auto_chance"):GetFloat() then
            Randomat:TriggerRandomEvent(nil)
        end
    end)
end

local files, _ = file.Find("randomat2/events/*.lua", "LUA")
for _, fil in ipairs(files) do
    AddServer("randomat2/events/" .. fil)
end

local clientfiles, _ = file.Find("randomat2/cl_events/*.lua", "LUA")
for _, fil in ipairs(clientfiles) do
    AddClient("randomat2/cl_events/" .. fil)
end