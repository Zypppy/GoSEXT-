if myHero.charName ~= "Garen" then return end

require("DamageLib")


local GarenMenu = MenuElement({type = MENU, name = "Garen", id = "Garen", leftIcon = "http://static.lolskill.net/img/champions/64/garen.png"})

GarenMenu:MenuElement({id = "Enabled", name = "Script Enabled", value = true})
GarenMenu:MenuElement({type = MENU, name = "Drawings", id = "Draw"})
GarenMenu.Draw:MenuElement({id = "DrawRangeR", name = "Demacian Justice(R) Range", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Garen_R.png"})

GarenMenu:MenuElement({type = MENU, name = "Killsteal", id = "Steal"})
GarenMenu.Steal:MenuElement({id = "StealR", name = "Demacian Justice(R)", value = true, leftIcon= "http://static.lolskill.net/img/abilities/64/Garen_R.png"})
GarenMenu.Steal:MenuElement({id = "StealRCircle", name = "Draw Circle Indicator", value = true})

PrintChat("<3 ALL CREDITS TO FERETORIX")

function OnDraw()
if myHero.alive == false then return end --make sure we don't calc anything while dead <3

 if GarenMenu.Enabled:Value() then

 local rSpellData = myHero:GetSpellData(_R);
 local drawc0lor = Draw.Color(0x4F00FF00);
 local drawc0lorLasthit = Draw.Color(0xFF0000FF);
    if GarenMenu.Draw.DrawRangeR:Value() then Draw.Circle(myHero.pos,rSpellData.range,3,drawc0lor) end
      for i = 1, Game.HeroCount() do
       local hero = Game.Hero(i);
        if hero and hero.valid and hero.isEnemy and hero.visible then
         if hero.distance <= rSpellData.range then
          local spellDmg = getdmg("R", hero, myHero);
           if spellDmg > hero.health then
            if GarenMenu.Steal.StealRCircle:Value() then
             Draw.Circle(hero.pos,hero.boundingRadius+10,4,drawc0lorLasthit);
              end
               if GarenMenu.Steal.StealR:Value() then
                if (rSpellData.currentCd == 0) and (rSpellData.level > 0) then
                 Control.CastSpell(HK_R, hero)
                end
               end
              end
             end
            end
           end
         end
        end
 
           
