// For any mob that can be ridden

/datum/component/riding/creature
	/// If TRUE, this creature's movements can be controlled by the rider while mounted (as opposed to riding cyborgs and humans, which is passive)
	var/can_be_driven = TRUE

/datum/component/riding/creature/Initialize(mob/living/riding_mob, force = FALSE, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()
	var/mob/living/living_parent = parent
	living_parent.stop_pulling() // was only used on humans previously, may change some other behavior
	log_riding(living_parent, riding_mob)
	riding_mob.set_glide_size(living_parent.glide_size)
	handle_vehicle_offsets(living_parent.dir)

	if(isanimal(parent))
		var/mob/living/simple_animal/simple_parent = parent
		simple_parent.stop_automated_movement = TRUE

/datum/component/riding/creature/Destroy(force, silent)
	unequip_buckle_inhands(parent)
	if(isanimal(parent))
		var/mob/living/simple_animal/simple_parent = parent
		simple_parent.stop_automated_movement = FALSE
	return ..()

/datum/component/riding/creature/RegisterWithParent()
	. = ..()
	if(can_be_driven)
		RegisterSignal(parent, COMSIG_RIDDEN_DRIVER_MOVE, PROC_REF(driver_move)) // this isn't needed on riding humans or cyborgs since the rider can't control them

/// Creatures need to be logged when being mounted
/datum/component/riding/creature/proc/log_riding(mob/living/living_parent, mob/living/rider)
	if(!istype(living_parent) || !istype(rider))
		return

	living_parent.log_message("is now being ridden by [rider]", LOG_ATTACK, color="pink")
	rider.log_message("started riding [living_parent]", LOG_ATTACK, color="pink")

// this applies to humans and most creatures, but is replaced again for cyborgs
/datum/component/riding/creature/ride_check(mob/living/rider)
	var/mob/living/living_parent = parent

	var/kick_us_off
	if(living_parent.lying_angle) // if we move while on the ground, the rider falls off
		kick_us_off = TRUE
	// for piggybacks and (redundant?) borg riding, check if the rider is stunned/restrained
	else if((ride_check_flags & RIDER_NEEDS_ARMS) && (rider.restrained(RESTRAINED_NECKGRAB) || rider.incapacitated(TRUE, TRUE)))
		kick_us_off = TRUE
	// for fireman carries, check if the ridden is stunned/restrained
	else if((ride_check_flags & CARRIER_NEEDS_ARM) && (rider.restrained(RESTRAINED_NECKGRAB) || living_parent.incapacitated(TRUE, TRUE)))
		kick_us_off = TRUE

	if(!kick_us_off)
		return TRUE

	rider.visible_message("<span class='warning'>[rider] falls off of [living_parent]!</span>", \
					"<span class='warning'>You fall off of [living_parent]!</span>")
	rider.Paralyze(1 SECONDS)
	rider.Knockdown(4 SECONDS)
	living_parent.unbuckle_mob(rider)

/datum/component/riding/creature/vehicle_mob_unbuckle(mob/living/living_parent, mob/living/former_rider, force = FALSE)
	if(istype(living_parent) && istype(former_rider))
		living_parent.log_message("is no longer being ridden by [former_rider]", LOG_ATTACK, color="pink")
		former_rider.log_message("is no longer riding [living_parent]", LOG_ATTACK, color="pink")
	return ..()

/datum/component/riding/creature/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if(!COOLDOWN_CHECK(src, vehicle_move_cooldown))
		return COMPONENT_DRIVER_BLOCK_MOVE
	if(!keycheck(user))
		if(ispath(keytype, /obj/item))
			var/obj/item/key = keytype
			to_chat(user, "<span class='warning'>You need a [initial(key.name)] to ride [movable_parent]!</span>")
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/mob/living/living_parent = parent
	var/turf/next = get_step(living_parent, direction)
	step(living_parent, direction)
	last_move_diagonal = ((direction & (direction - 1)) && (living_parent.loc == next))
	COOLDOWN_START(src, vehicle_move_cooldown, (last_move_diagonal? 2 : 1) * vehicle_move_delay)

/// Yeets the rider off, used for animals and cyborgs, redefined for humans who shove their piggyback rider off
/datum/component/riding/creature/proc/force_dismount(mob/living/rider, gentle = FALSE)
	var/atom/movable/movable_parent = parent
	movable_parent.unbuckle_mob(rider)

	if(!isanimal(movable_parent))
		return

	var/turf/target = get_edge_target_turf(movable_parent, movable_parent.dir)
	var/turf/targetm = get_step(get_turf(movable_parent), movable_parent.dir)
	rider.Move(targetm)
	rider.Knockdown(3 SECONDS)
	if(gentle)
		rider.visible_message("<span class='warning'>[rider] is thrown clear of [movable_parent]!</span>", \
		"<span class='warning'>You're thrown clear of [movable_parent]!</span>")
		rider.throw_at(target, 8, 3, movable_parent)
	else
		rider.visible_message("<span class='warning'>[rider] is thrown violently from [movable_parent]!</span>", \
		"<span class='warning'>You're thrown violently from [movable_parent]!</span>")
		rider.throw_at(target, 14, 5, movable_parent)

// ***************************************
// *********** Humans
// ***************************************
/datum/component/riding/creature/human
	can_be_driven = FALSE

/datum/component/riding/creature/human/Initialize(mob/living/riding_mob, force = FALSE, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	. = ..()
	var/mob/living/carbon/human/human_parent = parent
	human_parent.add_movespeed_modifier(MOVESPEED_ID_HUMAN_CARRYING, TRUE, 0, NONE, TRUE, HUMAN_CARRY_SLOWDOWN)

	if(ride_check_flags & RIDER_NEEDS_ARMS) // piggyback
		human_parent.buckle_lying = 0
		// the riding mob is made nondense so they don't bump into any dense atoms the carrier is pulling,
		// since pulled movables are moved before buckled movables
		riding_mob.density = FALSE
	else if(ride_check_flags & CARRIER_NEEDS_ARM) // fireman
		human_parent.buckle_lying = 90

/datum/component/riding/creature/human/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_SET_LYING_ANGLE, PROC_REF(check_carrier_fall_over))

/datum/component/riding/creature/human/log_riding(mob/living/living_parent, mob/living/rider)
	if(!istype(living_parent) || !istype(rider))
		return

	if(ride_check_flags & RIDER_NEEDS_ARMS) // piggyback
		living_parent.log_message("started giving [rider] a piggyback ride", LOG_ATTACK, color="pink")
		rider.log_message("started piggyback riding [living_parent]", LOG_ATTACK, color="pink")
	else if(ride_check_flags & CARRIER_NEEDS_ARM) // fireman
		living_parent.log_message("started fireman carrying [rider]", LOG_ATTACK, color="pink")
		rider.log_message("was fireman carried by [living_parent]", LOG_ATTACK, color="pink")

/datum/component/riding/creature/human/vehicle_mob_unbuckle(datum/source, mob/living/former_rider, force = FALSE)
	unequip_buckle_inhands(parent)
	var/mob/living/carbon/human/human_carrier = parent
	human_carrier.remove_movespeed_modifier(MOVESPEED_ID_HUMAN_CARRYING)
	former_rider.density = TRUE
	return ..()

/// If the carrier gets knocked over, force the rider(s) off and see if someone got hurt
/datum/component/riding/creature/human/proc/check_carrier_fall_over(mob/living/carbon/human/human_parent)
	SIGNAL_HANDLER

	for(var/mob/living/rider AS in human_parent.buckled_mobs)
		human_parent.unbuckle_mob(rider)
		rider.Paralyze(1 SECONDS)
		rider.Knockdown(4 SECONDS)
		human_parent.visible_message("<span class='danger'>[rider] topples off of [human_parent] as they both fall to the ground!</span>", \
					"<span class='warning'>You fall to the ground, bringing [rider] with you!</span>", "<span class='hear'>You hear two consecutive thuds.</span>")
		to_chat(rider, "<span class='danger'>[human_parent] falls to the ground, bringing you with [human_parent.p_them()]!</span>")

/datum/component/riding/creature/human/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	if(!AM.buckled_mobs || !length(AM.buckled_mobs))
		AM.layer = MOB_LAYER
		return

	for(var/mob/M in AM.buckled_mobs) //ensure proper layering of piggyback and carry, sometimes weird offsets get applied
		M.layer = MOB_LAYER

	if(!AM.buckle_lying) // rider is vertical, must be piggybacking
		if(dir == SOUTH)
			AM.layer = ABOVE_MOB_LAYER
		else
			AM.layer = OBJ_LAYER
	else  // laying flat, we must be firemanning the rider
		if(dir == NORTH)
			AM.layer = OBJ_LAYER
		else
			AM.layer = ABOVE_MOB_LAYER

/datum/component/riding/creature/human/get_offsets(pass_index)
	var/mob/living/carbon/human/H = parent
	if(H.buckle_lying)
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(0, 6), TEXT_WEST = list(0, 6))
	else
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-6, 4), TEXT_WEST = list( 6, 4))

