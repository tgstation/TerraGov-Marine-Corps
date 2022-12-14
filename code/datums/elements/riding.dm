/**
 * This element is used to indicate that a movable atom can be mounted by mobs in order to ride it. The movable is considered mounted when a mob is buckled to it,
 * at which point a [riding component][/datum/component/riding] is created on the movable, and that component handles the actual riding behavior.
 *
 * Besides the target, the ridable element has one argument: the component subtype. This is not really ideal since there's ~20-30 component subtypes rather than
 * having the behavior defined on the ridable atoms themselves or some such, but because the old riding behavior was so horrifyingly spread out and redundant,
 * just having the variables, behavior, and procs be standardized is still a big improvement.
 */
/datum/element/ridable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	/// The specific riding component subtype we're loading our instructions from, don't leave this as default please!
	var/riding_component_type = /datum/component/riding

/datum/element/ridable/Attach(atom/movable/target, component_type = /datum/component/riding, potion_boost = FALSE)
	. = ..()
	if(!ismovable(target))
		return COMPONENT_INCOMPATIBLE

	if(component_type == /datum/component/riding)
		stack_trace("Tried attaching a ridable element to [target] with basic/abstract /datum/component/riding component type. Please designate a specific riding component subtype when adding the ridable element.")
		return COMPONENT_INCOMPATIBLE

	riding_component_type = component_type

	RegisterSignal(target, COMSIG_MOVABLE_PREBUCKLE, .proc/check_mounting)

/datum/element/ridable/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_MOVABLE_PREBUCKLE, COMSIG_PARENT_ATTACKBY))
	return ..()

/// Someone is buckling to this movable, which is literally the only thing we care about (other than speed potions)
/datum/element/ridable/proc/check_mounting(atom/movable/target_movable, mob/living/potential_rider, force = FALSE, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	SIGNAL_HANDLER

	if(HAS_TRAIT(potential_rider, TRAIT_CANT_RIDE))
		return

	if(target_hands_needed && !equip_buckle_inhands(potential_rider, target_hands_needed, target_movable)) // can be either 1 (cyborg riding) or 2 (human piggybacking) hands
		potential_rider.visible_message("<span class='warning'>[potential_rider] can't get a grip on [target_movable] because [potential_rider.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [target_movable] because your hands are full!</span>")
		return COMPONENT_BLOCK_BUCKLE
/*
	if((ride_check_flags & RIDER_NEEDS_LEGS) && HAS_TRAIT(potential_rider, TRAIT_FLOORED))
		potential_rider.visible_message("<span class='warning'>[potential_rider] can't get [potential_rider.p_their()] footing on [target_movable]!</span>",
			"<span class='warning'>You can't get your footing on [target_movable]!</span>")
		return COMPONENT_BLOCK_BUCKLE
*/

	var/mob/living/target_living = target_movable

	// need to see if !equip_buckle_inhands() checks are enough to skip any needed incapac/restrain checks
	// CARRIER_NEEDS_ARM shouldn't apply if the ridden isn't even a living mob
	if(hands_needed && !equip_buckle_inhands(target_living, hands_needed, target_living, potential_rider))
		target_living.visible_message("<span class='warning'>[target_living] can't get a grip on [potential_rider] because [target_living.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [potential_rider] because your hands are full!</span>")
		return COMPONENT_BLOCK_BUCKLE

	target_living.AddComponent(riding_component_type, potential_rider, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)

/// Try putting the appropriate number of [riding offhand items][/obj/item/riding_offhand] into the target's hands, return FALSE if we can't
/datum/element/ridable/proc/equip_buckle_inhands(mob/living/carbon/human/user, amount_required = 1, atom/movable/target_movable, riding_target_override = null)
	var/atom/movable/AM = target_movable
	var/amount_equipped = 0
	for(var/amount_needed = amount_required, amount_needed > 0, amount_needed--)
		var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user)
		if(!riding_target_override)
			inhand.rider = user
		else
			inhand.rider = riding_target_override
		inhand.parent = AM

		if(user.put_in_hands(inhand))
			amount_equipped++
		else
			qdel(inhand)
			break

	if(amount_equipped >= amount_required)
		return TRUE
	else
		unequip_buckle_inhands(user, target_movable)
		return FALSE


/// Remove all of the relevant [riding offhand items][/obj/item/riding_offhand] from the target
/datum/element/ridable/proc/unequip_buckle_inhands(mob/living/carbon/user, atom/movable/target_movable)
	var/atom/movable/AM = target_movable
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.parent != AM)
			CRASH("RIDING OFFHAND ON WRONG MOB")
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE




/obj/item/riding_offhand
	name = "offhand"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags_item = ITEM_ABSTRACT | DELONDROP | NOBLUDGEON
	resistance_flags = INDESTRUCTIBLE | UNACIDABLE | PROJECTILE_IMMUNE
	var/mob/living/carbon/rider
	var/mob/living/parent
	var/selfdeleting = FALSE

/obj/item/riding_offhand/dropped()
	selfdeleting = TRUE
	return ..()

/obj/item/riding_offhand/equipped()
	if(loc != rider && loc != parent)
		selfdeleting = TRUE
		qdel(src)
	return ..()

/obj/item/riding_offhand/Destroy()
	var/atom/movable/AM = parent
	if(selfdeleting)
		if(rider in AM.buckled_mobs)
			AM.unbuckle_mob(rider)
	return ..()

/obj/item/riding_offhand/on_thrown(mob/living/carbon/user, atom/target)
	if(rider == user)
		return //Piggyback user.
	user.unbuckle_mob(rider)
	var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
	var/turf/end_T = get_turf(target)
	if(start_T && end_T)
		log_combat(user, src, "thrown", addition = "from tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)] with the target tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]")
	return rider
