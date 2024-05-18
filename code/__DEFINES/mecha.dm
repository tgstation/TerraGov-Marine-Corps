#define MECHA_INT_FIRE (1<<0)
#define MECHA_INT_SHORT_CIRCUIT (1<<1)
#define MECHA_INT_CONTROL_LOST (1<<2)

#define LIGHTS_ON (1<<0)
#define HAS_LIGHTS (1<<1)
///Do you need mech skill to pilot this mech
#define MECHA_SKILL_LOCKED (1<<2)
///Is currently suffering from an EMP
#define MECHA_EMPED (1<<3)

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

// Some mechs must (at least for now) use snowflake handling of their UI elements, these defines are for that
// when changing MUST update the same-named tsx file constants
#define MECHA_SNOWFLAKE_ID_MODE "mode_snowflake"
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

///degree of cone in front of which mech is allowed to fire at
#define MECH_FIRE_CONE_ALLOWED 120

///degree of cone in front of which armored vehicles are allowed to fire at
#define ARMORED_FIRE_CONE_ALLOWED 110
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
