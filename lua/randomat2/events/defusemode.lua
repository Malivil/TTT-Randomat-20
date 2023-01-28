local EVENT = {}

EVENT.Title = "Somebody set us up the bomb"
EVENT.AltTitle = "Defuse Mode"
EVENT.Description = "Gives all traitors C4. If a C4 explodes by running out of time, the traitors win."
EVENT.id = "defusemode"
EVENT.Categories = {"gamemode", "biased_traitor", "biased", "moderateimpact"}

function EVENT:Begin()
    EVENT.Description = "Gives all " .. Randomat:GetRolePluralString(ROLE_TRAITOR) .. " C4. If a C4 explodes by running out of time, the " .. Randomat:GetRolePluralString(ROLE_TRAITOR) .. " win."

    for _, p in ipairs(player.GetAll()) do
        if Randomat:IsTraitorTeam(p) or Randomat:IsMonsterTeam(p) or Randomat:IsIndependentTeam(p) then
            local set_credits = not Randomat:IsTraitorTeam(p)
            Randomat:SetRole(p, ROLE_TRAITOR)
            self:StripRoleWeapons(p)
            p:Give("weapon_ttt_c4")
            if set_credits then p:SetDefaultCredits() end
        elseif Randomat:IsDetectiveTeam(p) then
            if not p:IsDetective() then
                Randomat:SetRole(p, ROLE_DETECTIVE)
                self:StripRoleWeapons(p)
                p:Give("weapon_ttt_wtester")
            end
        else
            Randomat:SetRole(p, ROLE_INNOCENT)
            self:StripRoleWeapons(p)
        end
    end
    SendFullStateUpdate()

    local traitors_win = false
    self:AddHook("TTTC4Explode", function(c4)
        if not IsValid(c4) then return end
        if c4.DisarmCausedExplosion then return end

        traitors_win = true
    end)

    self:AddHook("TTTCheckForWin", function()
        if traitors_win then return WIN_TRAITOR end
    end)
end

Randomat:register(EVENT)