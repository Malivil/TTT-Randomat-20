local EVENT = {}

util.AddNetworkString("RdmtRagdollBegin")
util.AddNetworkString("RdmtRagdollEnd")

CreateConVar("randomat_ragdoll_time", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The time the player is ragdolled", 0.5, 10)
CreateConVar("randomat_ragdoll_delay", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The time between ragdolls", 0.5, 10)

EVENT.Title = "Bad Trip"
EVENT.Description = "Causes any player who is off the ground (by jumping, falling, etc.) to turn into a ragdoll temporarily"
EVENT.id = "ragdoll"
EVENT.Type = EVENT_TYPE_JUMPING
EVENT.Categories = {"fun", "moderateimpact"}

local function PlayerNotStuck(ply)
    local pos = ply:GetPos()
    local t = {
        start = pos,
        endpos = pos,
        mask = MASK_PLAYERSOLID,
        filter = ply
    }
    return util.TraceEntity(t, ply).StartSolid == false
end

local function FindPassableSpace(ply, direction, step)
    local i = 0
    while (i < 100) do
        local origin = ply:GetPos()

        origin = origin + step * direction

        ply:SetPos(origin)
        if PlayerNotStuck(ply) then
            return true, ply:GetPos()
        end
        i = i + 1
    end
    return false, nil
end

--
--    Purpose: Unstucks player
--    Note: Very expensive to call, you have been warned!
--
local function UnstuckPlayer(ply)
    if not PlayerNotStuck(ply) then
        local oldPos = ply:GetPos()
        local angle = ply:GetAngles()
        local forward = angle:Forward()
        local right = angle:Right()
        local up = angle:Up()

        local SearchScale = 1 -- Increase and it will unstuck you from even harder places but with lost accuracy. Please, don't try higher values than 12
        -- Forward
        local success, pos = FindPassableSpace(ply, forward, SearchScale)
        if not success then success, pos = FindPassableSpace(ply, right, SearchScale) end -- Right
        if not success then success, pos = FindPassableSpace(ply, right, -SearchScale) end -- Left
        if not success then success, pos = FindPassableSpace(ply, up, SearchScale) end -- Up
        if not success then success, pos = FindPassableSpace(ply, up, -SearchScale) end -- Down
        if not success then success, pos = FindPassableSpace(ply, forward, -SearchScale) end -- Back
        if not success then
            return false
        end

        -- Not stuck?
        if oldPos == pos then
            return true
        else
            ply:SetPos(pos)
            if ply:IsValid() and ply:GetPhysicsObject():IsValid() then
                if ply:IsPlayer() then
                    ply:SetVelocity(vector_origin)
                end
                ply:GetPhysicsObject():SetVelocity(vector_origin) -- prevents bugs :s
            end

            return true
        end
    end
end

local function unragdollPlayer(v)
    v.inRagdoll = false
    v:SetParent()

    local ragdoll = v.ragdoll
    v.ragdoll = nil -- Gotta do this before spawn or our hook catches it
    -- Set these so players don't get their role weapons given back if they've already used them
    v.Resurrecting = true
    v.DeathRoleWeapons = nil
    v:Spawn()

    if IsValid(ragdoll) then
        local pos = ragdoll:GetPos()
        pos.z = pos.z + 10
        v:SetPos(pos)
        v:SetVelocity(ragdoll:GetVelocity())
        local yaw = ragdoll:GetAngles().yaw
        v:SetAngles(Angle(0, yaw, 0))
        if ragdoll.DisallowDeleting then
            ragdoll:DisallowDeleting(false)
        end
        ragdoll:Remove()
    end

    for i, _ in pairs(v.spawnInfo.weps) do
        v:Give(i)
        local wep = v:GetWeapon(i)
        if IsValid(wep) then
            if v.spawnInfo.weps[i].Clip then
                wep:SetClip1(v.spawnInfo.weps[i].Clip)
            end
            v:SetAmmo(v.spawnInfo.weps[i].Reserve, wep:GetPrimaryAmmoType(), true)
        end
        v:SelectWeapon(v.spawnInfo.activeWeapon)
    end

    v:SetCredits(v.spawnInfo.credits)
    v:SetModel(v.spawnInfo.model)
    v:SetPlayerColor(v.spawnInfo.playerColor)

    for i, j in pairs(v.spawnInfo.equipment) do
        if j then
            v:GiveEquipmentItem(i)
        end
    end

    v:SetMaxHealth(v.spawnInfo.maxhealth)
    v:SetHealth(math.max(0, v.spawnInfo.health))
    if v:Health() <= 0 then
        v:Kill()
    else
        timer.Simple(0.1, function()
            if v:IsInWorld() then
                UnstuckPlayer(v) -- Thanks to SunRed on GitHub for the unstuck script
            end
        end)
    end
end

local function ragdollPlayer(v)
    v.inRagdoll = true
    v.lastRagdoll = CurTime()
    v.spawnInfo = {}

    local weps = {}
    for _, j in ipairs(v:GetWeapons()) do
        weps[j.ClassName] = {}
        weps[j.ClassName].Clip = j:Clip1()
        weps[j.ClassName].Reserve = v:GetAmmoCount(j:GetPrimaryAmmoType())
    end

    local equipment = {}
    -- Keep track of what equipment the player had
    local i = 1
    while i <= EQUIP_MAX do
        equipment[i] = v:HasEquipmentItem(i)
        -- Double the index since this is a bit-mask
        i = i * 2
    end

    local info = {}
    info.weps = weps
    info.activeWeapon = v:GetActiveWeapon().ClassName
    info.health = v:Health()
    info.maxhealth = v:GetMaxHealth()
    info.model = v:GetModel()
    info.credits = v:GetCredits()
    info.equipment = equipment
    info.playerColor = v:GetPlayerColor()
    v.spawnInfo = info

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll.ragdolledPly = v
    ragdoll:SetNWBool("RdmtRagdollRagdoll", true)
    local velocity = v:GetVelocity()
    ragdoll:SetPos(v:GetPos())
    ragdoll:SetModel(info.model)
    ragdoll:SetSkin(v:GetSkin())
    for _, value in pairs(v:GetBodyGroups()) do
        ragdoll:SetBodygroup(value.id, v:GetBodygroup(value.id))
    end
    ragdoll:SetAngles(v:GetAngles())
    ragdoll:SetColor(v:GetColor())
    CORPSE.SetPlayerNick(ragdoll, v)
    ragdoll:Spawn()
    ragdoll:Activate()

    v:SetParent(ragdoll)

    for j=0, ragdoll:GetPhysicsObjectCount() - 1 do
        local phys_obj = ragdoll:GetPhysicsObjectNum(j)
        phys_obj:SetVelocity(velocity)
    end

    v:Spectate(OBS_MODE_CHASE)
    v:SpectateEntity(ragdoll)
    v:StripWeapons()

    if ragdoll.DisallowDeleting then
        ragdoll:DisallowDeleting(true, function(old, new)
            if IsValid(v) then v.ragdoll = new end
        end)
    end

    v.ragdoll = ragdoll
    local ragdolltime = GetConVar("randomat_ragdoll_time"):GetFloat()
    hook.Add("Think", v:Nick().."UnragdollTimer", function()
        -- Turn a ragdoll back into a player if they have essentially stopped moving and have been a ragdoll "long enough"
        if IsValid(ragdoll) and ragdoll:GetPhysicsObjectNum(1):GetVelocity():Length() <= 10 and (CurTime() - v.lastRagdoll) > ragdolltime then
            hook.Remove("Think", v:Nick().."UnragdollTimer")
            unragdollPlayer(v)
        end
    end)
end

function EVENT:Begin()
    net.Start("RdmtRagdollBegin")
    net.Broadcast()

    for _, v in ipairs(player.GetAll()) do
        v.inRagdoll = false
        v.lastRagdoll = nil
    end

    local ragdolltime = GetConVar("randomat_ragdoll_time"):GetFloat()
    local ragdolldelay = GetConVar("randomat_ragdoll_delay"):GetFloat()
    self:AddHook("Think", function()
        for _, v in ipairs(self:GetAlivePlayers()) do
            -- Turn a player into a ragdoll if they are in the air, not already a ragdoll, not in the water, and haven't been ragdolled recently
            if not v:IsOnGround() and not v.inRagdoll and v:WaterLevel() == 0 and (v.lastRagdoll == nil or (CurTime() - v.lastRagdoll) > (ragdolltime + ragdolldelay)) then
                local parent = v:GetParent()
                -- Find out if something else is creating a ragdoll like the Taser/Stun Gun or Moon Ball
                local has_ragdoll = (IsValid(parent) and parent:GetClass() == "prop_ragdoll") or IsValid(v.tazeragdoll) or IsValid(v.moonragdoll)

                -- Don't create a ragdoll for this player if something else already is, just add to the delay and check again later
                if has_ragdoll then
                    v.lastRagdoll = CurTime()
                else
                    ragdollPlayer(v)
                end
            end
        end
    end)

    self:AddHook("PostEntityTakeDamage", function(ent, dmg, taken)
        if not taken then return end
        if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then return end
        -- Skip crush damage. This is to prevent taking damage just by turning into a ragdoll
        if dmg:IsDamageType(DMG_CRUSH) then return end
        for _, v in ipairs(player.GetAll()) do
            for _, j in ipairs(ent:GetChildren()) do
                if j == v then
                    v.spawnInfo.health = v.spawnInfo.health - dmg:GetDamage()
                    -- Each ragdoll can only represent a single player so stop both loops early
                    return
                end
            end
        end
    end)
end

function EVENT:End()
    net.Start("RdmtRagdollEnd")
    net.Broadcast()

    for _, v in ipairs(player.GetAll()) do
        if v.inRagdoll then
            unragdollPlayer(v)
        end
        hook.Remove("Think", v:Nick().."UnragdollTimer")
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"time", "delay"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 1
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)