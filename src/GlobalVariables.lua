require "Helper"
--[[
Monster Actors Values：
]]--

---hurtEffect
cc.SpriteFrameCache:getInstance():addSpriteFrames("FX/FX.plist")
animationCathe = cc.AnimationCache:getInstance()
local hurtAnimation = cc.Animation:create()
for i=1,5 do
    name = "hit"..i..".png"
    hurtAnimation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(name))
end
hurtAnimation:setDelayPerUnit(0.1)
animationCathe:addAnimation(hurtAnimation,"hurtAnimation")

FXZorder = 1999

--G values
G =
{
    winSize = cc.Director:getInstance():getWinSize(),
    bloodPercentDropSpeed = 2,
    activearea = {left = -2800, right = 500, bottom = 100, top = 700},
}
FXZorder = 1999


--Audios
BGM_RES = 
{
    MAINMENUBGM = "audios/Royal Flush Party.mp3",
    MAINMENUSTART= "audios/effects/magical_3.mp3",
    BATTLEFIELDBGM = "audios/The_Last_Encounter_Short_Loop.mp3",
    CHOOSEROLESCENEBGM = "audios/Imminent Threat Beat B FULL Loop.mp3"
}

--play2d id
AUDIO_ID = 
{
    MAINMENUBGM,
    BATTLEFIELDBGM,
    CHOOSEROLECHAPTERBGM,
    KNIGHTNORMALATTACK,
    KNIGHTSPECIALATTACK,
    ARCHERATTACK
}
EnumRaceType = 
    { 
        "DEBUG",
        "BASE",
        "HERO",  --only this
        "WARRIOR",
        "KNIGHT",
        "ARCHER",
        "MAGE",
        "MONSTER", --and this
        "BOSS", 
        "DRAGON",
    }
EnumRaceType = CreateEnumTable(EnumRaceType) 

EnumStateType =
    {
        "IDLE",
        "WALKING",
        "ATTACKING",
        "DEFENDING",
        "KNOCKING",
        "DYING",
        "DEAD"
    }
