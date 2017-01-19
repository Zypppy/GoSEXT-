if myHero.charName ~= "Annie" then return end

require("DamageLib")


local AnnieMenu = MenuElement({type = MENU, name = "Annie", id = "Annie", leftIcon = "http://static.lolskill.net/img/champions/64/annie.png"})

AnnieMenu:MenuElement({id = "Enabled", name = "Script Enabled", value = true})
AnnieMenu:MenuElement({type = MENU, name = "Drawings", id = "Draw"})
AnnieMenu.Draw:MenuElement({id = "DrawRangeQ", name = "Disintegrate(Q) Range", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Annie_Q.png"})
AnnieMenu.Draw:MenuElement({id = "DrawRangeW", name = "Incinerate(W) Range", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Annie_W.png"})
AnnieMenu.Draw:MenuElement({id = "DrawRangeR", name = "Tibbers(R) Range", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Annie_R1.png"})

AnnieMenu:MenuElement({type = MENU, name = "Killsteal", id = "Steal"})
AnnieMenu.Steal:MenuElement({id = "StealQ", name = "Disintegrate(Q)", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Annie_Q.png"})
AnnieMenu.Steal:MenuElement({id = "StealQCircle", name = "Draw Circle Indicator", value = true})
AnnieMenu.Steal:MenuElement({id = "StealW", name = "Incinerate(W)", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Annie_W.png"})
AnnieMenu.Steal:MenuElement({id = "StealWCircle", name = "Draw Circle Indicator", value = true})
AnnieMenu.Steal:MenuElement({id = "StealR", name = "Tibbers(R)", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Annie_R1.png"})
AnnieMenu.Steal:MenuElement({id = "StealRCircle", name = "Draw Circle Indicator", value = true})
AnnieMenu.Steal:MenuElement({id = "KillCombo", name = "Can Kill With QWR", value = true})

AnnieMenu:MenuElement({type = MENU, id = "LHQMinions", name = "Auto Kill Minions"})
AnnieMenu.LHQMinions:MenuElement({id = "LHQM_Circle", name = "Draw Circle Indicator", value = true})
AnnieMenu.LHQMinions:MenuElement({id = "Enabled", name = "Enabled", value = true})

PrintChat("<3 ALL CREDITS TO FERETORIX")

function OnDraw()
if myHero.alive == false then return end --make sure we don't calc anything while dead <3

if AnnieMenu.Enabled:Value() then



local qSpellData = myHero:GetSpellData(_Q);
local wSpellData = myHero:GetSpellData(_W);
local rSpellData = myHero:GetSpellData(_R);
local drawc0lor = Draw.Color(0x4F00FF00);
local drawc0lorLasthit = Draw.Color(0xFF0000FF);

  if AnnieMenu.Draw.DrawRangeQ:Value() then Draw.Circle(myHero.pos,qSpellData.range,3,drawc0lor) end
  if AnnieMenu.Draw.DrawRangeW:Value() then Draw.Circle(myHero.pos,wSpellData.range,3,drawc0lor) end
  if AnnieMenu.Draw.DrawRangeR:Value() then Draw.Circle(myHero.pos,rSpellData.range,3,drawc0lor) end
    
  
    for i = 1, Game.MinionCount() do
      local minion = Game.Minion(i);
      if minion and minion.valid and minion.isEnemy and minion.visible then
        if minion.distance <= qSpellData.range then
          local spellDmg = getdmg("Q", minion, myHero);
          if spellDmg > minion.health then
          
            if AnnieMenu.LHQMinions.LHQM_Circle:Value() then
              Draw.Circle(minion.pos,minion.boundingRadius+10,4,drawc0lorLasthit);
              end
            
            if AnnieMenu.LHQMinions.Enabled:Value() then
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
        if hero.distance <= qSpellData.range then
          local spellDmg = getdmg("Q", hero, myHero);
          if spellDmg > hero.health then
          
            if AnnieMenu.Steal.StealQCircle:Value() then
              Draw.Circle(hero.pos,hero.boundingRadius+10,4,drawc0lorLasthit);
            end
            
            if AnnieMenu.Steal.StealQ:Value() then
              if (qSpellData.currentCd == 0) and (qSpellData.level > 0) then
                Control.CastSpell(HK_Q, hero)
              end
            end
          end
        end
        if hero.distance <= wSpellData.range then
          local spellDmg = getdmg("W", hero, myHero);
          if spellDmg > hero.health then
          
            if AnnieMenu.Steal.StealWCircle:Value() then
              Draw.Circle(hero.pos,hero.boundingRadius+10,4,drawc0lorLasthit);
            end
            
            if AnnieMenu.Steal.StealW:Value() then
              if (wSpellData.currentCd == 0) and (wSpellData.level > 0) then
                Control.CastSpell(HK_W, hero)
              end
            end
          end
        end
        if hero.distance <= qSpellData.range then
          local spellDmg = getdmg("R", hero, myHero);
          if spellDmg > hero.health then
          
            if AnnieMenu.Steal.StealRCircle:Value() then
              Draw.Circle(hero.pos,hero.boundingRadius+10,4,drawc0lorLasthit);
              end
            
            if AnnieMenu.Steal.StealR:Value() then
              if (rSpellData.currentCd == 0) and (rSpellData.level > 0) then
                Control.CastSpell(HK_R, hero.pos)
              end
            end
          end
        end
        local spellDmg = getdmg("R", hero, myHero)+getdmg("Q", hero, myHero)+getdmg("W", hero, myHero);
        if spellDmg > hero.health then
          if AnnieMenu.Steal.KillCombo:Value() and hero.distance <= 1000 then
            Draw.Text("MOLEST!!!!!", 16 ,myHero.pos2D.x-45, myHero.pos2D.y+30)
          end
        end    
      end
    end
  end  
end
