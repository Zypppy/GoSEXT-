if myHero.charName ~= "Katarina" then return end

require("DamageLib")


local KatarinaMenu = MenuElement({type = MENU, name = "Katarina", id = "Katarina", leftIcon = "http://static.lolskill.net/img/champions/64/katarina.png"})

KatarinaMenu:MenuElement({id = "Enabled", name = "Script Enabled", value = true})
KatarinaMenu:MenuElement({type = MENU, name = "Drawings", id = "Draw"})
KatarinaMenu.Draw:MenuElement({id = "DrawRangeQ", name = "Bouncing Blades(Q) Range", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Katarina_Q.png"})

KatarinaMenu:MenuElement({type = MENU, name = "Killsteal", id = "Steal"})
KatarinaMenu.Steal:MenuElement({id = "KillCombo", name = "Can Kill With QWE Notification", value = true})

KatarinaMenu:MenuElement({type = MENU, id = "LHQMinions", name = "Auto Kill Minions"})
KatarinaMenu.LHQMinions:MenuElement({id = "LHQM_Circle", name = "Draw Circle Indicator", value = true})
KatarinaMenu.LHQMinions:MenuElement({id = "Enabled", name = "Enabled", value = true})

PrintChat("<3 ALL CREDITS TO FERETORIX")

function OnDraw()
if myHero.alive == false then return end --make sure we don't calc anything while dead <3

 if KatarinaMenu.Enabled:Value() then

local qSpellData = myHero:GetSpellData(_Q);
local wSpellData = myHero:GetSpellData(_W);
local eSpellData = myHero:GetSpellData(_E);
local drawc0lor = Draw.Color(0x4F00FF00);
local drawc0lorLasthit = Draw.Color(0xFF0000FF);

    if KatarinaMenu.Draw.DrawRangeQ:Value() then Draw.Circle(myHero.pos,qSpellData.range,3,drawc0lor) end


for i = 1, Game.MinionCount() do
      local minion = Game.Minion(i);
      if minion and minion.valid and minion.isEnemy and minion.visible then
        if minion.distance <= qSpellData.range then
          local spellDmg = getdmg("Q", minion, myHero);
          if spellDmg > minion.health then
          
            if KatarinaMenu.LHQMinions.LHQM_Circle:Value() and (qSpellData.currentCd == 0) and (qSpellData.level > 0) then
              Draw.Circle(minion.pos,minion.boundingRadius+10,4,drawc0lorLasthit);
              end
            
            if KatarinaMenu.LHQMinions.Enabled:Value() then
              if (qSpellData.currentCd == 0) and (qSpellData.level > 0) then
                Control.CastSpell(HK_Q, minion)
                end
              end
            end
          end
        end
      end

      for i = 1, Game.HeroCount() do
       local hero = Game.Hero(i);
        if hero and hero.valid and hero.isEnemy and hero.visible then
         if hero.distance <= 1000 then
          local spellDmg = getdmg("Q", hero, myHero)+getdmg("W", hero, myHero)+getdmg("E", hero, myHero);
           if spellDmg > hero.health then
              end
               if KatarinaMenu.Steal.KillCombo:Value() and (qSpellData.currentCd == 0) and (wSpellData.currentCd == 0) and (eSpellData.currentCd == 0) and (qSpellData.level > 0) and (wSpellData.level > 0) and (eSpellData.level > 0) then
                 Draw.Text("QWE Kill", 16 ,hero.pos2D.x-45, hero.pos2D.y+30)
                end
               end
              end
             end
            end
           end
