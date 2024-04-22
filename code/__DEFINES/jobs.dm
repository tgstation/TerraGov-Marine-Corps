
#define ENGSEC			(1<<0)

#define CAPTAIN			(1<<0)
#define HOS				(1<<1)
#define WARDEN			(1<<2)
#define DETECTIVE		(1<<3)
#define OFFICER			(1<<4)
#define CHIEF			(1<<5)
#define ENGINEER		(1<<6)
#define ATMOSTECH		(1<<7)
#define ROBOTICIST		(1<<8)
#define AI_JF			(1<<9)
#define CYBORG			(1<<10)


#define MEDSCI			(1<<1)

#define RD_JF			(1<<0)
#define SCIENTIST		(1<<1)
#define CHEMIST			(1<<2)
#define CMO_JF			(1<<3)
#define DOCTOR			(1<<4)
#define GENETICIST		(1<<5)
#define VIROLOGIST		(1<<6)


#define CIVILIAN		(1<<2)

#define HOP				(1<<0)
#define BARTENDER		(1<<1)
#define BOTANIST		(1<<2)
//#define COOK			(1<<3) //This is redefined below, and is a ss13 leftover.
#define JANITOR			(1<<4)
#define CURATOR			(1<<5)
#define QUARTERMASTER	(1<<6)
#define CARGOTECH		(1<<7)
//#define MINER			(1<<8) //This is redefined below, and is a ss13 leftover.
#define LAWYER			(1<<9)
#define CHAPLAIN		(1<<10)
#define CLOWN			(1<<11)
#define MIME			(1<<12)
#define ASSISTANT		(1<<13)

#define JOB_AVAILABLE 0
#define JOB_UNAVAILABLE_GENERIC 1
#define JOB_UNAVAILABLE_BANNED 2
#define JOB_UNAVAILABLE_PLAYTIME 3
#define JOB_UNAVAILABLE_ACCOUNTAGE 4
#define JOB_UNAVAILABLE_SLOTFULL 5
#define JOB_UNAVAILABLE_RACE 6
#define JOB_UNAVAILABLE_SEX 7
#define JOB_UNAVAILABLE_WTEAM 8
#define JOB_UNAVAILABLE_LASTCLASS 9
#define JOB_UNAVAILABLE_PATRON 10
#define JOB_UNAVAILABLE_ADVENTURER_COOLDOWN 11

#define DEFAULT_RELIGION "Christianity"
#define DEFAULT_DEITY "Space Jesus"

#define JOB_DISPLAY_ORDER_DEFAULT 0

#define JOB_DISPLAY_ORDER_ASSISTANT 1
#define JOB_DISPLAY_ORDER_CAPTAIN 2
#define JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL 3
#define JOB_DISPLAY_ORDER_QUARTERMASTER 4
#define JOB_DISPLAY_ORDER_CARGO_TECHNICIAN 5
#define JOB_DISPLAY_ORDER_SHAFT_MINER 6
#define JOB_DISPLAY_ORDER_BARTENDER 7
#define JOB_DISPLAY_ORDER_COOK 8
#define JOB_DISPLAY_ORDER_BOTANIST 9
#define JOB_DISPLAY_ORDER_JANITOR 10
#define JOB_DISPLAY_ORDER_CLOWN 11
#define JOB_DISPLAY_ORDER_MIME 12
#define JOB_DISPLAY_ORDER_CURATOR 13
#define JOB_DISPLAY_ORDER_LAWYER 14
#define JOB_DISPLAY_ORDER_CHAPLAIN 15
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER 16
#define JOB_DISPLAY_ORDER_STATION_ENGINEER 17
#define JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN 18
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER 19
#define JOB_DISPLAY_ORDER_MEDICAL_DOCTOR 20
#define JOB_DISPLAY_ORDER_CHEMIST 21
#define JOB_DISPLAY_ORDER_GENETICIST 22
#define JOB_DISPLAY_ORDER_VIROLOGIST 23
#define JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR 24
#define JOB_DISPLAY_ORDER_SCIENTIST 25
#define JOB_DISPLAY_ORDER_ROBOTICIST 26
#define JOB_DISPLAY_ORDER_HEAD_OF_SECURITY 27
#define JOB_DISPLAY_ORDER_WARDEN 28
#define JOB_DISPLAY_ORDER_DETECTIVE 29
#define JOB_DISPLAY_ORDER_SECURITY_OFFICER 30
#define JOB_DISPLAY_ORDER_AI 31
#define JOB_DISPLAY_ORDER_CYBORG 32

