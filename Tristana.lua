if myHero.charName ~= "Tristana" then return end

require("DamageLib")

local TickH, TickL = 0, 0

local _EnemyHeroes

function GetEnemyHeroes()
  if _EnemyHeroes then return _EnemyHeroes end
  _EnemyHeroes = {}
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isEnemy then
      table.insert(_EnemyHeroes, unit)
    end
  end
  return _EnemyHeroes
end

function GetPercentHP(unit)
  if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  return 100*unit.health/unit.maxHealth
end

function GetRange(spell)
  return myHero:GetSpellData(spell).range
end

function GetSpeed(spell)
    return myHero:GetSpellData(spell).speed
end

function GetWidth(spell)
    return myHero:GetSpellData(spell).width
end

local function GetBuffs(unit)
  local t = {}
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.count > 0 then
      table.insert(t, buff)
    end
  end
  return t
end

function HasBuff(unit, buffname)
  if type(unit) ~= "userdata" then error("{HasBuff}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  if type(buffname) ~= "string" then error("{HasBuff}: bad argument #2 (string expected, got "..type(buffname)..")") end
  for i, buff in pairs(GetBuffs(unit)) do
    if buff.name == buffname then 
      return true
    end
  end
  return false
end

function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(unit).itemID == id then
      return i
    end
  end
  return 0 -- 
end

function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}--
end

function GetMinions(team) --> " " - All | 100 - Ally | 200 - Enemy | 300 - Jungle
    local Minions
    if Minions then return Minions end
    Minions = {}
    for i = 1, Game.MinionCount() do
        local Minion = Game.Minion(i)
        if team then
            if Minion.team == team then
                table.insert(Minions, Minion)
            end
        else
            table.insert(Minions, Minion)
        end
    end
    return Minions
end

function IsImmune(unit)
  if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  for i, buff in pairs(GetBuffs(unit)) do
    if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
      return true
    end
    if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then 
      return true
    end
  end
  return false
end

function IsValidTarget(unit, range, checkTeam, from)
  local range = range == nil and math.huge or range
  if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
  if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
  if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
  if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
    return false 
  end 
  return unit.pos:DistanceTo(from and from or myHero) < range 
end

function CountEnemiesInRange(point, range)
  if type(point) ~= "userdata" then error("{CountEnemiesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
  local range = range == nil and math.huge or range 
  if type(range) ~= "number" then error("{CountEnemiesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
  local n = 0
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if IsValidTarget(unit, range, true, point) then
      n = n + 1
    end
  end
  return n
end

function CanUseSpell(unit, spell)
    if unit:GetSpellData(spell).currentCd == 0 and unit.mana > unit:GetSpellData(spell).mana then
        return true
    else
        return false
    end
end


local function AngleBetween(p1, p2)
  local theta = p1:Polar() - p2:Polar()
  if theta < 0 then
    theta = theta + 360
  end
  if theta > 180 then
    theta = 360 - theta
  end
  return theta
end

function UnderEnemyTurret(unit)
        for i = 1, Game.TurretCount() do
            local turret = Game.Turret(i)
            local range = (turret.boundingRadius + 750 + myHero.boundingRadius / 2)
            if turret.valid and turret.isEnemy and unit.pos:DistanceTo(turret.pos) <= range then
                return true
            end
        end
        return false
end

local Config = MenuElement({type = MENU, name = "Tristana", id = "Tristana", leftIcon = "http://static.lolskill.net/img/champions/64/tristana.png"})

Config:MenuElement({type = MENU, name = "Combo Settings", id = "Combo"})
Config.Combo:MenuElement({type = MENU, name = "Rapid Fire (Q)", id = "Q", leftIcon= "http://static.lolskill.net/img/abilities/64/Tristana_Q.png"})
Config.Combo.Q:MenuElement({name = "Enabled", id = "Enabled", value = true})
Config.Combo:MenuElement({type = MENU, name = "Explosive Charge (E)", id = "E", leftIcon= "http://static.lolskill.net/img/abilities/64/Tristana_E.png"})
Config.Combo.E:MenuElement({name = "Enabled", id = "Enabled", value = true})
Config.Combo:MenuElement({type = MENU, name = "Buster Shot(R) Killsteal Combo Only", id = "R", leftIcon= "http://static.lolskill.net/img/abilities/64/Tristana_R.png"})
Config.Combo.R:MenuElement({name = "Enabled", id = "Enabled", value = true})


Config:MenuElement({type = MENU, name = "Killsteal Settings", id = "Steal"})
Config.Steal:MenuElement({type = MENU, name = "Buster Shot(R) Toggle", id = "R", leftIcon= "http://static.lolskill.net/img/abilities/64/Tristana_R.png"})
Config.Steal.R:MenuElement({name = "Enabled", id = "Enabled", value = true})

Config:MenuElement({type = MENU, name = "Key Settings", id = "Key"})
Config.Key:MenuElement({id = "Combo", name = "Combo", key = 32})

PrintChat("UPLOADED THIS FOR PPL TO TEST , QE NOT FINISHED TO WORK IN COMBO")

function OnTick()
  if not myHero.dead then
    local target = GetTarget(3000)
      if target then
        Combo(target)
        Steal(target)
      end
  end
end

function GetTarget(range)
        local target, _ = nil, nil
        for i = 1, #GetEnemyHeroes() do
        local Enemy = GetEnemyHeroes()[i]
        if IsValidTarget(Enemy, range, false, myHero.pos) then
            local K = Enemy.health / getdmg("AA", Enemy, myHero)
            if not _ or K < _ then
                target = Enemy
                _ = K
            end
        end
    end
    return target
end

function Combo()
  if Config.Key.Combo:Value() then
    for _, Enemy in pairs(GetEnemyHeroes()) do
      if Config.Combo.R.Enabled:Value() then
        if getdmg("R", Enemy, myHero) > Enemy.health then
          if CanUseSpell(myHero, _R) and IsValidTarget(Enemy, GetRange(_R), false, myHero.pos) then
            Control.CastSpell(HK_R, Enemy)
          end
        end  
      end
    end
  end   
end

function Steal()
    for _, Enemy in pairs(GetEnemyHeroes()) do
      if Config.Steal.R.Enabled:Value() then
        if getdmg("R", Enemy, myHero) > Enemy.health then
          if CanUseSpell(myHero, _R) and IsValidTarget(Enemy, GetRange(_R), false, myHero.pos) then
            Control.CastSpell(HK_R, Enemy)
          end
        end  
      end
    end 
end
