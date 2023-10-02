local EVENT = {}

CreateConVar("randomat_connies_timer", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The amount of time before the messages are shown")
CreateConVar("randomat_connies_show_role", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to show the role of the person")
CreateConVar("randomat_connies_show_name", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to show the name of the person")
CreateConVar("randomat_connies_show_equipment", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to show the equipment a person has")
CreateConVar("randomat_connies_show_role_weapons", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to show the role-specific weapons a person has")

EVENT.Title = "Got any connies?!"
EVENT.Description = "Announces players that have shop items after " .. GetConVar("randomat_connies_timer"):GetInt() .. " seconds"
EVENT.id = "connies"
EVENT.Categories = {"biased_innocent", "moderateimpact"}
EVENT.MinRoundCompletePercent = 10

local someone_has_connies = false

local function TriggerAlert(item, role, is_item, ply)
    -- Event handler located in cl_networkstrings
    net.Start("alerteventtrigger")
    net.WriteString(EVENT.id)
    net.WriteString(item)
    net.WriteString(role)
    net.WriteUInt(is_item ~= nil and is_item or 0, 32)
    net.WriteInt(ply:GetRole(), 16)
    net.Send(ply)
end

function EVENT:BeforeEventTrigger(ply, options, ...)
    self.Description = "Announces players that have shop items after " .. GetConVar("randomat_connies_timer"):GetInt() .. " seconds"
end

function EVENT:Begin()
    local time = GetConVar("randomat_connies_timer"):GetInt()
    local show_role = GetConVar("randomat_connies_show_role"):GetBool()
    local show_name = GetConVar("randomat_connies_show_name"):GetBool()
    local show_equipment = GetConVar("randomat_connies_show_equipment"):GetBool()
    local show_role_weapons = GetConVar("randomat_connies_show_role_weapons"):GetBool()

    someone_has_connies = false

    timer.Create("RdmtConniesAnnounceTimer", time, 1, function()
        local found_connies = false
        for _, p in ipairs(self:GetAlivePlayers()) do
            local role = self:GetRoleName(p, false)
            local player_name = "Someone"
            if show_name then
                player_name = p:Nick()
                if show_role then
                    player_name = player_name .. " (" .. string.lower(role) .. ")"
                end
            elseif show_role then
                player_name = role
            end

            for _, w in ipairs(p:GetWeapons()) do
                local is_role_weapon = WEAPON_CATEGORY_ROLE and w.Category == WEAPON_CATEGORY_ROLE
                -- Skip role weapons unless we're configured to show them
                if not show_role_weapons and is_role_weapon then continue end
                -- Only run the other checks if this isn't a role weapon
                if not is_role_weapon then
                    -- Only announce buyable weapons
                    if w.AutoSpawnable or not w.CanBuy then continue end
                    -- Specifically skip the joke weapons
                    -- Even if someone bought them they don't really DO anything so it doesn't matter
                    if w.Kind == 317 then continue end
                    -- Skip weapons that have ammo but are empty
                    if w.Primary and w.Primary.ClipSize > 0 and w:Clip1() <= 0 then continue end
                end

                local weap_class = WEPS.GetClass(w)
                TriggerAlert(weap_class, player_name, nil, p)
                found_connies = true
            end

            if show_equipment then
                local i = 1
                while i <= EQUIP_MAX do
                    if p:HasEquipmentItem(i) then
                        TriggerAlert(i, player_name, i, p)
                        found_connies = true
                    end
                    -- Double the index since this is a bit-mask
                    i = i * 2
                end
            end
        end

        if not found_connies then
            self:SmallNotify("Nobody has connies! Yet...")
        end
    end)

    -- Event started in cl_networkstrings
    net.Receive("AlertTriggerFinal", function(len, ply)
        local event = net.ReadString()
        if event ~= EVENT.id then return end
        if not IsPlayer(ply) then return end

        local weap_name = self:RenameWeps(net.ReadString())
        local role = net.ReadString()

        if not someone_has_connies then
            someone_has_connies = true
            self:SmallNotify("Someone has connies! Check chat for the list...")
        end

        Randomat:SendChatToAll(role .. " has connies: " .. weap_name .. "!")
    end)
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
    for _, v in ipairs({"show_name", "show_role", "show_equipment", "show_role_weapons"}) do
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