#define NOBLEMEN		(1<<0)

#define LORD		(1<<0)
#define STEWARD		(1<<1)
#define KNIGHT		(1<<2)
#define WIZARD		(1<<3)
#define SHERIFF		(1<<4)

#define GARRISON		(1<<1)

#define GUARDSMAN	(1<<0)
#define DUNGEONEER	(1<<1)
#define WATCHMAN	(1<<2)
#define WOODSMAN	(1<<3)

#define CHURCHMEN		(1<<2)

#define PRIEST		(1<<0)
#define CLERIC		(1<<1)
#define PURITAN		(1<<2)
#define MONK		(1<<3)

#define SERFS			(1<<3)

#define BARKEEP		(1<<0)
#define ARCHIVIST	(1<<1)
#define BLACKSMITH	(1<<2)
#define ALCHEMIST	(1<<3)
#define MASON		(1<<4)
#define TAILOR		(1<<5)
#define MERCHANT	(1<<6)
#define SCRIBE		(1<<7)

#define PEASANTS		(1<<4)

#define HUNTER		(1<<0)
#define FARMER		(1<<1)
#define BEASTMASTER	(1<<2)
#define FISHER		(1<<4)
#define LUMBERJACK	(1<<5)
#define GRAVEDIGGER	(1<<6)
#define MINER		(1<<7)
#define BUTLER		(1<<8)
#define JESTER		(1<<8)
#define ADVENTURER	(1<<9)
#define COOK		(1<<10)
#define GRABBER		(1<<11)

#define YOUNGFOLK		(1<<5)

#define APPRENTICE	(1<<0)
#define SQUIRE		(1<<1)
#define SERVANT		(1<<2)
#define ORPHAN		(1<<3)
#define PRINCE		(1<<4)

#define JCOLOR_NOBLE "#aa83b9"
#define JCOLOR_CHURCH "#c0ba8d"
#define JCOLOR_SOLDIER "#b18484"
#define JCOLOR_SERF "#819e82"
#define JCOLOR_PEASANT "#b6a68c"


// job display orders //

#define JDO_LORD 1
#define JDO_LADY 1.1
#define JDO_PRINCE 1.2
#define JDO_HAND 2
#define JDO_STEWARD 3

#define JDO_MAGICIAN 5
#define JDO_WAPP 6

#define JDO_SHERIFF 7
#define JDO_CASTLEGUARD 7.1
#define JDO_TOWNGUARD 8
#define JDO_BOGGUARD 8.1
#define JDO_GATEMASTER 9
#define JDO_BOGMASTER 9.1
#define JDO_DUNGEONEER 10
#define JDO_KNIGHT 10.1
#define JDO_SQUIRE 11
#define JDO_VET 11.1

#define JDO_PRIEST 12
#define JDO_CLERIC 13
#define JDO_MONK 14
#define JDO_TEMPLAR 14.1
#define JDO_CHURCHLING 15

#define JDO_PURITAN 16
#define JDO_SHEPHERD 17

#define JDO_MERCHANT 18
#define JDO_GRABBER 19

#define JDO_ARMORER 20
#define JDO_WSMITH 21
#define JDO_BAPP 22

#define JDO_MASON 23

#define JDO_BUTLER 24
#define JDO_SERVANT 25

#define JDO_BARKEEP 26
#define JDO_COOK 27

#define JDO_BUTCHER 27.1
#define JDO_SOILSON 27.2

#define JDO_GRAVEMAN 28

#define JDO_NIGHTMAN 28.1
#define JDO_NIGHTMAIDEN 28.2

#define JDO_JESTER 29
#define JDO_PRISONER 30

#define JDO_CHIEF 31
#define JDO_VILLAGER 32

#define JDO_ADVENTURER 32.1
#define JDO_PILGRIM 32.2

#define JDO_MERCENARY 33

#define JDO_VAGRANT 34
#define JDO_ORPHAN 35
