/datum/mech_limb
	/// Reference to the mech we are attached too. Remember, this will clean us up ind estroy already
	var/obj/vehicle/sealed/mecha/combat/greyscale/owner
	/// The name for this limb to display when examined
	var/display_name = "CODE ERROR OOPSIE"
	/// If set, instead of relaying damage to the owning mech will instead relay damage to this limb and will call [/proc/on_disable]
	var/part_health = 0
	/// for part_health, if the targetted zone is in this list will make this limb take damage
	var/list/def_zones
	///whether this has taken full damage and become disabled
	var/disabled = FALSE
	///when attached the mechs armor is modified by this amount
	var/list/soft_armor_mod = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	///when attached the mechs slowdown is modified by this amount
	var/slowdown_mod = 0
	///typepath for greyscale icon generation
	var/datum/greyscale_config/greyscale_type = /datum/greyscale_config
	/// icon state name for the part we are using
	var/icon_state = ""
	///whether the icon file for the greyscale config ALSO includes some damage overlays
	var/has_damage_overlays = FALSE
	///whether the greyscale config supports boosting sprites
	var/has_boosting_state = FALSE
	///whether the greyscale config supports destroyed sprites
	var/has_destroyed_iconstate = FALSE
	/// 2 or 3 entry list of primary, secondary, visor color to use
	var/list/colors = list(MECH_GREY_PRIMARY_DEFAULT, MECH_GREY_SECONDARY_DEFAULT, MECH_GREY_VISOR_DEFAULT)
	///overlay icon to generate
	var/icon/overlay_icon
	///The weight that we contribute to the max limit, if this is equipped to a greyscale mech
	var/weight = 10

/datum/mech_limb/New(noload)
	..()
	if(noload)
		return
	update_colors(arglist(colors))

/datum/mech_limb/Destroy(force, ...)
	owner = null
	return ..()

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
	owner = attached
	attached.move_delay += slowdown_mod

	attached.soft_armor = attached.soft_armor.modifyRating(arglist(soft_armor_mod))
	attached.update_icon(UPDATE_OVERLAYS)
	if(part_health)
		RegisterSignal(attached, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(intercept_damage))
		RegisterSignal(attached, COMSIG_ATOM_REPAIR_DAMAGE, PROC_REF(intercept_repair))
	attached.weight += weight // ignores any checks. we assume that you handle those elsewhere like ui or equipment checks

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
	detached.weight -= weight
	UnregisterSignal(owner, list(COMSIG_ATOM_TAKE_DAMAGE, COMSIG_ATOM_REPAIR_DAMAGE))
	owner = null
	detached.move_delay -= slowdown_mod

	var/list/removed_armor = soft_armor_mod.Copy()
	for(var/armor_type in removed_armor)
		removed_armor[armor_type] = -removed_armor[armor_type]
	detached.soft_armor = detached.soft_armor.modifyRating(arglist(removed_armor))
	if(!QDELING(detached))
		detached.update_icon(UPDATE_OVERLAYS)

/// Returns an overlay or list of overlays to use on the mech
/datum/mech_limb/proc/get_overlays()
	if(disabled && !has_destroyed_iconstate)
		return
	. = list()
	var/prefix = ""
	if(owner.is_wreck)
		prefix = "d_"
	else if (owner.leg_overload_mode && has_boosting_state)
		prefix = "b_"

	. += iconstate2appearance(overlay_icon, prefix+icon_state)
	if(has_damage_overlays)
		var/percent
		if(initial(part_health))
			percent = (part_health / initial(part_health))
		else
			percent = owner.obj_integrity / owner.max_integrity
		if(percent > 0.75)
			return
		var/dmg_percent = max(CEILING(percent, 0.25)*100, 25)
		. += iconstate2appearance(greyscale_type::icon_file, prefix+icon_state+"[dmg_percent]")

