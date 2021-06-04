local Revolvers = {}

net.Receive("MurderEventActive", function()
    local active = net.ReadBool()
    if active then
        local pl = LocalPlayer()
        local allow_shop = net.ReadBool()

        local maxpck = net.ReadInt(32)
        surface.CreateFont("HealthAmmo", {font = "Trebuchet24", size = 24, weight = 750})

        hook.Add("DrawOverlay", "RandomatMurderUI", function()
            local rl = pl:GetRole()
            local pks = pl:GetNWInt("MurderWeaponsEquipped")
            local text = string.format("%i / %02i", pks, maxpck)

            local y = ScrH() - 60

            if rl ~= ROLE_TRAITOR and rl ~= ROLE_KILLER and pl:Alive() and not pl:IsSpec() and not pl:GetNWBool("RdmMurderRevolver") then
                local texttable = {}
                texttable.font = "HealthAmmo"
                texttable.color = COLOR_WHITE
                texttable.pos = { 230, y+24 }
                texttable.text = text
                texttable.xalign = TEXT_ALIGN_RIGHT
                texttable.yalign = TEXT_ALIGN_BOTTOM
                draw.RoundedBox(8, 19.6, y, 230, 25, Color(0, 0, 0, 175))
                draw.RoundedBox(8, 19.6, y, (pks/maxpck)*230, 25, Color(205, 155, 0, 255))
                draw.TextShadow(texttable, 2)
            end
        end)

        local highlight = net.ReadBool()
        hook.Add("PreDrawHalos", "RandomatMurderGunHighlight", function()
            if not highlight then return end
            for _, wep in ipairs(ents.FindByClass("weapon_ttt_randomatrevolver")) do
                if #table.KeysFromValue(player.GetAll(), wep.Owner) ~= 0 then
                    table.RemoveByValue(Revolvers, wep)
                elseif #table.KeysFromValue(Revolvers, wep) == 0 then
                    table.insert(Revolvers, wep)
                end
            end
            halo.Add(Revolvers, Color(0,255,0), 1, 1, 10)
        end)

        -- Close any menu they may have open and block opening a new one
        if not allow_shop then
            pl:ConCommand("ttt_cl_traitorpopup_close")

            hook.Add("OnContextMenuOpen", "RandomatMurderBlockShop", function()
                return false
            end)
        end
    else
        hook.Remove("DrawOverlay", "RandomatMurderUI")
        hook.Remove("PreDrawHalos", "RandomatMurderGunHighlight")
        hook.Remove("OnContextMenuOpen", "RandomatMurderBlockShop")
    end
end)