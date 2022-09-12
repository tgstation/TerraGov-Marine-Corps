#define MECH_GREY_R_ARM "R_ARM"
#define MECH_GREY_L_ARM "L_ARM"
#define MECH_GREY_LEGS "LEG"
#define MECH_GREY_TORSO "CHEST"
#define MECH_GREY_HEAD "HEAD"

/obj/vehicle/sealed/mecha/combat/greyscale
	name = "Should not be visible"
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	move_delay = 3 // tivi todo
	///keyed list. values are types at init, otherwise instances of mecha limbs, order is layer order as well
	var/list/datum/mech_limb/limbs = list(
		MECH_GREY_TORSO = null,
		MECH_GREY_HEAD = null,
		MECH_GREY_LEGS = null,
		MECH_GREY_R_ARM = null,
		MECH_GREY_L_ARM = null,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/Initialize(mapload)
	. = ..()
	for(var/key in limbs)
		if(!limbs[key])
			continue
		var/new_limb_type = limbs[key]
		limbs[key] = null
		var/datum/mech_limb/limb = new new_limb_type
		limb.attach(src, key)

/obj/vehicle/sealed/mecha/combat/greyscale/update_overlays()
	. = ..()
	for(var/key in limbs) // tivi todo typepath runtime below
		if(!limbs[key])
			continue
		var/datum/mech_limb/limb = limbs[key]
		. += limb.get_overlays()
	var/obj/item/mecha_parts/mecha_equipment/weapon/right_gun = equip_by_category[MECHA_R_ARM]
	var/obj/item/mecha_parts/mecha_equipment/weapon/left_gun = equip_by_category[MECHA_L_ARM]
	if(right_gun)
		. += image(right_gun.icon, right_gun.icon_state)
	if(left_gun)
		. += image(left_gun.icon, left_gun.icon_state)

/obj/vehicle/sealed/mecha/combat/greyscale/test
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/assault,
		MECH_GREY_HEAD = /datum/mech_limb/head/assault,
		MECH_GREY_LEGS = /datum/mech_limb/legs/assault,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/assault,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/assault,
	)