/datum/component/riding/creature/human/force_dismount(mob/living/dismounted_rider)
	var/atom/movable/AM = parent
	AM.unbuckle_mob(dismounted_rider)
	dismounted_rider.Paralyze(1 SECONDS)
	dismounted_rider.Knockdown(4 SECONDS)
	dismounted_rider.visible_message("<span class='warning'>[AM] pushes [dismounted_rider] off of [AM.p_them()]!</span>", \
						"<span class='warning'>[AM] pushes you off of [AM.p_them()]!</span>")

// ***************************************
// *********** Simple Animals
// ***************************************
/datum/component/riding/creature/cow/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(-2, 8), TEXT_WEST = list(2, 8)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/creature/bear/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 8), TEXT_SOUTH = list(1, 8), TEXT_EAST = list(-3, 6), TEXT_WEST = list(3, 6)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(WEST, ABOVE_MOB_LAYER)

/datum/component/riding/creature/carp
	override_allow_spacemove = TRUE

/datum/component/riding/creature/carp/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 13), TEXT_SOUTH = list(0, 15), TEXT_EAST = list(-2, 12), TEXT_WEST = list(2, 12)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

// ***************************************
// *********** Crusher
// ***************************************
/datum/component/riding/creature/crusher
	can_be_driven = FALSE

