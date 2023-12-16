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
#define GRAB_PASSIVE 0
#define GRAB_AGGRESSIVE 1
#define GRAB_NECK 2
#define GRAB_KILL 3

//TK Grab levels
#define TKGRAB_NONLETHAL 3	//Values should be different as they are identifiers.
#define TKGRAB_LETHAL 4	//Also serves as a measure of how many attempts to resist it.

//intent defines
#define INTENT_HELP "help"
#define INTENT_GRAB "grab"
#define INTENT_DISARM "disarm"
#define INTENT_HARM "harm"
//NOTE: INTENT_HOTKEY_* defines are not actual intents!
//they are here to support hotkeys
#define INTENT_HOTKEY_LEFT "left"
#define INTENT_HOTKEY_RIGHT "right"
//intent magic numbers associations.
#define INTENT_NUMBER_HELP 0
#define INTENT_NUMBER_DISARM 1
#define INTENT_NUMBER_GRAB 2
#define INTENT_NUMBER_HARM 3

//Ammo defines for gun/projectile related things.
//flags_ammo_behavior
#define AMMO_EXPLOSIVE (1<<0) //Ammo will impact a targeted open turf instead of continuing past it
#define AMMO_XENO (1<<1)
#define AMMO_UNWIELDY (1<<2) //poor accuracy against humans
#define AMMO_ENERGY (1<<3) //Ammo will pass through windows and has damage reduced by smokes with SMOKE_NERF_BEAM
#define AMMO_ROCKET (1<<4) //Ammo is more likely to continue past cover such as cades //todo merge AMMO_ROCKET and AMMO_SNIPER
#define AMMO_SNIPER (1<<5) //Ammo is more likely to continue past cover such as cades
#define AMMO_INCENDIARY (1<<6) //Ammo will attempt to add firestacks and ignite a hit mob if it deals any damage. Armor applies, regardless of AMMO_IGNORE_ARMOR
#define AMMO_SKIPS_ALIENS (1<<7)
#define AMMO_IS_SILENCED (1<<8) //Unused right now.
#define AMMO_IGNORE_ARMOR (1<<9) //Projectile direct damage will ignore both hard and soft armor
#define AMMO_IGNORE_RESIST (1<<10) //Unused.
#define AMMO_BALLISTIC (1<<11) //Generates blood splatters on mob hit
#define AMMO_SUNDERING (1<<12) // TODO useless flag just check if sundering != 0
#define AMMO_SPECIAL_PROCESS (1<<13)
#define AMMO_SENTRY (1<<14) //Used to identify ammo from sentry guns and other automated sources
#define AMMO_FLAME (1<<15) //Used to identify flamethrower projectiles and similar projectiles
#define AMMO_IFF (1<<16) //Used to identify ammo that have intrinsec IFF properties
#define AMMO_HITSCAN (1<<17) //If the projectile from this ammo is hitscan
#define AMMO_LEAVE_TURF (1<<18) //If the projectile does something with on_leave_turf()
#define AMMO_PASS_THROUGH_TURF (1<<19) //If the projectile passes through walls causing damage to them
#define AMMO_PASS_THROUGH_MOVABLE (1<<20) //If the projectile passes through mobs and objects causing damage to them
#define AMMO_PASS_THROUGH_MOB (1<<21) //If the projectile passes through mobs only causing damage to them
#define AMMO_SOUND_PITCH (1<<22) //If the projectile ricochet and miss sound is pitched up

//Gun defines for gun related thing. More in the projectile folder.
//flags_gun_features
#define GUN_CAN_POINTBLANK (1<<0)
#define GUN_UNUSUAL_DESIGN (1<<1)
#define GUN_AMMO_COUNTER (1<<2)
#define GUN_WIELDED_FIRING_ONLY (1<<3)
#define GUN_ALLOW_SYNTHETIC (1<<4)
#define GUN_WIELDED_STABLE_FIRING_ONLY (1<<5)
#define GUN_IFF (1<<6)
#define GUN_DEPLOYED_FIRE_ONLY (1<<7)
#define GUN_IS_ATTACHMENT (1<<8)
#define GUN_ATTACHMENT_FIRE_ONLY (1<<9)
#define GUN_ENERGY (1<<10)
#define GUN_AMMO_COUNT_BY_PERCENTAGE (1<<11)
#define GUN_AMMO_COUNT_BY_SHOTS_REMAINING (1<<12)
#define GUN_NO_PITCH_SHIFT_NEAR_EMPTY (1<<13)
#define GUN_SHOWS_AMMO_REMAINING (1<<14) //Whether the mob sprite reflects the ammo level
#define GUN_SHOWS_LOADED (1<<15) //Whether the mob sprite as loaded or unloaded, a binary version of the above
#define GUN_SMOKE_PARTICLES (1<<16) //Whether the gun has smoke particles

//reciever_flags. Used to determin how the gun cycles, what kind of ammo it uses, etc.
#define AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION (1<<0)
	#define AMMO_RECIEVER_UNIQUE_ACTION_LOCKS (1<<1)
#define AMMO_RECIEVER_MAGAZINES (1<<2)
	#define AMMO_RECIEVER_AUTO_EJECT (1<<3)
#define AMMO_RECIEVER_HANDFULS (1<<4)
#define AMMO_RECIEVER_TOGGLES_OPEN (1<<5)
	#define AMMO_RECIEVER_TOGGLES_OPEN_EJECTS (1<<6)
#define AMMO_RECIEVER_CLOSED (1<<7)
#define AMMO_RECIEVER_ROTATES_CHAMBER (1<<8)
#define AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS (1<<9)
#define AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE (1<<10)
#define AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE (1<<11) //The ammo stay in the magazine until the last moment
#define AMMO_RECIEVER_AUTO_EJECT_LOCKED (1<<12) //Not allowed to turn automatic unloading off

