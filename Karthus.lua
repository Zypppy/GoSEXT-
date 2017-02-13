if myHero.charName ~= "Karthus" then return end

require("DamageLib")


local KarthusMenu = MenuElement({type = MENU, name = "Karthus", id = "Karthus", leftIcon = "http://static.lolskill.net/img/champions/64/karthus.png"})

KarthusMenu:MenuElement({id = "Enabled", name = "Script Enabled", value = true})
KarthusMenu:MenuElement({type = MENU, name = "Drawings", id = "Draw"})
KarthusMenu.Draw:MenuElement({id = "DrawRangeQ", name = "Lay Waste(Q) Range", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Karthus_Q.png"})

KarthusMenu:MenuElement({type = MENU, name = "Killsteal", id = "Steal"})
KarthusMenu.Steal:MenuElement({id = "StealR", name = "Requiem(R)", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Karthus_R.png"})
KarthusMenu.Steal:MenuElement({id = "StealRCircle", name = "Draw Circle Indicator", value = true})
KarthusMenu.Steal:MenuElement({id = "KillR", name = "Notification For R", value = true})

PrintChat("<3 ALL CREDITS TO FERETORIX")

function OnDraw()
if myHero.alive == false then return end

if KarthusMenu.Enabled:Value() then



local qSpellData = myHero:GetSpellData(_Q);
local rSpellData = myHero:GetSpellData(_R);
local drawc0lor = Draw.Color(0x4F00FF00);

  if KarthusMenu.Draw.DrawRangeQ:Value() then Draw.Circle(myHero.pos,qSpellData.range,3,drawc0lor) end

    for i = 1, Game.HeroCount() do
      local hero = Game.Hero(i);
      if hero and hero.valid and hero.isEnemy and hero.visible then
        if hero.distance <= rSpellData.range then
          local spellDmg = getdmg("R", hero, myHero);
          if spellDmg > hero.health then
            
            if KarthusMenu.Steal.StealR:Value() then
              if (rSpellData.currentCd == 0) and (rSpellData.level > 0) then
                Control.CastSpell(HK_R)
              end
            end
          end
        end
        local spellDmg = getdmg("R", hero, myHero);
        if spellDmg > hero.health then
          if KarthusMenu.Steal.KillR:Value() and (rSpellData.currentCd == 0) and (rSpellData.level > 0)  then
            Draw.Text("Can Kill With R", 16 ,myHero.pos2D.x-45, myHero.pos2D.y+30)
          end
        end    
      end
    end
  end  
end  
