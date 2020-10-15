Randomat = Randomat or {}

local function AddServer(fil)
    if SERVER then include(fil) end
end

local function AddClient(fil)
    if SERVER then AddCSLuaFile(fil) end
    if CLIENT then include(fil) end
end

AddServer("randomat2/randomat_base.lua")
AddClient("randomat2/cl_message.lua")
AddClient("randomat2/cl_networkstrings.lua")

local files, _ = file.Find("randomat2/events/*.lua", "LUA")

for _, fil in pairs(files) do
    AddServer("randomat2/events/" .. fil)
end

if SERVER then
    concommand.Add("ttt_randomat_disableall", function()
        for _, v in pairs(Randomat.Events) do
            RunConsoleCommand("ttt_randomat_"..v.Id, 0)
        end
    end)

    concommand.Add("ttt_randomat_enableall", function()
        for _, v in pairs(Randomat.Events) do
            RunConsoleCommand("ttt_randomat_"..v.Id, 1)
        end
    end)

    CreateConVar("ttt_randomat_auto", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether the randomat should automatically trigger on round start.")
    CreateConVar("randomat_auto_chance", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Chance of the auto-randomat triggering.")
    CreateConVar("ttt_randomat_rebuyable", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether you can buy more than one randomat")

    hook.Add("TTTBeginRound", "AutoRandomat", function()
        if GetConVar("ttt_randomat_auto"):GetBool() and math.random() <= GetConVar("randomat_auto_chance"):GetFloat() then
            Randomat:TriggerRandomEvent(Randomat:GetValidPlayer(nil))
        end
    end)
end

local clientfiles, _ = file.Find("randomat2/cl_events/*.lua", "LUA")
for _, fil in pairs(clientfiles) do
    AddClient("randomat2/cl_events/" .. fil)
end