/datum/component/riding/creature/crusher/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(-10, -3), TEXT_SOUTH = list(-11, 6), TEXT_EAST = list(-21, 4), TEXT_WEST = list(4, 4)))
	set_riding_offsets(/mob/living/carbon/xenomorph/runner, list(TEXT_NORTH = list(-16, 9), TEXT_SOUTH = list(-16, 17), TEXT_EAST = list(-21, 7), TEXT_WEST = list(-6, 7)))
	set_riding_offsets(/mob/living/carbon/xenomorph/larva, list(TEXT_NORTH = list(3, 6), TEXT_SOUTH = list(0, 16), TEXT_EAST = list(-2, 10), TEXT_WEST = list(0, 10)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_LYING_MOB_LAYER)
	set_vehicle_dir_layer(EAST, ABOVE_LYING_MOB_LAYER)
	set_vehicle_dir_layer(WEST, ABOVE_LYING_MOB_LAYER)

/datum/component/riding/creature/crusher/Initialize(mob/living/riding_mob, force = FALSE, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	. = ..()
	riding_mob.density = FALSE

/datum/component/riding/creature/crusher/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_SET_LYING_ANGLE, PROC_REF(check_carrier_fall_over))

/datum/component/riding/creature/crusher/log_riding(mob/living/living_parent, mob/living/rider)
	if(!istype(living_parent) || !istype(rider))
		return

	living_parent.log_message("started carrying [rider] on their back", LOG_ATTACK, color="pink")
	rider.log_message("started being carried on [living_parent]'s back", LOG_ATTACK, color="pink")

/datum/component/riding/creature/crusher/vehicle_mob_unbuckle(datum/source, mob/living/former_rider, force = FALSE)
	unequip_buckle_inhands(parent)
	former_rider.density = TRUE
	return ..()

/// If the crusher gets knocked over, force the riding rounys off and see if someone got hurt
/datum/component/riding/creature/crusher/proc/check_carrier_fall_over(mob/living/carbon/xenomorph/crusher/carrying_crusher)
	SIGNAL_HANDLER

	for(var/mob/living/rider AS in carrying_crusher.buckled_mobs)
		carrying_crusher.unbuckle_mob(rider)
		rider.Knockdown(1 SECONDS)
		carrying_crusher.visible_message("<span class='danger'>[rider] topples off of [carrying_crusher] as they both fall to the ground!</span>", \
					"<span class='warning'>You fall to the ground, bringing [rider] with you!</span>", "<span class='hear'>You hear two consecutive thuds.</span>")
		to_chat(rider, "<span class='danger'>[carrying_crusher] falls to the ground, bringing you with [carrying_crusher.p_them()]!</span>")

//Override this to set your vehicle's various pixel offsets
/datum/component/riding/creature/crusher/get_offsets(pass_index, mob_type) // list(dir = x, y, layer)
	. = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0))
	if (riding_offsets["[mob_type]"])
		. = riding_offsets["[mob_type]"]
	else if(riding_offsets["[RIDING_OFFSET_ALL]"])
		. = riding_offsets["[RIDING_OFFSET_ALL]"]

// ***************************************
// *********** Widow
// ***************************************
/datum/component/riding/creature/widow
	can_be_driven = FALSE

