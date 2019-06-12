//click cooldowns, in tenths of a second, used for various combat actions
#define CLICK_CD_FASTEST 1
#define CLICK_CD_RAPID 2
#define CLICK_CD_RANGE 4
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_MELEE 8
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_GRABBING 10
#define CLICK_CD_RESIST 20
#define CLICK_CD_BREAKOUT 100

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
//flags_ammo_behavior
#define AMMO_EXPLOSIVE 			(1<<0)
#define AMMO_XENO_ACID 			(1<<1)
#define AMMO_XENO_TOX			(1<<2)
#define AMMO_ENERGY 			(1<<3)
#define AMMO_ROCKET				(1<<4)
#define AMMO_SNIPER				(1<<5)
#define AMMO_INCENDIARY			(1<<6)
#define AMMO_SKIPS_HUMANS		(1<<7)
#define AMMO_SKIPS_ALIENS 		(1<<8)
#define AMMO_IS_SILENCED 		(1<<9) //Unused right now.
#define AMMO_IGNORE_ARMOR		(1<<10)
#define AMMO_IGNORE_RESIST		(1<<11)
#define AMMO_BALLISTIC			(1<<12)

//Gun defines for gun related thing. More in the projectile folder.
//flags_gun_features
#define GUN_CAN_POINTBLANK		(1<<0)
#define GUN_TRIGGER_SAFETY		(1<<1)
#define GUN_UNUSUAL_DESIGN		(1<<2)
#define GUN_SILENCED			(1<<3)
#define GUN_AUTOMATIC			(1<<4)
#define GUN_INTERNAL_MAG		(1<<5)
#define GUN_AUTO_EJECTOR		(1<<6)
#define GUN_AMMO_COUNTER		(1<<7)
#define GUN_BURST_ON			(1<<8)
#define GUN_BURST_FIRING		(1<<9)
#define GUN_FLASHLIGHT_ON		(1<<10)
#define GUN_WIELDED_FIRING_ONLY	(1<<11)
#define GUN_HAS_FULL_AUTO		(1<<12)
#define GUN_FULL_AUTO_ON		(1<<13)
#define GUN_POLICE				(1<<14)
#define GUN_ENERGY				(1<<15)
#define GUN_LOAD_INTO_CHAMBER	(1<<16)
#define GUN_SHOTGUN_CHAMBER		(1<<17)

//Gun attachable related flags.
//flags_attach_features
#define ATTACH_REMOVABLE	(1<<0)
#define ATTACH_ACTIVATION	(1<<1)
#define ATTACH_PROJECTILE	(1<<2) //for attachments that fire bullets
#define ATTACH_RELOADABLE	(1<<3)
#define ATTACH_WEAPON		(1<<4) //is a weapon that fires stuff
#define ATTACH_UTILITY		(1<<5) //for attachments with utility that trigger by 'shooting'

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

#define SNIPER_LASER_DAMAGE_MULTIPLIER	1.5 //+50% damage vs the aimed target
#define SNIPER_LASER_ARMOR_MULTIPLIER	1.5 //+50% penetration vs the aimed target
#define SNIPER_LASER_SLOWDOWN_STACKS	3

//Define lasgun
#define M43_STANDARD_AMMO_COST			20
#define M43_OVERCHARGE_AMMO_COST		80
#define M43_OVERCHARGE_FIRE_DELAY		10

//Define smoke effects
#define SMOKE_COUGH			(1<<0)
#define SMOKE_GASP			(1<<1)
#define SMOKE_OXYLOSS		(1<<2)
#define SMOKE_FOUL			(1<<3)
#define SMOKE_NERF_BEAM		(1<<4)
#define SMOKE_CAMO			(1<<5)
#define SMOKE_SLEEP			(1<<6)
#define SMOKE_BLISTERING	(1<<7)
#define SMOKE_PLASMALOSS	(1<<8)
#define SMOKE_XENO			(1<<9)
#define SMOKE_XENO_ACID		(1<<10)
#define SMOKE_XENO_NEURO	(1<<11)
#define SMOKE_CHEM			(1<<12)
