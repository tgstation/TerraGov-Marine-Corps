/obj/vehicle/sealed/mecha/combat/greyscale
	name = "Should not be visible"
	icon_state = "greyscale"
	layer = ABOVE_ALL_MOB_LAYER
	mech_type = EXOSUIT_MODULE_GREYSCALE
	pixel_x = -16
	move_delay = 3 // tivi todo: polish, mechs too fast
	/// keyed list. values are types at init, otherwise instances of mecha limbs, order is layer order as well
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
	// TIVI TODO HELLO ADMINS
	if(length(GLOB.clients) > 1)
		message_admins("Stop trying to spawn mechs before they're ready")
		return INITIALIZE_HINT_QDEL

/obj/vehicle/sealed/mecha/combat/greyscale/update_overlays()
	. = ..()
	for(var/key in limbs)
		if(!istype(limbs[key], /datum/mech_limb))
			continue
		var/datum/mech_limb/limb = limbs[key]
		. += limb.get_overlays()
	var/obj/item/mecha_parts/mecha_equipment/weapon/right_gun = equip_by_category[MECHA_R_ARM]
	var/obj/item/mecha_parts/mecha_equipment/weapon/left_gun = equip_by_category[MECHA_L_ARM]
	if(right_gun)
		. += image(right_gun.icon, right_gun.icon_state) // tivi todo weapons can just use appearance?
	if(left_gun)
		. += image(left_gun.icon, left_gun.icon_state)

/obj/vehicle/sealed/mecha/combat/greyscale/recon
	name = "Recon Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/recon,
		MECH_GREY_HEAD = /datum/mech_limb/head/recon,
		MECH_GREY_LEGS = /datum/mech_limb/legs/recon,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/recon,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/recon,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/assault
	name = "Assault Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/assault,
		MECH_GREY_HEAD = /datum/mech_limb/head/assault,
		MECH_GREY_LEGS = /datum/mech_limb/legs/assault,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/assault,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/assault,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/vanguard
	name = "Vanguard Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/vanguard,
		MECH_GREY_HEAD = /datum/mech_limb/head/vanguard,
		MECH_GREY_LEGS = /datum/mech_limb/legs/vanguard,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/vanguard,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/vanguard,
	)