EnumStateType = CreateEnumTable(EnumStateType) 
--common value is used to reset an actor
ActorCommonValues =
{
    _aliveTime      = 0, --time the actor is alive in seconds
    _curSpeed       = 0, --current speed the actor is traveling in units/seconds
    _curAnimation   = nil,
    _curAnimation3d = nil,
    
    --runtime modified values
    _curFacing      = 0, -- current direction the actor is facing, in radians, 0 is to the right
    _isalive        = true,
    _AITimer        = 0, -- accumulated timer before AI will execute, in seconds
    _AIEnabled      = false, --if false, AI will not run
    _attackTimer    = 0, --accumulated timer to decide when to attack, in seconds
    _timeKnocked    = 0, --accumulated timer to recover from knock, in seconds
    _cooldown       = false, --if its true, then you are currently playing attacking animation,
    _hp             = 1000, --current hit point
    _goRight        = true,
    
    --target variables
    _targetFacing   = 0, --direction the actor Wants to turn to
    
    _target         = nil, --the enemy actor 
}
ActorDefaultValues =
{
    _racetype       = EnumRaceType.HERO, --type of the actor
    _statetype      = nil, -- AI state machine
    _sprite3d       = nil, --place to hold 3d model
    
    _radius         = 50, --actor collider size
    _mass           = 100, --weight of the role, it affects collision
    _shadowSize     = 70, --the size of the shadow under the actor

    --character strength
    _maxhp          = 1000,
    _defense        = 100,
    _specialAttackChance = 0, 
    _recoverTime    = 0.8,--time takes to recover from knock, in seconds
    
    _speed          = 500, --actor maximum movement speed in units/seconds
    _turnSpeed      = DEGREES_TO_RADIANS(225), --actor turning speed in radians/seconds
    _acceleration   = 750, --actor movement acceleration, in units/seconds
    _decceleration  = 750*1.7, --actor movement decceleration, in units/seconds
    
    _AIFrequency    = 1.0, --how often AI executes in seconds
    _attackFrequency = 4.0, --an attack move every few seconds
    _searchDistance = 5000, --distance which enemy can be found

    _attackRange    = 100, --distance the actor will stop and commence attack
    
    --attack collider info, it can be customized
    _normalAttack   = {--data for normal attack
        minRange = 0, -- collider inner radius
        maxRange = 130, --collider outer radius
        angle    = DEGREES_TO_RADIANS(30), -- collider angle, 360 for full circle, other wise, a fan shape is created
        knock    = 50, --attack knock back distance
        damage   = 100, -- attack damage
        mask     = EnumRaceType.HERO, -- who created this attack collider
        duration = 0, -- 0 duration means it will be removed upon calculation
        speed    = 0, -- speed the collider is traveling
        criticalChance=0
    }, 
}
KnightValues = {
    _racetype       = EnumRaceType.KNIGHT,
    _name           = "Knight",
    _radius         = 50,
    _mass           = 1000,
    _shadowSize     = 70,
    
    _hp             = 1500,
    _maxhp          = 1500,
    _defense        = 150,
    _attackFrequency = 2.5,
    _recoverTime    = 0.5,
    _AIFrequency    = 1.1,
    _attackRange    = 100,
    _specialAttackChance = 0.33,
    
    _normalAttack   = {
        minRange = 0,
        maxRange = 130,
        angle    = DEGREES_TO_RADIANS(30),
        knock    = 60,
        damage   = 250,
        mask     = EnumRaceType.KNIGHT,
        duration = 0,
        speed    = 0,
        criticalChance = 0.3
    }, 
    _specialAttack   = {
        minRange = 0,
        maxRange = 180,
        angle    = DEGREES_TO_RADIANS(150),
        knock    = 100,
        damage   = 320,
        mask     = EnumRaceType.KNIGHT,
        duration = 0,
        speed    = 0,
        criticalChance = 0.3
    }, 
}
MageValues = {
    _racetype       = EnumRaceType.MAGE,
    _name           = "Mage",
    _radius         = 50,
    _mass           = 800,
    _shadowSize     = 70,

    _hp             = 1100,
    _maxhp          = 1100,
    _defense        = 120,
    _attackFrequency = 2.67,
    _recoverTime    = 0.8,
    _AIFrequency    = 1.33,
    _attackRange    = 666,
    _specialAttackChance = 0.3,

    _normalAttack   = {
        minRange = 0,
        maxRange = 50,
        angle    = DEGREES_TO_RADIANS(360),
        knock    = 10,
        damage   = 280,
        mask     = EnumRaceType.MAGE,
        duration = 1.5,
        speed    = 400,
        criticalChance = 0.3
    }, 
    _specialAttack   = {
        minRange = 0,
        maxRange = 140,
        angle    = DEGREES_TO_RADIANS(360),
        knock    = 75,
        damage   = 250,
        mask     = EnumRaceType.MAGE,
        duration = 1.5,
        speed    = 0,
        criticalChance = 0.3
    }, 
}
ArcherValues = {
    _racetype       = EnumRaceType.ARCHER,
    _name           = "Archer",
    _radius         = 50,
    _mass           = 800,
    _shadowSize     = 70,

    _hp             = 1200,
    _maxhp          = 1200,
    _defense        = 130,
    _attackFrequency = 4.7,
    _recoverTime    = 0.4,
    _AIFrequency    = 1.3,
    _attackRange    = 800,
    _specialAttackChance = 0.33,

    _normalAttack   = {
        minRange = 0,
        maxRange = 30,
        angle    = DEGREES_TO_RADIANS(360),
        knock    = 100,
        damage   = 230,
        mask     = EnumRaceType.ARCHER,
        duration = 2,
        speed    = 900,
        criticalChance = 0.3
    }, 
    _specialAttack   = {
        minRange = 0,
        maxRange = 30,
        angle    = DEGREES_TO_RADIANS(360),
        knock    = 75,
        damage   = 285,
        mask     = EnumRaceType.ARCHER,
        duration = 2,
        speed    = 850,
        criticalChance = 0.3
    }, 
}
DragonValues = {
    _racetype       = EnumRaceType.MONSTER,
    _name           = "Dragon",
    _radius         = 50,
    _mass           = 100,
    _shadowSize     = 70,

    _hp             = 600,
    _maxhp          = 600,
    _defense        = 130,
    _attackFrequency = 4.8,
    _recoverTime    = 0.8,
    _AIFrequency    = 1.337,
    _attackRange    = 650,
    
    _speed          = 300,
    _turnSpeed      = DEGREES_TO_RADIANS(180),
    _acceleration   = 250,
    _decceleration  = 750*1.7,

    _normalAttack   = {
        minRange = 0,
        maxRange = 50,
        angle    = DEGREES_TO_RADIANS(360),
        knock    = 100,
        damage   = 380,
        mask     = EnumRaceType.MONSTER,
        duration = 3,
        speed    = 350,
        criticalChance = 0.3
    }, 
}
SlimeValues = {
    _racetype       = EnumRaceType.MONSTER,
    _name           = "Slime",
    _radius         = 25,
    _mass           = 20,
    _shadowSize     = 20,

    _hp             = 300,
    _maxhp          = 300,
    _defense        = 65,
    _attackFrequency = 1.5,
    _recoverTime    = 0.7,
    _AIFrequency    = 3.3,
    _attackRange    = 50,
    
    _speed          = 150,
    _turnSpeed      = DEGREES_TO_RADIANS(270),
    _acceleration   = 9999,
    _decceleration  = 9999,

    _normalAttack   = {
        minRange = 0,
        maxRange = 50,
        angle    = DEGREES_TO_RADIANS(360),
        knock    = 0,
        damage   = 135,
        mask     = EnumRaceType.MONSTER,
        duration = 0,
        speed    = 0,
        criticalChance = 0.3
    }, 
}
PigletValues = {
    _racetype       = EnumRaceType.MONSTER,
    _name           = "Piglet",
    _radius         = 50,
    _mass           = 69,
    _shadowSize     = 60,

    _hp             = 400,
    _maxhp          = 400,
    _defense        = 65,
    _attackFrequency = 4.73,
    _recoverTime    = 0.9,
    _AIFrequency    = 4.3,
    _attackRange    = 120,

    _speed          = 350,
    _turnSpeed      = DEGREES_TO_RADIANS(270),
    _acceleration   = 9999,
    _decceleration  = 9999,

    _normalAttack   = {
        minRange = 0,
        maxRange = 120,
        angle    = DEGREES_TO_RADIANS(50),
        knock    = 0,
        damage   = 150,
        mask     = EnumRaceType.MONSTER,
        duration = 0,
        speed    = 0,
        criticalChance = 0.3
    }, 
}
RatValues = {
    _racetype       = EnumRaceType.MONSTER,
    _name           = "Rat",
    _radius         = 50,
    _mass           = 100,
    _shadowSize     = 65,

    _hp             = 400,
    _maxhp          = 450,
    _defense        = 170,
    _attackFrequency = 3.7,
    _recoverTime    = 0.4,
    _AIFrequency    = 5.3,
    _attackRange    = 110,

    _speed          = 300,
    _turnSpeed      = DEGREES_TO_RADIANS(225),
    _acceleration   = 450,
    _decceleration  = 750*1.7,

    _normalAttack   = {
        minRange = 0,
        maxRange = 110,
        angle    = DEGREES_TO_RADIANS(100),
        knock    = 50,
        damage   = 200,
        mask     = EnumRaceType.MONSTER,
        duration = 0,
        speed    = 0,
        criticalChance = 0.3
    }, 
}

