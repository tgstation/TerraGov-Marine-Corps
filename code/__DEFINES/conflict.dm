//Grab levels
#define GRAB_PASSIVE	0
#define GRAB_AGGRESSIVE	1
#define GRAB_NECK		2
#define GRAB_KILL		3

//intent defines
#define INTENT_HELP   "help"
#define INTENT_GRAB   "grab"
#define INTENT_DISARM "disarm"
#define INTENT_HARM "harm"
//NOTE: INTENT_HOTKEY_* defines are not actual intents!
//they are here to support hotkeys
#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"
//intent magic numbers associations.
#define INTENT_NUMBER_HELP		0
#define INTENT_NUMBER_DISARM	1
#define INTENT_NUMBER_GRAB		2
#define INTENT_NUMBER_HARM		3

//Ammo defines for gun/projectile related things.
#define AMMO_EXPLOSIVE 			1
#define AMMO_XENO_ACID 			2
#define AMMO_XENO_TOX			4
#define AMMO_ENERGY 			8
#define AMMO_ROCKET				16
#define AMMO_SNIPER				32
#define AMMO_INCENDIARY			64
#define AMMO_SKIPS_HUMANS		128
#define AMMO_SKIPS_ALIENS 		256
#define AMMO_IS_SILENCED 		512 //Unused right now.
#define AMMO_IGNORE_ARMOR		1024
#define AMMO_IGNORE_RESIST		2048
#define AMMO_BALLISTIC			4096

//Gun defines for gun related thing. More in the projectile folder.
#define GUN_CAN_POINTBLANK		(1 << 0)
#define GUN_TRIGGER_SAFETY		(1 << 1)
#define GUN_UNUSUAL_DESIGN		(1 << 2)
#define GUN_SILENCED			(1 << 3)
#define GUN_AUTOMATIC			(1 << 4)
#define GUN_INTERNAL_MAG		(1 << 5)
#define GUN_AUTO_EJECTOR		(1 << 6)
#define GUN_AMMO_COUNTER		(1 << 7)
#define GUN_BURST_ON			(1 << 8)
#define GUN_BURST_FIRING		(1 << 9)
#define GUN_FLASHLIGHT_ON		(1 << 10)
#define GUN_WIELDED_FIRING_ONLY	(1 << 11)
#define GUN_HAS_FULL_AUTO		(1 << 12)
#define GUN_FULL_AUTO_ON		(1 << 13)
#define GUN_POLICE				(1 << 14)
#define GUN_ENERGY				(1 << 15)
#define GUN_LOAD_INTO_CHAMBER	(1 << 16)
#define GUN_SHOTGUN_CHAMBER		(1 << 17)

//Gun attachable related flags.
#define ATTACH_REMOVABLE	1
#define ATTACH_ACTIVATION	2
#define ATTACH_PROJECTILE	4 //for attachments that fire bullets
#define ATTACH_RELOADABLE	8
#define ATTACH_WEAPON		16 //is a weapon that fires stuff
#define ATTACH_UTILITY		32 //for attachments with utility that trigger by 'shooting'

//Ammo magazine defines, for flags_magazine
#define AMMUNITION_REFILLABLE	1
#define AMMUNITION_HANDFUL		2

//Slowdown from various armors.
#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up

#define SLOWDOWN_ARMOR_VERY_LIGHT	0.20
#define SLOWDOWN_ARMOR_LIGHT		0.35
#define SLOWDOWN_ARMOR_MEDIUM		0.55
#define SLOWDOWN_ARMOR_HEAVY		1
#define SLOWDOWN_ARMOR_VERY_HEAVY	1.15

#define SLOWDOWN_ADS_SHOTGUN			0.35
#define SLOWDOWN_ADS_RIFLE				0.35
#define SLOWDOWN_ADS_SPECIALIST_LIGHT	0.75
#define SLOWDOWN_ADS_SCOPE				1
#define SLOWDOWN_ADS_SPECIALIST_MED		1
#define SLOWDOWN_ADS_INCINERATOR		1.75
#define SLOWDOWN_ADS_SPECIALIST_HEAVY	1.75
#define SLOWDOWN_ADS_SUPERWEAPON		2.75

//Wield delays, in milliseconds. 10 is 1 second
#define WIELD_DELAY_VERY_FAST		2
#define WIELD_DELAY_FAST			4
#define WIELD_DELAY_NORMAL			6
#define WIELD_DELAY_SLOW			10
#define WIELD_DELAY_VERY_SLOW		16
#define WIELD_DELAY_HORRIBLE		20
//=================================================

//Define detpack
#define DETPACK_TIMER_MIN			5
#define DETPACK_TIMER_MAX			300

//Define flamer
#define M240T_WATER_AMOUNT 			reagents.get_reagent_amount("water")

//Define sniper laser multipliers

#define SNIPER_LASER_DAMAGE_MULTIPLIER	1.5
#define SNIPER_LASER_ARMOR_MULTIPLIER	1.5

//Define lasgun
#define M37_STANDARD_AMMO_COST			20
#define M37_OVERCHARGE_AMMO_COST		80
#define M37_OVERCHARGE_FIRE_DELAY		10