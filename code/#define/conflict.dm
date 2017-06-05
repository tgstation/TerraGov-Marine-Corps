//Grab levels
#define GRAB_PASSIVE	0
#define GRAB_AGGRESSIVE	1
#define GRAB_NECK		2
#define GRAB_KILL		3

//Ammo defines for gun/projectile related things.
#define AMMO_REGULAR 		0 //Just as a reminder.
#define AMMO_EXPLOSIVE 		1
#define AMMO_XENO_ACID 		2
#define AMMO_XENO_TOX		4
#define AMMO_ENERGY 		8
#define AMMO_ROCKET			16
#define AMMO_SNIPER			32
#define AMMO_INCENDIARY		64
#define AMMO_SKIPS_HUMANS	128
#define AMMO_SKIPS_ALIENS 	256
#define AMMO_IS_SILENCED 	512 //Unused right now.
#define AMMO_IGNORE_ARMOR	1024
#define AMMO_IGNORE_RESIST	2048
#define AMMO_BALLISTIC		4096

//Gun defines for gun related thing. More in the projectile folder.
#define GUN_CAN_POINTBLANK		1
#define GUN_TRIGGER_SAFETY		2
#define GUN_UNUSUAL_DESIGN		4
#define GUN_SILENCED			8
#define GUN_AUTOMATIC			16
#define GUN_INTERNAL_MAG		32
#define GUN_AUTO_EJECTOR		64
#define GUN_AMMO_COUNTER		128
#define GUN_BURST_ON			256
#define GUN_BURST_FIRING		512
#define GUN_FLASHLIGHT_ON		1024
#define GUN_ON_MERCS			2048 //Unused right now.
#define GUN_ON_RUSSIANS			4096 //Unused right now.
#define GUN_WY_RESTRICTED		8192
#define GUN_SPECIALIST			16384

//Gun attachable related flags.
#define ATTACH_PASSIVE		1
#define ATTACH_REMOVABLE	2
#define ATTACH_CONTINUOUS	4
#define ATTACH_ACTIVATION	8
#define ATTACH_PROJECTILE	16

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

#define SLOWDOWN_ADS_SHOTGUN		0.75
#define SLOWDOWN_ADS_RIFLE			0.75
#define SLOWDOWN_ADS_SCOPE			0.5
#define SLOWDOWN_ADS_INCINERATOR	1.1
#define SLOWDOWN_ADS_SPECIALIST		1.5
#define SLOWDOWN_ADS_SUPERWEAPON	2

#define WIELD_DELAY_SCOPE			5
//=================================================