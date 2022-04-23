local EVENT = {}

CreateConVar("randomat_insurance_damage", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How much damage before a player gets paid", 1, 100)

EVENT.Title = "Insurance Policy"
EVENT.Description = "Players gain a credit every 20 damage they take"
EVENT.id = "insurance"
EVENT.Categories = {"biased_innocent", "biased", "moderateimpact"}

function EVENT:Begin()
    local damage = GetConVar("randomat_insurance_damage"):GetInt()
    self.Description = "Players gain a credit every " .. damage .. " damage they take"

    self:AddHook("PostEntityTakeDamage", function(ent, dmginfo, taken)
        if not taken then return end
        if not IsPlayer(ent) or not ent:Alive() or ent:IsSpec() then return end
        local att = dmginfo:GetAttacker()
        if not IsPlayer(att) or ent == att then return end
        local dmg = math.floor(dmginfo:GetDamage())

        -- Track how much damage they have taken
        if not ent.insuranceDamageTaken then
            ent.insuranceDamageTaken = 0
        end
        local current = ent.insuranceDamageTaken
        ent.insuranceDamageTaken = ent.insuranceDamageTaken + dmg

        -- To give out a credit for every X damage, we can't simply divide the total amount
        -- of damage done by X because we would end up giving out credits multiple times
        -- But if we only check it against the damage done, it will skip fractions of X,
        -- meaning the person gets less credits overall

        -- So... we need to either keep track of the last X interval we awarded for, or we
        -- need to add the difference between the last X interval and the last damage
        -- amount to the damage done, and then figure out how many Xs fit into that

        -- That "leftover" amounts to the remainer of dividing the previous damage dealt
        -- total by the damage interval amount. For example, if the damage interval is 5 and
        -- the player previously took 7 damage, the "leftover" would be 2. Adding that 2 leftover
        -- to the new damage of 3 would mean the player would be awarded a credit. Without that leftover,
        -- even though the total damage done would be 10 the player would have only gotten 1 credit
        local leftover = current % damage
        local total_damage = dmg + leftover
        local credits = math.floor(total_damage / damage)
        if credits <= 0 then return end

        ent:AddCredits(credits)
        ent:PrintMessage(HUD_PRINTTALK, "Congratulations! You have been awarded an insurance payout of " .. credits .. " credits!")
        ent:PrintMessage(HUD_PRINTCENTER, "Congratulations! You have been awarded an insurance payout of " .. credits .. " credits!")
    end)
end

function EVENT:End()
    -- Reset the damage recorded in case this runs again
    for _, p in ipairs(player.GetAll()) do
        p.insuranceDamageTaken = nil
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"damage"}) do
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

    return sliders
end

Randomat:register(EVENT)