--Some common audios
CommonAudios =
{
    hit = "audios/effects/hit20.mp3"
}

--Monster Slime
MonsterSlimeValues =
{
    fileNameNormal = "model/slime/slimeAnger.c3b",
    fileNameAnger = "model/slime/slimeAnger.c3b"
}

--Monster Dragon
MonsterDragonValues = 
{
    fileName = "model/dragon/dragon.c3b"
}

--Monster Rat
MonsterRatValues = 
    {
        fileName = "model/rat/rat.c3b"
    }

--Monster Piglet
MonsterPigletValues = 
{
    fileName = "model/piglet/piglet.c3b",
    attack1 = "audios/effects/piglet/piglet1.mp3",
    attack2 = "audios/effects/piglet/piglet2.mp3",
    attack3 = "audios/effects/piglet/piglet3.mp3",
    dead = "audios/effects/piglet/dead.mp3",
    hurt = "audios/effects/piglet/hurt.mp3",
}
    
--Warroir property
WarriorProperty =
{
    normalAttack1 = "audios/effects/knight/swish-1.mp3",
    normalAttack2 = "audios/effects/knight/swish-2.mp3",
    specialAttack1 = "audios/effects/knight/swish-3.mp3",
    specialAttack2 = "audios/effects/knight/swish-4.mp3",
    kickit = "audios/effects/knight/kickit.mp3",
    normalAttackShout = "audios/effects/knight/normalAttackShout.mp3",
    specialAttackShout = "audios/effects/knight/specialAttackShout.mp3",
    wounded = "audios/effects/knight/wounded.mp3"
}

--Archer property
Archerproperty =
{
    attack1 = "audios/effects/archer/swish-3.mp3",
    attack2 = "audios/effects/archer/swish-4.mp3",
    wow = "audios/effects/archer/wow.mp3",
    cheers = "audios/effects/archer/cheers.mp3"
}

--Mage property
MageProperty =
{
    blood = 1000,
    attack = 100,
    defense = 100,
    speed = 50,
    special_attack_chance = 0.33,
    normalAttack = "audios/effects/mage/yeaha.mp3",
    alright = "audios/effects/mage/alright.mp3",
    ice_normal = "audios/effects/mage/ice_1.mp3",
    ice_special = "audios/effects/mage/ice_2.mp3",
    ice_normalAttackHit = "audios/effects/mage/ice_3.mp3",
    ice_specialAttackHit = "audios/effects/mage/ice_4.mp3"
}