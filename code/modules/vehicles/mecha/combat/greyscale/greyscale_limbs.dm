
GLOBAL_LIST_INIT(mech_bodytypes, list(MECH_RECON, MECH_ASSAULT, MECH_VANGUARD))

/datum/mech_limb
	///when attached the mechs health is modified by this amount
	var/health_mod = 0
	///when attached the mechs armor is modified by this amount
	var/list/soft_armor_mod = list(MELEE = 5, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 0, FIRE = 20, ACID = 5)
	///when attached the mechs slowdown is modified by this amount
	var/slowdown_mod = 0
	///typepath for greyscale icon generation
	var/greyscale_type = /datum/greyscale_config
	/// 2 or 3 entry list of primary, secondary, visor color to use
	var/list/colors = list(MECH_GREY_PRIMARY_DEFAULT, MECH_GREY_SECONDARY_DEFAULT, MECH_GREY_VISOR_DEFAULT)
	///overlay icon to generate
	var/icon/overlay_icon

/datum/mech_limb/New(noload)
	..()
	if(noload)
		return
	update_colors(arglist(colors))


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
	if(istype(attached.limbs[slot], /datum/mech_limb))
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



///MECH HEAD
/datum/mech_limb/head
	health_mod = 200
	/// greyscale config datum for the visor
	var/visor_config
	///amount accuracy is modified by
	var/accuracy_mod
	///generated visor icon for us to use when updating icon
	var/icon/visor_icon
	///light range we set on the mech
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
	health_mod = 250
	accuracy_mod = 1.3
	slowdown_mod = 0.2
	light_range = 7
	greyscale_type = /datum/greyscale_config/mech_recon/head
	visor_config = /datum/greyscale_config/mech_recon/visor

/datum/mech_limb/head/assault
	health_mod = 400
	accuracy_mod = 1.4
	slowdown_mod = 0.3
	light_range = 6
	greyscale_type = /datum/greyscale_config/mech_assault/head
	visor_config = /datum/greyscale_config/mech_assault/visor

/datum/mech_limb/head/vanguard
	health_mod = 600
	accuracy_mod = 1.5
	slowdown_mod = 0.4
	light_range = 5
	greyscale_type = /datum/greyscale_config/mech_vanguard/head
	visor_config = /datum/greyscale_config/mech_vanguard/visor


/datum/mech_limb/torso
	health_mod = 600
	/// cell typepath to place into the mech when this torso is attached
	var/cell_type = /obj/item/cell/mecha

/datum/mech_limb/torso/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	. = ..()
	attached.add_cell(new cell_type)

/datum/mech_limb/torso/detach(obj/vehicle/sealed/mecha/combat/greyscale/detached)
	. = ..()
	detached.add_cell() //replaces with a standard high cap that does not have built in recharge

/datum/mech_limb/torso/recon
	health_mod = 250
	slowdown_mod = 0.4
	cell_type = /obj/item/cell/mecha
	greyscale_type = /datum/greyscale_config/mech_recon/torso

/datum/mech_limb/torso/assault
	health_mod = 400
	slowdown_mod = 0.7
	cell_type = /obj/item/cell/mecha/medium
	greyscale_type = /datum/greyscale_config/mech_assault/torso

/datum/mech_limb/torso/vanguard
	health_mod = 600
	slowdown_mod = 1.0
	cell_type = /obj/item/cell/mecha/large
	greyscale_type = /datum/greyscale_config/mech_vanguard/torso


//MECH ARMS
/datum/mech_limb/arm
	health_mod = 200
	/// Amount scatter is modified by when this arm shoots
	var/scatter_mod = 0
	///which slot this arm is equipped to when it is attached
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
	health_mod = 250
	scatter_mod = -10
	slowdown_mod = 0.2
	greyscale_type = /datum/greyscale_config/mech_recon/arms

/datum/mech_limb/arm/assault
	health_mod = 400
	scatter_mod = -17
	slowdown_mod = 0.3
	greyscale_type = /datum/greyscale_config/mech_assault/arms

/datum/mech_limb/arm/vanguard
	health_mod = 600
	scatter_mod = -25
	slowdown_mod = 0.4
	greyscale_type = /datum/greyscale_config/mech_vanguard/arms


//MECH LEGS
/datum/mech_limb/legs
	health_mod = 300

/datum/mech_limb/legs/recon
	health_mod = 300
	slowdown_mod = -0.7
	greyscale_type = /datum/greyscale_config/mech_recon/legs

/datum/mech_limb/legs/assault
	health_mod = 600
	slowdown_mod = -0.3
	greyscale_type = /datum/greyscale_config/mech_assault/legs

/datum/mech_limb/legs/vanguard
	health_mod = 800
	slowdown_mod = 0.1
	greyscale_type = /datum/greyscale_config/mech_vanguard/legs