/datum/component/riding/creature/widow/handle_specials()
	. = ..()
	var/mob/living/widow = parent
	if(widow.stat == UNCONSCIOUS) //For spiderling guard
		set_riding_offsets(1, list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0)))
		set_riding_offsets(2, list(TEXT_NORTH = list(16, 16), TEXT_SOUTH = list(16, 16), TEXT_EAST = list(16, 16), TEXT_WEST = list(16, 16)))
		set_riding_offsets(3, list(TEXT_NORTH = list(-16, 16), TEXT_SOUTH = list(-16, 16), TEXT_EAST = list(-16, 16), TEXT_WEST = list(-16, 16)))
		set_riding_offsets(4, list(TEXT_NORTH = list(16, 32), TEXT_SOUTH = list(16, -16), TEXT_EAST = list(16, -16), TEXT_WEST = list(16, -16)))
		set_riding_offsets(5, list(TEXT_NORTH = list(0, -16), TEXT_SOUTH = list(-16, -16), TEXT_EAST = list(-16, -16), TEXT_WEST = list(-16, -16)))
		set_vehicle_dir_layer(SOUTH, ABOVE_ALL_MOB_LAYER)
		set_vehicle_dir_layer(NORTH, ABOVE_ALL_MOB_LAYER)
		set_vehicle_dir_layer(EAST, ABOVE_ALL_MOB_LAYER)
		set_vehicle_dir_layer(WEST, ABOVE_ALL_MOB_LAYER)
		return
	set_riding_offsets(1, list(TEXT_NORTH = list(-16, 9), TEXT_SOUTH = list(-16, 17), TEXT_EAST = list(-21, 7), TEXT_WEST = list(-6, 7)))
	set_riding_offsets(2, list(TEXT_NORTH = list(16, 16), TEXT_SOUTH = list(16, 17), TEXT_EAST = list(21, 7), TEXT_WEST = list(6, 7)))
	set_riding_offsets(3, list(TEXT_NORTH = list(8, 8), TEXT_SOUTH = list(-8, 21), TEXT_EAST = list(14, 11), TEXT_WEST = list(0, 2)))
	set_riding_offsets(4, list(TEXT_NORTH = list(-8, 16), TEXT_SOUTH = list(-16, 13), TEXT_EAST = list(-21, 2), TEXT_WEST = list(6, 11)))
	set_riding_offsets(5, list(TEXT_NORTH = list(8, 8), TEXT_SOUTH = list(8, 12), TEXT_EAST = list(21, 2), TEXT_WEST = list(-6, 11)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_LYING_MOB_LAYER)
	set_vehicle_dir_layer(EAST, ABOVE_LYING_MOB_LAYER)
	set_vehicle_dir_layer(WEST, ABOVE_LYING_MOB_LAYER)

/datum/component/riding/creature/widow/Initialize(mob/living/riding_mob, force = FALSE, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	. = ..()
	riding_mob.density = FALSE

// If we call parent here , we get registered for COMSIG_MOVABLE_BUMP, and when we do bump, there will be a bad index runtime
/datum/component/riding/creature/widow/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(vehicle_turned))
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(vehicle_mob_unbuckle))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(vehicle_moved))
	RegisterSignals(parent, list(COMSIG_XENOMORPH_ATTACK_LIVING, COMSIG_XENOMORPH_ATTACK_OBJ, COMSIG_XENOMORPH_ATTACK_HOSTILE_XENOMORPH), PROC_REF(check_widow_attack))

/datum/component/riding/creature/widow/vehicle_mob_unbuckle(datum/source, mob/living/former_rider, force = FALSE)
	unequip_buckle_inhands(parent)
	former_rider.density = initial(former_rider.density)
	REMOVE_TRAIT(former_rider, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	return ..()

/// If the widow gets knocked over, force the riding rounys off and see if someone got hurt
/datum/component/riding/creature/widow/proc/check_widow_attack(mob/living/carbon/xenomorph/widow/carrying_widow)
	SIGNAL_HANDLER
	for(var/mob/living/rider AS in carrying_widow.buckled_mobs)
		carrying_widow.unbuckle_mob(rider)
		REMOVE_TRAIT(rider, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)

// Spiderlings latch on to crit widows when guarding and cannot be kicked off..
/datum/component/riding/creature/widow/ride_check(mob/living/rider)
	var/mob/living/widow = parent
	return widow.stat == UNCONSCIOUS

//..nor can they be laid under widow..
/datum/component/riding/creature/widow/handle_vehicle_layer(dir)
	var/mob/living/widow = parent
	if(widow.stat == UNCONSCIOUS)
		return
	return ..()

//..and nor will they change direction.
/datum/component/riding/creature/widow/handle_vehicle_offsets(dir)
	var/mob/living/widow = parent
	if(widow.stat == UNCONSCIOUS)
		dir = SOUTH
	return ..()
