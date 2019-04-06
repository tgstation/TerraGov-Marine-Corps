/mob/living/carbon/Xenomorph/Boiler
	caste_base_type = /mob/living/carbon/Xenomorph/Boiler
	name = "Boiler"
	desc = "A huge, grotesque xenomorph covered in glowing, oozing acid slime."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Boiler Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 450
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	gib_chance = 100
	drag_delay = 6 //pulling a big dead xeno is hard
	var/obj/item/explosive/grenade/grenade_type = "/obj/item/explosive/grenade/xeno"
	var/datum/effect_system/smoke_spread/xeno/smoke

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/Boiler,
		/datum/action/xeno_action/activable/bombard,
		/datum/action/xeno_action/toggle_long_range,
		/datum/action/xeno_action/toggle_bomb,
		/datum/action/xeno_action/activable/spray_acid/line/boiler
		)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/Xenomorph/Boiler/Initialize()
	. = ..()
	SetLuminosity(BOILER_LUMINOSITY)
	smoke = new /datum/effect_system/smoke_spread/xeno/acid(src)
	see_in_dark = 20
	ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas]

/mob/living/carbon/Xenomorph/Boiler/Destroy()
	SetLuminosity(-BOILER_LUMINOSITY)
	return ..()

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/Xenomorph/Boiler/update_stat()
	. = ..()
	if(stat == CONSCIOUS)
		see_in_dark = 20
