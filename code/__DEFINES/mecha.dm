#define MECHA_INT_FIRE (1<<0)
#define MECHA_INT_TEMP_CONTROL (1<<1)
#define MECHA_INT_SHORT_CIRCUIT (1<<2)
#define MECHA_INT_TANK_BREACH (1<<3)
#define MECHA_INT_CONTROL_LOST (1<<4)

#define ADDING_ACCESS_POSSIBLE (1<<0)
#define ADDING_MAINT_ACCESS_POSSIBLE (1<<1)
#define CANSTRAFE (1<<2)
#define LIGHTS_ON (1<<3)
#define SILICON_PILOT (1<<4)
#define IS_ENCLOSED (1<<5)
#define HAS_LIGHTS (1<<6)
#define QUIET_STEPS (1<<7)
#define QUIET_TURNS (1<<8)
///blocks using equipment and melee attacking.
#define CANNOT_INTERACT (1<<9)
/// Can click from any direction and perform stuff
#define OMNIDIRECTIONAL_ATTACKS (1<<10)
///Do you need mech skill to pilot this mech
#define MECHA_SKILL_LOCKED (1<<11)

#define MECHA_MELEE (1 << 0)
#define MECHA_RANGED (1 << 1)

#define MECHA_FRONT_ARMOUR "mechafront"
#define MECHA_SIDE_ARMOUR "mechaside"
#define MECHA_BACK_ARMOUR "mechaback"

#define MECHA_WEAPON "mecha_weapon" //l and r arm weapon type
#define MECHA_L_ARM "mecha_l_arm"
#define MECHA_R_ARM "mecha_r_arm"
#define MECHA_UTILITY "mecha_utility"
#define MECHA_POWER "mecha_power"
#define MECHA_ARMOR "mecha_armor"

#define MECHA_LOCKED 0
#define MECHA_SECURE_BOLTS 1
#define MECHA_LOOSE_BOLTS 2
#define MECHA_OPEN_HATCH 3

// Some mechs must (at least for now) use snowflake handling of their UI elements, these defines are for that
// when changing MUST update the same-named tsx file constants
#define MECHA_SNOWFLAKE_ID_SLEEPER "sleeper_snowflake"
#define MECHA_SNOWFLAKE_ID_SYRINGE "syringe_snowflake"
#define MECHA_SNOWFLAKE_ID_MODE "mode_snowflake"
#define MECHA_SNOWFLAKE_ID_EXTINGUISHER "extinguisher_snowflake"
#define MECHA_SNOWFLAKE_ID_EJECTOR "ejector_snowflake"

#define MECHA_AMMO_INCENDIARY "Incendiary bullet"
#define MECHA_AMMO_BUCKSHOT "Buckshot shell"
#define MECHA_AMMO_LMG "LMG bullet"
#define MECHA_AMMO_MISSILE_HE "HE missile"
#define MECHA_AMMO_MISSILE_AP "AP missile"
#define MECHA_AMMO_FLASHBANG "Flashbang"
#define MECHA_AMMO_CLUSTERBANG "Clusterbang"

#define MECHA_AMMO_GREY_LMG "30mm LMG bullet"
#define MECHA_AMMO_RIFLE "Rocket-assisted rifle bullet"
#define MECHA_AMMO_BURSTRIFLE "Rocket-assisted burst bullet"
#define MECHA_AMMO_SHOTGUN "Large buckshot shell"
#define MECHA_AMMO_LIGHTCANNON "Autocannon shrapnel shell"
#define MECHA_AMMO_HEAVYCANNON "APFSDS tank shell"
#define MECHA_AMMO_SMG "Large SMG bullet"
#define MECHA_AMMO_BURSTPISTOL "Heavy burstpistol bullet"
#define MECHA_AMMO_PISTOL "Heavy pistol bullet"
#define MECHA_AMMO_RPG "High explosive missile"
#define MECHA_AMMO_MINIGUN "Vulcan bullet"
#define MECHA_AMMO_SNIPER "Anti-tank bullet"
#define MECHA_AMMO_GRENADE "Frag grenade"
#define MECHA_AMMO_FLAMER "Napalm"

/// Module is compatible with Ripley Exosuit models
#define EXOSUIT_MODULE_RIPLEY (1<<0)
/// Module is compatible with Odyseeus Exosuit models
#define EXOSUIT_MODULE_ODYSSEUS (1<<1)
/// Module is compatible with Gygax Exosuit models
#define EXOSUIT_MODULE_GYGAX (1<<2)
/// Module is compatible with Durand Exosuit models
#define EXOSUIT_MODULE_DURAND (1<<3)
/// Module is compatible with H.O.N.K Exosuit models
#define EXOSUIT_MODULE_HONK (1<<4)
/// Module is compatible with Phazon Exosuit models
#define EXOSUIT_MODULE_PHAZON (1<<5)
/// Module is compatible with Savannah Exosuit models
#define EXOSUIT_MODULE_SAVANNAH (1<<6)
/// Module is compatible with Greyscale Exosuit models
#define EXOSUIT_MODULE_GREYSCALE (1<<7)

/// Module is compatible with "Working" Exosuit models - Ripley and Clarke
#define EXOSUIT_MODULE_WORKING EXOSUIT_MODULE_RIPLEY
/// Module is compatible with "Combat" Exosuit models - Gygax, H.O.N.K, Durand and Phazon
#define EXOSUIT_MODULE_COMBAT EXOSUIT_MODULE_GYGAX | EXOSUIT_MODULE_HONK | EXOSUIT_MODULE_DURAND | EXOSUIT_MODULE_PHAZON | EXOSUIT_MODULE_SAVANNAH
/// Module is compatible with "Medical" Exosuit modelsm - Odysseus
#define EXOSUIT_MODULE_MEDICAL EXOSUIT_MODULE_ODYSSEUS

///degree of cone in front of which mech is allowed to fire at
#define MECH_FIRE_CONE_ALLOWED 120

/**
 * greyscale mech shenanigans
 */
#define MECH_VANGUARD "Vanguard"
#define MECH_RECON "Recon"
#define MECH_ASSAULT "Assault"

#define MECH_GREY_R_ARM "R_ARM"
#define MECH_GREY_L_ARM "L_ARM"
#define MECH_GREY_LEGS "LEG"
#define MECH_GREY_TORSO "CHEST"
#define MECH_GREY_HEAD "HEAD"

//Defaults for mech palettes and the palette shown in the UI
#define MECH_GREY_PRIMARY_DEFAULT ARMOR_PALETTE_DRAB
#define MECH_GREY_SECONDARY_DEFAULT ARMOR_PALETTE_BLACK
#define MECH_GREY_VISOR_DEFAULT VISOR_PALETTE_GOLD

#define MECH_GREYSCALE_MAX_EQUIP list(\
		MECHA_UTILITY = 1,\
		MECHA_POWER = 1,\
		MECHA_ARMOR = 1,\
	)
