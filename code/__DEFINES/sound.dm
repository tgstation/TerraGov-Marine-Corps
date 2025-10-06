//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_NOTIFY 1022 // observer, new player, vote notifications
#define CHANNEL_VOX 1021 //vox announcements from AI
#define CHANNEL_ANNOUNCEMENTS 1020 // IC priority announcements, hivemind messages etc
#define CHANNEL_CINEMATIC 1019
#define CHANNEL_ADMIN 1018
#define CHANNEL_MIDI 1017
#define CHANNEL_AMBIENCE 1016
#define CHANNEL_ELEVATOR 1015

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED
#define CHANNEL_HIGHEST_AVAILABLE 1014

#define MAX_INSTRUMENT_CHANNELS (128 * 6)

/// This is the lowest volume that can be used by playsound otherwise it gets ignored
/// Most sounds around 10 volume can barely be heard. Almost all sounds at 5 volume or below are inaudible
/// This is to prevent sound being spammed at really low volumes due to distance calculations
/// Recommend setting this to anywhere from 10-3 (or 0 to disable any sound minimum volume restrictions)
/// Ex. For a 70 volume sound, 17 tile range, 3 exponent, 2 falloff_distance:
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 0 for the above will result in 17x17 radius (289 turfs)
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 5 for the above will result in 14x14 radius (196 turfs)
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 10 for the above will result in 11x11 radius (121 turfs)
#define SOUND_AUDIBLE_VOLUME_MIN 3

///Default range of a sound.
#define SOUND_RANGE 17
#define MEDIUM_RANGE_SOUND_EXTRARANGE -5
///default extra range for sounds considered to be quieter
#define SHORT_RANGE_SOUND_EXTRARANGE -9
///The range deducted from sound range for things that are considered silent / sneaky
#define SILENCED_SOUND_EXTRARANGE -11
///Percentage of sound's range where no falloff is applied
#define SOUND_DEFAULT_FALLOFF_DISTANCE 1 //For a normal sound this would be 1 tile of no falloff
///The default exponent of sound falloff
#define SOUND_FALLOFF_EXPONENT 6

#define FALLOFF_SOUNDS 1

#define GUN_FIRE_SOUND_VOLUME 50

///Frequency stuff only works with 45kbps oggs.
#define GET_RAND_FREQUENCY (rand(32000, 55000))

//default byond sound environments
#define SOUND_ENVIRONMENT_NONE -1
#define SOUND_ENVIRONMENT_GENERIC 0
#define SOUND_ENVIRONMENT_PADDED_CELL 1
#define SOUND_ENVIRONMENT_ROOM 2
#define SOUND_ENVIRONMENT_BATHROOM 3
#define SOUND_ENVIRONMENT_LIVINGROOM 4
#define SOUND_ENVIRONMENT_STONEROOM 5
#define SOUND_ENVIRONMENT_AUDITORIUM 6
#define SOUND_ENVIRONMENT_CONCERT_HALL 7
#define SOUND_ENVIRONMENT_CAVE 8
#define SOUND_ENVIRONMENT_ARENA 9
#define SOUND_ENVIRONMENT_HANGAR 10
#define SOUND_ENVIRONMENT_CARPETED_HALLWAY 11
#define SOUND_ENVIRONMENT_HALLWAY 12
#define SOUND_ENVIRONMENT_STONE_CORRIDOR 13
#define SOUND_ENVIRONMENT_ALLEY 14
#define SOUND_ENVIRONMENT_FOREST 15
#define SOUND_ENVIRONMENT_CITY 16
#define SOUND_ENVIRONMENT_MOUNTAINS 17
#define SOUND_ENVIRONMENT_QUARRY 18
#define SOUND_ENVIRONMENT_PLAIN 19
#define SOUND_ENVIRONMENT_PARKING_LOT 20
#define SOUND_ENVIRONMENT_SEWER_PIPE 21
#define SOUND_ENVIRONMENT_UNDERWATER 22
#define SOUND_ENVIRONMENT_DRUGGED 23
#define SOUND_ENVIRONMENT_DIZZY 24
#define SOUND_ENVIRONMENT_PSYCHOTIC 25