///intercepts damage intended for the mech and applies it to this limb when needed
/datum/mech_limb/proc/intercept_damage(datum/source, damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	SIGNAL_HANDLER
	if(!(blame_mob?.zone_selected in def_zones))
		return NONE
	if(take_damage(damage_amount))
		return COMPONENT_NO_TAKE_DAMAGE
	return NONE

///handles actually dealing damage to the mech
/datum/mech_limb/proc/take_damage(damage_amount)
	if(part_health <= 0)
		return FALSE
	part_health = max(0, part_health-damage_amount)
	owner.update_appearance(UPDATE_OVERLAYS)
	if(part_health <= 0)
		disable()
	return TRUE

///intercepts repair intended for the mech and applies it to this limb when needed
/datum/mech_limb/proc/intercept_repair(datum/source, repair_amount, mob/user)
	SIGNAL_HANDLER
	if(!user)
		return NONE
	if(!(user.zone_selected in def_zones))
		return NONE
	do_repairs(repair_amount)
	return COMPONENT_NO_REPAIR

///does the actual repair of this limb
/datum/mech_limb/proc/do_repairs(repair_amount)
	part_health = min(initial(part_health), part_health+repair_amount)
	owner.update_appearance(UPDATE_OVERLAYS)
	if(part_health >= initial(part_health))
		reenable()

///makes this limb "destroyed"
/datum/mech_limb/proc/disable()
	if(disabled)
		return FALSE
	disabled = TRUE
	owner.update_appearance(UPDATE_OVERLAYS)
	playsound(owner, 'sound/mecha/internaldmgalarm.ogg', 80, TRUE, falloff = 10)
	return TRUE

///makes this limb un-"destroyed"
/datum/mech_limb/proc/reenable()
	if(!disabled)
		return
	disabled = FALSE
	owner.update_icon(UPDATE_OVERLAYS)
	return TRUE


///MECH HEAD
/datum/mech_limb/head
	display_name = "Head"
	icon_state = "head"
	part_health = 200
	def_zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH)
	weight = 35
	/// greyscale config datum for the visor
	var/visor_config
	///amount accuracy is modified by
	var/accuracy_mod
	///generated visor icon for us to use when updating icon
	var/icon/visor_icon
	///visor iconstate name to use
	var/visor_icon_state = "visor"
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
	if(disabled && !has_destroyed_iconstate)
		return
	. = list()
	var/prefix = ""
	if(owner.is_wreck)
		prefix = "d_"
	else if(owner.leg_overload_mode && has_boosting_state)
		prefix = "b_"

	. += list(
		iconstate2appearance(overlay_icon, prefix+icon_state),
		iconstate2appearance(visor_icon, prefix+visor_icon_state),
		emissive_appearance(visor_icon, prefix+visor_icon_state, owner)
	)
	if(has_damage_overlays)
		var/percent
		if(initial(part_health))
			percent = (part_health / initial(part_health))
		else
			percent = owner.obj_integrity / owner.max_integrity
		if(percent > 0.75)
			return
		var/dmg_percent = max(CEILING(percent, 0.25)*100, 25)
		. += iconstate2appearance(greyscale_type::icon_file, prefix+icon_state+"[dmg_percent]")