#define FLAMER_IS_LIT (1<<0)
#define FLAMER_NO_LIT_OVERLAY (1<<1)
#define FLAMER_USES_GUN_FLAMES (1<<2)

#define FLAMER_STREAM_STRAIGHT "straight"
#define FLAMER_STREAM_CONE "cone"
#define FLAMER_STREAM_RANGED "ranged"

#define GUN_FIREMODE_SEMIAUTO "semi-auto fire mode"
#define GUN_FIREMODE_BURSTFIRE "burst-fire mode"
#define GUN_FIREMODE_AUTOMATIC "automatic fire mode"
#define GUN_FIREMODE_AUTOBURST "auto-burst-fire mode"

//autofire component fire callback callback return flags
#define AUTOFIRE_CONTINUE (1<<0)
#define AUTOFIRE_SUCCESS (1<<1)

//Ammo magazine defines, for flags_magazine
#define MAGAZINE_REFILLABLE (1<<0)
#define MAGAZINE_HANDFUL (1<<1)
#define MAGAZINE_WORN (1<<2)
#define MAGAZINE_REFUND_IN_CHAMBER (1<<3)

//Slowdown from various armors.
#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up

#define SLOWDOWN_ARMOR_VERY_LIGHT 0.20
#define SLOWDOWN_ARMOR_LIGHT 0.3
#define SLOWDOWN_ARMOR_MEDIUM 0.5
#define SLOWDOWN_ARMOR_HEAVY 0.7
#define SLOWDOWN_ARMOR_VERY_HEAVY 1


//=================================================

//Define detpack
#define DETPACK_TIMER_MIN 5
#define DETPACK_TIMER_MAX 300

//Define sniper laser multipliers

#define SNIPER_LASER_DAMAGE_MULTIPLIER 1.5 //+50% damage vs the aimed target

//Define lasrifle
#define ENERGY_STANDARD_AMMO_COST 20
#define ENERGY_OVERCHARGE_AMMO_COST 80
#define ENERGY_OVERCHARGE_FIRE_DELAY 10

//Define stagger damage multipliers
#define STAGGER_DAMAGE_MULTIPLIER 0.5 //-50% damage dealt by the staggered target after all other mods.

//Define smoke effects
#define SMOKE_COUGH (1<<0)
#define SMOKE_GASP (1<<1)
#define SMOKE_OXYLOSS (1<<2)
#define SMOKE_FOUL (1<<3)
#define SMOKE_NERF_BEAM (1<<4)
#define SMOKE_CAMO (1<<5)
#define SMOKE_SLEEP (1<<6)
#define SMOKE_BLISTERING (1<<7)
#define SMOKE_PLASMALOSS (1<<8)
#define SMOKE_XENO (1<<9)
#define SMOKE_XENO_ACID (1<<10)
#define SMOKE_XENO_NEURO (1<<11)
#define SMOKE_XENO_HEMODILE (1<<12)
#define SMOKE_XENO_TRANSVITOX (1<<13)
#define SMOKE_CHEM (1<<14)
#define SMOKE_EXTINGUISH (1<<15) //Extinguishes fires and mobs that are on fire
#define SMOKE_NEURO_LIGHT (1<<16) //Effectively a sub-flag of Neuro; precludes higher impact effects
#define SMOKE_HUGGER_PACIFY (1<<17) //Smoke that pacifies huggers in its area; mainly used for vision blocking smoke
#define SMOKE_XENO_SANGUINAL (1<<18) //Toxic crimson smoke created by the Defiler's Defile ability.
#define SMOKE_XENO_OZELOMELYN (1<<19) //Smoke that purges chemicals and does minor capped toxin damage for Defiler.
#define SMOKE_SATRAPINE (1<<20) //nerve agent that purges painkillers and causes increasing pain
#define SMOKE_XENO_TOXIC (1<<21) //deals damage to anyone inside it and inflicts the intoxicated debuff, dealing damage over time

//Incapacitated
#define INCAPACITATED_IGNORE_RESTRAINED (1<<0)
#define INCAPACITATED_IGNORE_GRAB (1<<1)


//Restraints
#define RESTRAINED_XENO_NEST (1<<0)
#define RESTRAINED_NECKGRAB (1<<1)
#define RESTRAINED_STRAIGHTJACKET (1<<2)
#define RESTRAINED_RAZORWIRE (1<<3)
#define RESTRAINED_PSYCHICGRAB (1<<4)

#define SINGLE_CASING (1 << 0)
#define SPEEDLOADER (1 << 1)
#define MAGAZINE (1 << 2)
#define CELL (1 << 3)
#define POWERPACK (1 << 4)

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

#define MAX_PARALYSE_AMOUNT_FOR_PARALYSE_RESISTANT 2 SECONDS

//Xeno Overlays Indexes//////////
#define X_LASER_LAYER 9
#define X_WOUND_LAYER 8
#define X_HEAD_LAYER 7
#define X_SUIT_LAYER 6
#define X_L_HAND_LAYER 5
#define X_R_HAND_LAYER 4
#define X_TARGETED_LAYER 3
#define X_FIRE_LAYER 1
#define X_TOTAL_LAYERS 9
/////////////////////////////////

//Cave comms defines
#define CAVE_NO_INTERFERENCE 0 //! No impact on comms.
#define CAVE_MINOR_INTERFERENCE 1 //! Scrambles outgoing messages, no impact on incoming.
#define CAVE_FULL_INTERFERENCE 2 //! Prevents incoming and outgoing messages.

#define ANTENNA_SYNCING_TIME 30 SECONDS //! Time needed to initially configure an antenna module after equipping.
