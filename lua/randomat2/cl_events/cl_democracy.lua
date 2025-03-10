local EVENT = {}
EVENT.id = "democracy"

local voteframe = nil
local jesterframes = {}

function EVENT:End()
    if IsValid(voteframe) then
        voteframe:Close()
    end

    for _, f in ipairs(jesterframes) do
        if IsValid(f) then
            f:Close()
        end
    end
end

Randomat:register(EVENT)

net.Receive("DemocracyEventBegin", function()
    voteframe = vgui.Create("DFrame")
    voteframe:SetPos(10, ScrH() - 800)
    voteframe:SetSize(200, 300)
    voteframe:SetTitle("Vote to Kill (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    voteframe:SetDraggable(false)
    voteframe:ShowCloseButton(false)
    voteframe:SetVisible(true)
    voteframe:SetDeleteOnClose(true)

    --Player List
    local list = vgui.Create("DListView", voteframe)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    local playerColumn = list:AddColumn("Players")
    list:AddColumn("Votes")

    for _, v in player.Iterator() do
        -- Skip spectators who weren't in this round
        if (not v:Alive() or v:IsSpec()) and v:GetRole() == ROLE_NONE then continue end

        list:AddLine(v:Nick(), 0)
    end

    list:OnRequestResize(playerColumn, 125)

    list.OnRowSelected = function(lst, index, pnl)
        local ply = LocalPlayer()
        if ply:Alive() and not ply:IsSpec() then
            net.Start("DemocracyPlayerVoted")
            net.WriteString(pnl:GetColumnText(1))
            net.SendToServer()
        else
            ply:PrintMessage(HUD_PRINTTALK, "Dead people can't vote")
        end
    end

    net.Receive("DemocracyPlayerVoted", function()
        local votee = net.ReadString()
        local num = net.ReadInt(32)
        for _, v in ipairs(list:GetLines()) do
            if v:GetColumnText(1) == votee then
                v:SetColumnText(2, num)
            end
        end
    end)

    net.Receive("DemocracyReset", function()
        for _, v in ipairs(list:GetLines()) do
            v:SetColumnText(2, 0)
        end
    end)
end)

net.Receive("DemocracyJesterRevenge", function()
    local jesterframe = vgui.Create("DFrame")
    table.insert(jesterframes, jesterframe)
    jesterframe:SetPos(10, ScrH() - 800)
    jesterframe:SetSize(200, 300)
    jesterframe:SetTitle("Choose Your Revenge (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    jesterframe:SetDraggable(false)
    jesterframe:ShowCloseButton(false)
    jesterframe:SetVisible(true)
    jesterframe:SetDeleteOnClose(true)

    --Player List
    local plylist = vgui.Create("DListView", jesterframe)
    plylist:Dock(FILL)
    plylist:SetMultiSelect(false)
    plylist:AddColumn("Players")

    local voters = net.ReadTable(true)
    for _, v in ipairs(voters) do
        if v:Alive() and not v:IsSpec() then
            plylist:AddLine(v:Nick())
        end
    end

    plylist.OnRowSelected = function(lst, index, pnl)
        net.Start("DemocracyJesterVoted")
        net.WriteString(pnl:GetColumnText(1))
        net.SendToServer()
        if IsValid(jesterframe) then
            jesterframe:Close()
        end
    end
end)