/// List of all of our sound keys.
#define SFX_SHATTER "shatter"
#define SFX_EXPLOSION_LARGE "explosion_large"
#define SFX_EXPLOSION_MICRO "explosion_micro"
#define SFX_EXPLOSION_SMALL "explosion_small"
#define SFX_EXPLOSION_MED "explosion_med"
#define SFX_EXPLOSION_SMALL_DISTANT "explosion_small_distant"
#define SFX_EXPLOSION_LARGE_DISTANT "explosion_large_distant"
#define SFX_EXPLOSION_CREAK "explosion_creak"
#define SFX_SPARKS "sparks"
#define SFX_RUSTLE "rustle"
#define SFX_PUNCH "punch"
#define SFX_CLOWNSTEP "clownstep"
#define SFX_SWING_HIT "swing_hit"
#define SFX_PAGE_TURN "pageturn"
#define SFX_GASBREATH "gasbreath"
#define SFX_TERMINAL_TYPE "terminal_type"
#define SFX_VENDING "vending"
#define SFX_INCENDIARY_EXPLOSION "incendiary_explosion"
#define SFX_MOLOTOV "molotov"
#define SFX_FLASHBANG "flashbang"
#define SFX_BALLISTIC_HIT "ballistic_hit"
#define SFX_BALLISTIC_HITMARKER "ballistic hitmarker"
#define SFX_BALLISTIC_ARMOR "ballistic_armor"
#define SFX_BALLISTIC_MISS "ballistic_miss"
#define SFX_BALLISTIC_BOUNCE "ballistic_bounce"
#define SFX_ROCKET_BOUNCE "rocket_bounce"
#define SFX_ENERGY_HIT "energy_hit"
#define SFX_ALLOY_HIT "alloy_hit"
#define SFX_ALLOY_ARMOR "alloy_armor"
#define SFX_ALLOY_BOUNCE "alloy_bounce"
#define SFX_GUN_SILENCED "gun_silenced"
#define SFX_GUN_SMARTGUN "gun_smartgun"
#define SFX_GUN_SMARTGPMG "gun_smartgun_gpmg"
#define SFX_GUN_FLAMETHROWER "gun_flamethrower"
#define SFX_GUN_AR12 "gun_ar12"
#define SFX_GUN_FB12 "gun_fb12"
#define SFX_SHOTGUN_SOM "shotgun_som"
#define SFX_GUN_PULSE "gun_pulse"
#define SFX_RPG_FIRE "rpg_fire"
#define SFX_AC_FIRE "ac_fire"
#define SFX_SVD_FIRE "svd_fire"
#define SFX_FAL_FIRE "fal_fire"
#define SFX_MP38_FIRE "mp38_fire"
#define SFX_SLAM "slam"
#define SFX_ACID_HIT "acid_hit"
#define SFX_ACID_BOUNCE "acid_bounce"
#define SFX_ALIEN_CLAW_FLESH "alien_claw_flesh"
#define SFX_ALIEN_CLAW_METAL "alien_claw_metal"
#define SFX_ALIEN_BITE "alien_bite"
#define SFX_ALIEN_TAIL_ATTACK "alien_tail_attack"
#define SFX_ALIEN_FOOTSTEP_LARGE "alien_footstep_large"
#define SFX_ALIEN_CHARGE "alien_charge"
#define SFX_ALIEN_RESIN_BUILD "alien_resin_build"
#define SFX_ALIEN_RESIN_BREAK "alien_resin_break"
#define SFX_ALIEN_RESIN_MOVE "alien_resin_move"
#define SFX_ALIEN_TALK "alien_talk"
#define SFX_ALIEN_GROWL "alien_growl"
#define SFX_ALIEN_HISS "alien_hiss"
#define SFX_ALIEN_TAIL_SWIPE "alien_tail_swipe"
#define SFX_ALIEN_HELP "alien_help"
#define SFX_ALIEN_DROOL "alien_drool"
#define SFX_ALIEN_ROAR "alien_roar"
#define SFX_ALIEN_ROAR_LARVA "alien_roar_larva"
#define SFX_QUEEN "queen"
#define SFX_ALIEN_VENTPASS "alien_ventpass"
#define SFX_BEHEMOTH_STEP_SOUNDS "behemoth_step_sounds"
#define SFX_BEHEMOTH_ROLLING "behemoth_rolling"
#define SFX_BEHEMOTH_EARTH_PILLAR_HIT "behemoth_earth_pillar_hit"
#define SFX_CONQUEROR_WILL_HOOK "conqueror_will_hook"
#define SFX_CONQUEROR_WILL_EXTRA "conqueror_will_extra"
#define SFX_MALE_SCREAM "male_scream"
#define SFX_MALE_PAIN "male_pain"
#define SFX_MALE_GORED "male_gored"
#define SFX_MALE_FRAGOUT "male_fragout"
#define SFX_MALE_WARCRY "male_warcry"
#define SFX_FEMALE_SCREAM "female_scream"
#define SFX_FEMALE_PAIN "female_pain"
#define SFX_FEMALE_GORED "female_gored"
#define SFX_FEMALE_FRAGOUT "female_fragout"
#define SFX_FEMALE_WARCRY "female_warcry"
#define SFX_MALE_HUGGED "male_hugged"
#define SFX_FEMALE_HUGGED "female_hugged"
#define SFX_MALE_GASP "male_gasp"
#define SFX_FEMALE_GASP "female_gasp"
#define SFX_MALE_COUGH "male_cough"
#define SFX_FEMALE_COUGH "female_cough"
#define SFX_MALE_PREBURST "male_preburst"
#define SFX_FEMALE_PREBURST "female_preburst"
#define SFX_JUMP "jump"
#define SFX_ROBOT_SCREAM "robot_scream"
#define SFX_ROBOT_PAIN "robot_pain"
#define SFX_ROBOT_WARCRY "robot_warcry"
