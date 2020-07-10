//click cooldowns, in tenths of a second, used for various combat actions
#define CLICK_CD_FASTEST 1
#define CLICK_CD_RAPID 2
#define CLICK_CD_RANGE 4
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_MELEE 8
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_GRABBING 10
#define CLICK_CD_RESIST 10
#define CLICK_CD_LONG 20
#define CLICK_CD_RESIST_PSYCHIC_GRAB 30
#define CLICK_CD_BREAKOUT 100

//Grab levels
#define GRAB_PASSIVE	0
#define GRAB_AGGRESSIVE	1
#define GRAB_NECK		2
#define GRAB_KILL		3

//TK Grab levels
#define TKGRAB_NONLETHAL	3	//Values should be different as they are identifiers.
#define TKGRAB_LETHAL		4	//Also serves as a measure of how many attempts to resist it.

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
#define AMMO_XENO 				(1<<1)
#define AMMO_XENO_TOX			(1<<2) //Unused value.
#define AMMO_ENERGY 			(1<<3)
#define AMMO_ROCKET				(1<<4)
#define AMMO_SNIPER				(1<<5)
#define AMMO_INCENDIARY			(1<<6)
#define AMMO_SKIPS_HUMANS		(1<<7)
#define AMMO_SKIPS_ALIENS 		(1<<8)
#define AMMO_IS_SILENCED 		(1<<9) //Unused right now.
#define AMMO_IGNORE_ARMOR		(1<<10)
#define AMMO_IGNORE_RESIST		(1<<11) //Unused.
#define AMMO_BALLISTIC			(1<<12)
#define AMMO_SUNDERING			(1<<13)

//Gun defines for gun related thing. More in the projectile folder.
//flags_gun_features
#define GUN_CAN_POINTBLANK		(1<<0)
#define GUN_TRIGGER_SAFETY		(1<<1)
#define GUN_UNUSUAL_DESIGN		(1<<2)
#define GUN_SILENCED			(1<<3)
#define GUN_SHOTGUN_CHAMBER		(1<<4)
#define GUN_INTERNAL_MAG		(1<<5)
#define GUN_AUTO_EJECTOR		(1<<6)
#define GUN_AMMO_COUNTER		(1<<7)
#define GUN_LOAD_INTO_CHAMBER	(1<<8)
#define GUN_ENERGY				(1<<9)
#define GUN_FLASHLIGHT_ON		(1<<10)
#define GUN_WIELDED_FIRING_ONLY	(1<<11)
#define GUN_POLICE				(1<<12)
#define GUN_BURST_FIRING		(1<<13)
#define GUN_ALLOW_SYNTHETIC		(1<<14)
#define GUN_HAS_AUTOBURST		(1<<15)

#define GUN_FIREMODE_SEMIAUTO "semi-auto fire mode"
#define GUN_FIREMODE_BURSTFIRE "burst-fire mode"
#define GUN_FIREMODE_AUTOMATIC "automatic fire mode"
#define GUN_FIREMODE_AUTOBURST "auto-burst-fire mode"

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


//=================================================

//Define detpack
#define DETPACK_TIMER_MIN			5
#define DETPACK_TIMER_MAX			300

//Define flamer
#define MARINESTANDARD_WATER_AMOUNT 			reagents.get_reagent_amount(/datum/reagent/water)

//Define sniper laser multipliers

#define SNIPER_LASER_DAMAGE_MULTIPLIER	1.5 //+50% damage vs the aimed target
#define SNIPER_LASER_ARMOR_MULTIPLIER	1.5 //+50% penetration vs the aimed target
#define SNIPER_LASER_SLOWDOWN_STACKS	3

//Define lasrifle
#define ENERGY_STANDARD_AMMO_COST			20
#define ENERGY_OVERCHARGE_AMMO_COST		80
#define ENERGY_OVERCHARGE_FIRE_DELAY		10

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


//Incapacitated
#define INCAPACITATED_IGNORE_RESTRAINED (1<<0)
#define INCAPACITATED_IGNORE_GRAB (1<<1)


//Restraints
#define RESTRAINED_XENO_NEST (1<<0)
#define RESTRAINED_NECKGRAB (1<<1)
#define RESTRAINED_STRAIGHTJACKET (1<<2)
#define RESTRAINED_RAZORWIRE (1<<3)
#define RESTRAINED_PSYCHICGRAB (1<<4)


//Explosion resistance
#define XENO_BOMB_RESIST_4 100
#define XENO_BOMB_RESIST_3 80
#define XENO_BOMB_RESIST_2 60
#define XENO_BOMB_RESIST_1 40
#define XENO_BOMB_RESIST_0 0

#define SINGLE_CASING	(1 << 0)
#define SPEEDLOADER		(1 << 1)
#define MAGAZINE		(1 << 2)
#define CELL			(1 << 3)
#define POWERPACK		(1 << 4)

#define EGG_BURST 0
#define EGG_BURSTING 1
#define EGG_GROWING 2
#define EGG_GROWN 3
#define EGG_DESTROYED 4

#define EGG_MIN_GROWTH_TIME 10 SECONDS //time it takes for the egg to mature once planted
#define EGG_MAX_GROWTH_TIME 15 SECONDS

#define EGG_GAS_DEFAULT_SPREAD 3
#define EGG_GAS_KILL_SPREAD 4


//We will round to this value in damage calculations.
#define DAMAGE_PRECISION 0.1

//Autofire component
#define AUTOFIRE_STAT_SLEEPING (1<<0) //Component is in the gun, but the gun is in a different firemode. Sleep until a compatible firemode is activated.
// VV wake_up() VV
// ^^ sleep_up() ^^
#define AUTOFIRE_STAT_IDLE (1<<1) //Compatible firemode is in the gun. Wait until it's held in the user hands.
// VV autofire_on() VV
// ^^ autofire_off() ^^
#define AUTOFIRE_STAT_ALERT	(1<<2) //Gun is active and in the user hands. Wait until user does a valid click.
// VV start_autofiring() VV
// ^^ stop_autofiring() ^^
#define AUTOFIRE_STAT_FIRING (1<<3) //Dakka-dakka-dakka.


//Xeno Overlays Indexes//////////
#define X_LASER_LAYER			9
#define X_WOUND_LAYER			8
#define X_HEAD_LAYER			7
#define X_SUIT_LAYER			6
#define X_L_HAND_LAYER			5
#define X_R_HAND_LAYER			4
#define X_TARGETED_LAYER		3
#define X_FIRE_LAYER			1
#define X_TOTAL_LAYERS			9
/////////////////////////////////