/datum/mech_limb/head/disable()
	. = ..()
	if(!.)
		return
	for(var/mob/occupant in owner.occupants)
		REMOVE_TRAIT(occupant, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
		occupant.update_sight()

/datum/mech_limb/head/reenable()
	. = ..()
	if(!.)
		return
	for(var/mob/occupant in owner.occupants)
		ADD_TRAIT(occupant, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
		occupant.update_sight()

/datum/mech_limb/head/recon
	part_health = 120
	accuracy_mod = 1.2
	light_range = 7
	weight = 20
	greyscale_type = /datum/greyscale_config/mech_recon/head
	visor_config = /datum/greyscale_config/mech_recon/visor

/datum/mech_limb/head/assault
	part_health = 150
	accuracy_mod = 1.1
	light_range = 6
	weight = 35
	greyscale_type = /datum/greyscale_config/mech_assault/head
	visor_config = /datum/greyscale_config/mech_assault/visor

/datum/mech_limb/head/vanguard
	part_health = 180
	accuracy_mod = 1
	light_range = 5
	weight = 55
	greyscale_type = /datum/greyscale_config/mech_vanguard/head
	visor_config = /datum/greyscale_config/mech_vanguard/visor

/*
/datum/mech_limb/head/light
	part_health = 120
	accuracy_mod = 1.2
	light_range = 7
	weight = 20
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_light/head
	visor_config = /datum/greyscale_config/mech_light/visor
*/
/datum/mech_limb/head/medium
	part_health = 150
	accuracy_mod = 1.1
	light_range = 6
	weight = 35
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_medium/head
	visor_config = /datum/greyscale_config/mech_medium/visor
/*
/datum/mech_limb/head/heavy
	part_health = 180
	accuracy_mod = 1
	light_range = 5
	weight = 55
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_heavy/head
	visor_config = /datum/greyscale_config/mech_heavy/visor
*/
/datum/mech_limb/torso
	display_name = "Torso"
	icon_state = "core"
	weight = 80
	///health to set the torso to
	var/health_set = 250
	///max repairpacks to set the mech to
	var/repairpacks = 2

/datum/mech_limb/torso/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	. = ..()
	attached.max_integrity = health_set
	attached.obj_integrity = health_set
	attached.max_repairpacks = repairpacks
	attached.stored_repairpacks = repairpacks

/datum/mech_limb/torso/detach(obj/vehicle/sealed/mecha/combat/greyscale/detached)
	. = ..()
	detached.max_repairpacks = 0
	detached.stored_repairpacks = 0

/datum/mech_limb/torso/recon
	health_set = 500
	repairpacks = 3
	weight = 50
	greyscale_type = /datum/greyscale_config/mech_recon/torso

/datum/mech_limb/torso/recon/hvh
	health_set = 450
	repairpacks = 1

/datum/mech_limb/torso/assault
	health_set = 700
	repairpacks = 2
	weight = 80
	greyscale_type = /datum/greyscale_config/mech_assault/torso

/datum/mech_limb/torso/assault/hvh
	repairpacks = 1

/datum/mech_limb/torso/vanguard
	health_set = 1000
	weight = 100
	repairpacks = 1
	greyscale_type = /datum/greyscale_config/mech_vanguard/torso
/*
/datum/mech_limb/torso/light
	health_set = 250
	repairpacks = 3
	weight = 50
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_light/torso
*/
/datum/mech_limb/torso/medium
	health_set = 300
	repairpacks = 2
	weight = 80
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_medium/torso
/*
/datum/mech_limb/torso/heavy
	health_set = 350
	weight = 100
	repairpacks = 1
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_heavy/torso
*/
//MECH ARMS
/datum/mech_limb/arm
	icon_state = "arm"
	part_health = 200
	weight = 45
	var/gun_icon = 'icons/mecha/mech_gun_overlays.dmi'
	/// Amount scatter is modified by when this arm shoots
	var/scatter_mod = 0
	///which slot this arm is equipped to when it is attached
	var/arm_slot
	///pixels to offset the overlay of the gun by
	var/pixel_x_offset = -32

/datum/mech_limb/arm/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	arm_slot = slot
	if(arm_slot == MECH_GREY_R_ARM) // this is on purpose, bodyzones dont cleanly convert to mech limbs
		def_zones = list(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)
		display_name = "Right Arm"
		icon_state = "right"
	else
		def_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)
		display_name = "Left Arm"
		icon_state = "left"
	return ..()

/datum/mech_limb/arm/detach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	arm_slot = null
	return ..()

/datum/mech_limb/arm/get_overlays()
	if(disabled && !has_destroyed_iconstate)
		return
	. = list()
	var/prefix = ""
	if(owner.is_wreck)
		prefix = "d_"
	else if (owner.leg_overload_mode && has_boosting_state)
		prefix = "b_"
	if(!owner.is_wreck && !owner.swapped_to_backweapons && (MECHA_R_BACK in owner.equip_by_category))
		prefix += "fire"
	. += iconstate2appearance(overlay_icon, prefix+icon_state)
	if(has_damage_overlays)
		var/percent
		if(initial(part_health))
			percent = (part_health / initial(part_health))
		else
			percent = owner.obj_integrity / owner.max_integrity
		if(percent > 0.75)
			return
		var/dmg_percent = max(CEILING(percent, 0.25)*100, 25)
		. += iconstate2appearance(greyscale_type::icon_file, prefix+icon_state+"arm"+"[dmg_percent]")

/datum/mech_limb/arm/recon
	part_health = 100
	weight = 25
	scatter_mod = 0
	greyscale_type = /datum/greyscale_config/mech_recon/arms

/datum/mech_limb/arm/assault
	part_health = 125
	weight = 45
	scatter_mod = -10
	greyscale_type = /datum/greyscale_config/mech_assault/arms

/datum/mech_limb/arm/vanguard
	part_health = 150
	weight = 65
	scatter_mod = -20
	greyscale_type = /datum/greyscale_config/mech_vanguard/arms
/*
/datum/mech_limb/arm/light
	part_health = 100
	weight = 25
	scatter_mod = 0
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	pixel_x_offset = 32
	gun_icon = 'icons/mecha/mech_core_weapons.dmi'
	greyscale_type = /datum/greyscale_config/mech_light/arms
*/
/datum/mech_limb/arm/medium
	part_health = 125
	weight = 45
	scatter_mod = -10
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	pixel_x_offset = 0
	gun_icon = 'icons/mecha/mech_core_weapons.dmi'
	greyscale_type = /datum/greyscale_config/mech_medium/arms
/*
/datum/mech_limb/arm/heavy
	part_health = 150
	weight = 65
	scatter_mod = -20
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	pixel_x_offset = 32
	gun_icon = 'icons/mecha/mech_core_weapons.dmi'
	greyscale_type = /datum/greyscale_config/mech_heavy/arms
*/
//MECH LEGS
/datum/mech_limb/legs
	display_name = "Legs"
	icon_state = "legs"
	part_health = 300
	def_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
	weight = 0
	/// current slowdown delay we are applying to the mech
	var/slowdown_delay = 0
	/// max weight we can carry when this limb is attached
	var/max_weight = 800

/datum/mech_limb/legs/intercept_damage(datum/source, damage_amount, damage_type, armor_type, effects, attack_dir, armour_penetration, mob/living/blame_mob)
	. = ..()
	if(. != COMPONENT_NO_TAKE_DAMAGE) // took dmg
		return
	update_movespeed()

/datum/mech_limb/legs/intercept_repair(datum/source, repair_amount, mob/user)
	. = ..()
	if(. != COMPONENT_NO_REPAIR) // repaired dmg
		return
	update_movespeed()

///updates movespeed after integrity changes
/datum/mech_limb/legs/proc/update_movespeed()
	owner.move_delay -= slowdown_delay
	slowdown_delay = (owner.move_delay) * (1-(part_health / initial(part_health)))
	owner.move_delay += slowdown_delay

/datum/mech_limb/legs/recon
	part_health = 145
	slowdown_mod = -0.5
	max_weight = 500
	greyscale_type = /datum/greyscale_config/mech_recon/legs

/datum/mech_limb/legs/assault
	part_health = 175
	slowdown_mod = -0.3
	max_weight = 800
	greyscale_type = /datum/greyscale_config/mech_assault/legs

/datum/mech_limb/legs/vanguard
	part_health = 200
	slowdown_mod = 0.1
	max_weight = 1000
	greyscale_type = /datum/greyscale_config/mech_vanguard/legs

/*
/datum/mech_limb/legs/light
	part_health = 145
	slowdown_mod = -0.5
	max_weight = 500
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_light/legs
*/
/datum/mech_limb/legs/medium
	part_health = 175
	slowdown_mod = -0.3
	max_weight = 800
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_medium/legs
/*
/datum/mech_limb/legs/heavy
	part_health = 200
	slowdown_mod = 0.1
	max_weight = 1000
	has_damage_overlays = TRUE
	has_boosting_state = TRUE
	has_destroyed_iconstate = TRUE
	greyscale_type = /datum/greyscale_config/mech_heavy/legs
*/
