--if myHero.charName ~= "kha'zix" then return end

require("DamageLib")

local TickH, TickL = 0, 0

local _AllyHeroes

function GetAllyHeroes()
  if _AllyHeroes then return _AllyHeroes end
  _AllyHeroes = {}
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly then
      table.insert(_AllyHeroes, unit)
    end
  end
  return _AllyHeroes
end

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

function GetPercentMP(unit)
  if type(unit) ~= "userdata" then error("{GetPercentMP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  return 100*unit.mana/unit.maxMana
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

function CountAlliesInRange(point, range)
  if type(point) ~= "userdata" then error("{CountAlliesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
  local range = range == nil and math.huge or range 
  if type(range) ~= "number" then error("{CountAlliesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
  local n = 0
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly and not unit.isMe and IsValidTarget(unit, range, false, point) then
      n = n + 1
    end
  end
  return n
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

local fountain

for i = 1, Game.ObjectCount() do
  local object = Game.Object(i)
  if object.isEnemy or object.type ~= Obj_AI_SpawnPoint then 
    goto continue
  end
  fountain = object
  break
  ::continue::
end

function InFountain(unit)
  if type(unit) ~= "userdata" then error("{InFountain}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  local range = Game.mapID() == SUMMONERS_RIFT and 1100 or 750
  return unit.visible and unit.pos:DistanceTo(fountain)-unit.boundingRadius <= range
end

function InShop(unit)
  if type(unit) ~= "userdata" then error("{InShop}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  local range = Game.mapID() == SUMMONERS_RIFT and 1000 or 750
  return unit.visible and unit.pos:DistanceTo(fountain)-unit.boundingRadius <= range
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

function IsFacing(unit, target)
  if type(unit) ~= "userdata" then error("{IsFacing}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  if type(target) ~= "userdata" then error("{IsFacing}: bad argument #2 (userdata expected, got "..type(target)..")") end
  return AngleBetween(unit.dir, target.pos-unit.pos) < 90
end

function IsOnScreen(pos)
  if type(pos) ~= "userdata" then error("{IsOnScreen}: bad argument #1 (vector expected, got "..type(pos)..")") end
  local p = pos.pos2D
  local res = Game.Resolution()
  return p.x > 0 and p.y > 0 and p.x <= res.x and p.y <= res.y
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

local Config = MenuElement({type = MENU, name = "KhaZix", id = "KhaZix", leftIcon = "http://static.lolskill.net/img/champions/64/khazix.png"})
--Config:MenuElement({type = MENU, name = "Last Hit Settings", id = "LastHit"})
--Config.LastHit:MenuElement({type = MENU, name = "Taste Their Fear (Q)", id = "Q", leftIcon = "http://static.lolskill.net/img/abilities/64/Khazix_Q.png"})
--Config.LastHit.Q:MenuElement({name = "Enabled", id = "Enabled", value = true})
--Config:MenuElement({type = MENU, name = "Key Settings", id = "Key"})
--Config.Key:MenuElement({id = "LastHit", name = "Last Hit Q", key = string.byte("Z")})
Config:MenuElement({type = MENU, name = "Combo Settings", id = "Combo"})
Config.Combo:MenuElement({type = MENU, name = "Taste Their Fear (Q)", id = "Q", leftIcon = "http://static.lolskill.net/img/abilities/64/Khazix_Q.png"})
Config.Combo.Q:MenuElement({name = "Enabled", id = "Enabled", value = true})
Config.Combo:MenuElement({type = MENU, name = "Void Spike (W)", id = "W", leftIcon = "http://static.lolskill.net/img/abilities/64/Khazix_W.png"})
Config.Combo.W:MenuElement({name = "Enabled", id = "Enabled", value = true})
Config.Combo:MenuElement({type = MENU, name = "Leap (E)", id = "E", leftIcon = "http://static.lolskill.net/img/abilities/64/Khazix_E.png"})
Config.Combo.E:MenuElement({name = "Enabled", id = "Enabled", value = true})
Config.Combo:MenuElement({type = MENU, name = "Void Assault (R)", id = "R", leftIcon = "http://static.lolskill.net/img/abilities/64/Khazix_R.png"})
Config.Combo.R:MenuElement({name = "Enabled", id = "Enabled", value = true})

Config:MenuElement({type = MENU, name = "Jungle Clear Settings", id = "Jungle"})
Config.Jungle:MenuElement({type = MENU, name = "Taste Their Fear (Q)", id = "Q", leftIcon = "http://static.lolskill.net/img/abilities/64/Khazix_Q.png"})
Config.Jungle.Q:MenuElement({name = "Enabled", id = "Enabled", value = true})
Config.Jungle:MenuElement({type = MENU, name = "Void Spike (W)", id = "W", leftIcon = "http://static.lolskill.net/img/abilities/64/Khazix_W.png"})
Config.Jungle.W:MenuElement({name = "Enabled", id = "Enabled", value = true})

Config:MenuElement({type = MENU, name = "Key Settings", id = "Key"})
Config.Key:MenuElement({id = "Combo", name = "Combo", key = 32})
Config.Key:MenuElement({id = "Jungle", name = "Jungle", key = string.byte("V")})

function OnTick()
        if not myHero.dead then
                local target = GetTarget(3000)
                if target then
                        Combo(target)

                end
                Jungle()
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

function Combo(target)
        if Config.Key.Combo:Value() then
                if Config.Combo.Q.Enabled:Value() then
                        if CanUseSpell(myHero, _Q) and IsValidTarget(target, GetRange(_Q), false, myHero.pos) then
                                Control.CastSpell(HK_Q, target.pos)
                        end
                end
                if Config.Combo.W.Enabled:Value() then
                        if CanUseSpell(myHero, _W) and IsValidTarget(target, GetRange(_W)-40, true, myHero.pos) then
                                Control.CastSpell(HK_W, target.pos)
                        end
                end
                if Config.Combo.E.Enabled:Value() then
                        if CanUseSpell(myHero, _E) and IsValidTarget(target, GetRange(_E), true, myHero.pos) then
                                Control.CastSpell(HK_E, target.pos)
                        end
                end
                if Config.Combo.R.Enabled:Value() then
                        if CanUseSpell(myHero, _R) and GetTarget(700) then
                                Control.CastSpell(HK_R)
                        end
                end
        end
end

function  Jungle()
    if Config.Key.Jungle:Value() then    
        for _, Minion in pairs(GetMinions(300)) do
            if Config.Jungle.Q.Enabled:Value() and CanUseSpell(myHero, _Q) and IsValidTarget(Minion, GetRange(_Q), false, myHero.pos) then
                Control.CastSpell(HK_Q, Minion.pos)
            end
            if Config.Jungle.W.Enabled:Value() and CanUseSpell(myHero, _W) and IsValidTarget(Minion, GetRange(_W), false, myHero.pos) then
                Control.CastSpell(HK_W, Minion.pos)
            end
        end
   end
end

--function LastHit()
--        if Config.LastHit.Q.Enabled:Value() then
--                for _, Minion in pairs(GetMinions(200)) do
--                        if getdmg("Q", Minion, myHero) > Minion.health then
--                                if CanUseSpell(myHero, _Q) and IsValidTarget(Minion, GetRange(_Q), false, myHero.pos) then
--                                    Control.CastSpell(HK_Q, Minion.pos)
--                            end
--                        end
--                end
--        end
--end
