local EVENT = {}

util.AddNetworkString("RdmtHerdImmunityBegin")
util.AddNetworkString("RdmtHerdImmunityEnd")
util.AddNetworkString("RdmtHerdImmunityPlayerVoted")
util.AddNetworkString("RdmtHerdImmunityReset")

CreateConVar("randomat_immunity_timer", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of seconds the vote lasts", 10, 90)
CreateConVar("randomat_immunity_bullet", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether bullet damage can be voted for")
CreateConVar("randomat_immunity_slashing", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether slashing damage can be voted for")

EVENT.Title = "Herd Immunity"
EVENT.Description = "Players vote for what type of damage they will be immune to for the rest of the round"
EVENT.id = "immunity"
EVENT.Type = {EVENT_TYPE_VOTING,EVENT_TYPE_WEAPON_OVERRIDE}

local playersvoted = {}
local votes = {}
local mapping = {
    ["Fire"] = DMG_BURN,
    ["Explosion"] = DMG_BLAST,
    ["Falling"] = DMG_FALL,
    ["Blunt (Crowbar)"] = DMG_CLUB,
    ["Crush (Prop)"] = DMG_CRUSH,
    ["Drowning"] = DMG_DROWN,
    ["Bullet"] = DMG_BULLET,
    ["Slash (Knife)"] = DMG_SLASH
}

function EVENT:Begin()
    playersvoted = {}
    votes = {}

    local options = {"Fire", "Explosion", "Falling", "Blunt (Crowbar)", "Crush (Prop)", "Drowning"}
    if GetConVar("randomat_immunity_bullet"):GetBool() then
        table.insert(options, "Bullet")
    end
    if GetConVar("randomat_immunity_slashing"):GetBool() then
        table.insert(options, "Slash (Knife)")
    end

    net.Start("RdmtHerdImmunityBegin")
    net.WriteTable(options)
    net.Broadcast()

    local immunity = nil
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not immunity then return end
        if not IsPlayer(ent) or not ent:Alive() or ent:IsSpec() then return end

        -- Disallow damage of the voted type
        if dmginfo:IsDamageType(immunity) then
            dmginfo:ScaleDamage(0)
        end
    end)

    local time = GetConVar("randomat_immunity_timer"):GetInt()
    timer.Create("RdmtHerdImmunityVoteTimer", time, 0, function()
        local max_votes = 0
        local max_value = nil
        for value, count in pairs(votes) do
            if count > max_votes then
                max_votes = count
                max_value = value
            end
        end

        -- Nobody voted, try again
        if max_value == nil then
            self:SmallNotify("Nobody voted. Try again.")
            return
        end

        local tie = false
        for value, count in pairs(votes) do
            if count == max_votes and value ~= max_value then
                tie = true
            end
        end

        table.Empty(playersvoted)
        table.Empty(votes)

        -- There was a tie, try again
        if tie then
            self:SmallNotify("The vote was a tie. Try again.")
            net.Start("RdmtHerdImmunityReset")
            net.Broadcast()
            return
        end

        net.Start("RdmtHerdImmunityEnd")
        net.Broadcast()

        self:SmallNotify("Vote complete! Everyone is now immune to " .. max_value .. " damage!")
        immunity = mapping[max_value]
        timer.Remove("RdmtHerdImmunityVoteTimer")
    end)
end

function EVENT:End()
    timer.Remove("RdmtHerdImmunityVoteTimer")
    net.Start("RdmtHerdImmunityEnd")
    net.Broadcast()
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
    for _, v in ipairs({"bullet", "slashing"}) do
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

net.Receive("RdmtHerdImmunityPlayerVoted", function(ln, ply)
    for k, _ in pairs(playersvoted) do
        if k == ply then
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
            --return
        end
    end

    local vote = net.ReadString()
    if not votes[vote] then
        votes[vote] = 0
    end

    local num = votes[vote] + 1
    votes[vote] = num

    playersvoted[ply] = vote

    net.Start("RdmtHerdImmunityPlayerVoted")
    net.WriteString(vote)
    net.WriteInt(num, 32)
    net.Broadcast()
end)

Randomat:register(EVENT)