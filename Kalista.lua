if myHero.charName ~= "Kalista" then return end

require("DamageLib")


local KalistaMenu = MenuElement({type = MENU, name = "Kalista", id = "Kalista", leftIcon = "http://static.lolskill.net/img/champions/64/kalista.png"})
KalistaMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})
KalistaMenu:MenuElement({id = "DrawRange", name = "Draw Rend(E) Range", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Kalista_E.png"})
KalistaMenu:MenuElement({type = MENU, id = "LHChampions", name = "Auto Kill Champions"})
KalistaMenu.LHChampions:MenuElement({id = "Enabled", name = "Enabled", value = true})
KalistaMenu.LHChampions:MenuElement({id = "LHC_Circle", name = "Draw Circle Indicator", value = true})
KalistaMenu:MenuElement({type = MENU, id = "LHMinions", name = "Auto Kill Minions"})
KalistaMenu.LHMinions:MenuElement({id = "Enabled", name = "Enabled", value = true})
KalistaMenu.LHMinions:MenuElement({id = "LHM_Circle", name = "Draw Circle Indicator", value = true})

PrintChat("<3 ALL CREDITS TO FERETORIX")

function OnDraw()
if myHero.alive == false then return end --make sure we don't calc anything while dead <3

if KalistaMenu.Enabled:Value() then

local eSpellData = myHero:GetSpellData(_E);
local drawc0lor = Draw.Color(0x4F00FF00);
local drawc0lorLasthit = Draw.Color(0xFF0000FF);

  if KalistaMenu.DrawRange:Value() then Draw.Circle(myHero.pos,eSpellData.range,3,drawc0lor) end
    
  
    for i = 1, Game.MinionCount() do
      local minion = Game.Minion(i);
      if minion and minion.valid and minion.isEnemy and minion.visible then
        if minion.distance <= eSpellData.range then
          local spellDmg = getdmg("E", minion, myHero);
          if spellDmg > minion.health then
          
            if KalistaMenu.LHMinions.LHM_Circle:Value() then
              Draw.Circle(minion.pos,minion.boundingRadius+10,4,drawc0lorLasthit);
              end
            
            if KalistaMenu.LHMinions.Enabled:Value() then
              if (eSpellData.currentCd == 0) and (eSpellData.level > 0) then
                Control.CastSpell(HK_E)
                end
              end
            end
          end
        end
      end

    
    
    for i = 1, Game.HeroCount() do
      local hero = Game.Hero(i);
      if hero and hero.valid and hero.isEnemy and hero.visible then
        if hero.distance <= eSpellData.range then
          local spellDmg = getdmg("E", hero, myHero);
          if spellDmg > hero.health then
          
            if KalistaMenu.LHChampions.LHC_Circle:Value() then
              Draw.Circle(hero.pos,hero.boundingRadius+10,4,drawc0lorLasthit);
              end
            
            if KalistaMenu.LHChampions.Enabled:Value() then
              if (eSpellData.currentCd == 0) and (eSpellData.level > 0) then
                Control.CastSpell(HK_E)
                end
              end
            end
          end
        end
      end
      
  end
end
