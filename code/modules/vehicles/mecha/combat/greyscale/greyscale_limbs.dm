
GLOBAL_LIST_INIT(mech_bodytypes, list(MECH_RECON, MECH_ASSAULT, MECH_VANGUARD))

/datum/mech_limb
	///category that this limb will be displayed in
	var/category = "NONE" // tivi todo del
	///when attached the mechs health is modified by this amount
	var/health_mod = 0
	///when attached the mechs armor is modified by this amount
	var/list/soft_armor_mod = list(MELEE = 20, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 100, ACID = 100)
	///when attached the mechs slowdown is modified by this amount
	var/slowdown_mod = 0
	///typepath for greyscale icon generation
	var/greyscale_type = /datum/greyscale_config
	/// 2 or 3 entry list of primary, secondary, visor color to use
	var/list/colors = list(MECH_GREY_PRIMARY_DEFAULT, MECH_GREY_SECONDARY_DEFAULT, MECH_GREY_VISOR_DEFAULT)
	///overlay icon to generate
	var/icon/overlay_icon

/datum/mech_limb/New()
	..()
	update_colors(arglist(colors)) // tivi todo


/datum/mech_limb/proc/update_colors(color_one, color_two, ...)
	if(!color_one && !color_two)
		CRASH("update_colors did not recieve any colors")
	var/list/colors_to_set = list()
	if(color_one && !color_two)
		colors_to_set += color_one
		colors_to_set += colors[2]
	else if(!color_one && color_two)
		colors_to_set += colors[1]
		colors_to_set += color_two
	else
		colors_to_set = list(color_one, color_two)
	colors = colors_to_set
	var/list/splitcolors = list()
	for(var/color in colors_to_set)
		splitcolors += color
	overlay_icon = SSgreyscale.GetColoredIconByType(greyscale_type, splitcolors)

/**
 * proc to call to add this limb to the mech object
 * Args:
 * * attached: mech we are attaching to
 * * slot: slot we are being attached to mostly relevant for r/l arm
 */
/datum/mech_limb/proc/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	SHOULD_CALL_PARENT(TRUE)
	if(!slot)
		CRASH("attaching with no slot")
	if(istype(attached.limbs[slot], /datum/mech_limb)) // tivi todo exact type
		attached.limbs[slot].detach(attached)
	attached.limbs[slot] = src
	attached.max_integrity += health_mod
	attached.obj_integrity += health_mod
	attached.move_delay += slowdown_mod

	attached.soft_armor = attached.soft_armor.modifyRating(arglist(soft_armor_mod))
	attached.update_icon()

/**
 * proc to call to remove this limb to the mech object
 * Args:
 * * attached: mech we are attaching to
 */
/datum/mech_limb/proc/detach(obj/vehicle/sealed/mecha/combat/greyscale/detached)
	SHOULD_CALL_PARENT(TRUE)
	for(var/slot in detached.limbs)
		if(detached.limbs[slot] != src)
			continue
		detached.limbs[slot] = null
	detached.max_integrity -= health_mod
	detached.obj_integrity -= health_mod
	detached.move_delay -= slowdown_mod

	var/list/removed_armor = soft_armor_mod.Copy()
	for(var/armor_type in removed_armor)
		removed_armor[armor_type] = -removed_armor[armor_type]
	detached.soft_armor = detached.soft_armor.modifyRating(arglist(removed_armor))
	detached.update_icon()

/// Returns an overlay or list of overlays to use on the mech
/datum/mech_limb/proc/get_overlays()
	return icon2appearance(overlay_icon)

/datum/mech_limb/arm
	health_mod = 200
	var/scatter_mod = 0
	var/arm_slot

/datum/mech_limb/arm/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	arm_slot = slot
	return ..()

/datum/mech_limb/arm/detach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	arm_slot = null
	return ..()

/datum/mech_limb/arm/get_overlays()
	if(arm_slot == MECH_GREY_R_ARM)
		return image(overlay_icon, icon_state = "right")
	return image(overlay_icon, icon_state = "left")

/datum/mech_limb/arm/recon
	greyscale_type = /datum/greyscale_config/mech_recon/arms

/datum/mech_limb/arm/assault
	greyscale_type = /datum/greyscale_config/mech_assault/arms

/datum/mech_limb/arm/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/arms

/datum/mech_limb/legs
	health_mod = 300

/datum/mech_limb/legs/recon
	greyscale_type = /datum/greyscale_config/mech_recon/legs

/datum/mech_limb/legs/assault
	greyscale_type = /datum/greyscale_config/mech_assault/legs

/datum/mech_limb/legs/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/legs

/datum/mech_limb/head
	health_mod = 200
	var/visor_config
	var/accuracy_mod
	var/icon/visor_icon
	var/light_range = 5

/datum/mech_limb/head/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	. = ..()
	attached.set_light_range(light_range)

/datum/mech_limb/head/detach(obj/vehicle/sealed/mecha/combat/greyscale/detached)
	. = ..()
	detached.set_light_range(initial(detached.light_range))

/datum/mech_limb/head/update_colors(color_one, color_two, visor_color)
	. = ..()
	visor_icon = SSgreyscale.GetColoredIconByType(visor_config, visor_color)

/datum/mech_limb/head/get_overlays()
	return list(icon2appearance(overlay_icon), icon2appearance(visor_icon), emissive_appearance(visor_icon))

/datum/mech_limb/head/recon
	greyscale_type = /datum/greyscale_config/mech_recon/head
	visor_config = /datum/greyscale_config/mech_recon/visor

/datum/mech_limb/head/assault
	greyscale_type = /datum/greyscale_config/mech_assault/head
	visor_config = /datum/greyscale_config/mech_assault/visor

/datum/mech_limb/head/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/head
	visor_config = /datum/greyscale_config/mech_vanguard/visor

/datum/mech_limb/torso
	health_mod = 600

/datum/mech_limb/torso/recon
	greyscale_type = /datum/greyscale_config/mech_recon/torso

/datum/mech_limb/torso/assault
	greyscale_type = /datum/greyscale_config/mech_assault/torso

/datum/mech_limb/torso/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/torso
