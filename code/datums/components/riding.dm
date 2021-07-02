/datum/component/riding
	var/last_vehicle_move = 0 //used for move delays
	var/last_move_diagonal = FALSE
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/keytype

	var/slowed = FALSE
	var/slowvalue = 1

	var/list/riding_offsets = list()	//position_of_user = list(dir = list(px, py)), or RIDING_OFFSET_ALL for a generic one.
	var/list/directional_vehicle_layers = list()	//["[DIRECTION]"] = layer. Don't set it for a direction for default, set a direction to null for no change.
	var/list/directional_vehicle_offsets = list()	//same as above but instead of layer you have a list(px, py)
	var/list/allowed_turf_typecache
	var/list/forbid_turf_typecache					//allow typecache for only certain turfs, forbid to allow all but those. allow only certain turfs will take precedence.
	var/allow_one_away_from_valid_turf = TRUE		//allow moving one tile away from a valid turf but not more.
	var/override_allow_spacemove = FALSE
	var/drive_verb = "drive"
	var/ride_check_rider_incapacitated = FALSE
	var/ride_check_rider_restrained = FALSE
	var/ride_check_ridden_incapacitated = FALSE

	var/del_on_unbuckle_all = FALSE

/datum/component/riding/Initialize()
	. = ..()
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/riding/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, .proc/vehicle_mob_buckle)
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/vehicle_mob_unbuckle)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/vehicle_moved)

/datum/component/riding/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_BUCKLE, COMSIG_MOVABLE_UNBUCKLE, COMSIG_MOVABLE_MOVED))
	return ..()

/datum/component/riding/proc/vehicle_mob_unbuckle(datum/source, mob/living/M, force = FALSE)
	SIGNAL_HANDLER
	var/atom/movable/AM = parent
	restore_position(M)
	if(del_on_unbuckle_all && !LAZYLEN(AM.buckled_mobs))
		qdel(src)

/datum/component/riding/proc/vehicle_mob_buckle(datum/source, mob/living/buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	SIGNAL_HANDLER
	handle_vehicle_offsets()

/datum/component/riding/proc/handle_vehicle_layer()
	var/atom/movable/AM = parent
	var/static/list/defaults = list(TEXT_NORTH = OBJ_LAYER, TEXT_SOUTH = ABOVE_MOB_LAYER, TEXT_EAST = ABOVE_MOB_LAYER, TEXT_WEST = ABOVE_MOB_LAYER)
	. = defaults["[AM.dir]"]
	if(directional_vehicle_layers["[AM.dir]"])
		. = directional_vehicle_layers["[AM.dir]"]
	if(isnull(.))	//you can set it to null to not change it.
		. = AM.layer
	AM.layer = .

/datum/component/riding/proc/set_vehicle_dir_layer(dir, layer)
	directional_vehicle_layers["[dir]"] = layer

/datum/component/riding/proc/vehicle_moved(datum/source)
	SIGNAL_HANDLER
	var/atom/movable/AM = parent
	for(var/i in AM.buckled_mobs)
		ride_check(i)
	handle_vehicle_offsets()
	handle_vehicle_layer()

/datum/component/riding/proc/ride_check(mob/living/M)
	var/atom/movable/AM = parent
	var/mob/AMM = AM
	if((ride_check_rider_restrained && M.restrained(RESTRAINED_NECKGRAB)) || (ride_check_rider_incapacitated && M.incapacitated(restrained_flags = RESTRAINED_NECKGRAB)) || (ride_check_ridden_incapacitated && istype(AMM) && AMM.incapacitated(restrained_flags = RESTRAINED_NECKGRAB)))
		M.visible_message("<span class='warning'>[M] falls off of [AM]!</span>",
			"<span class='warning'>You fall off of [AM]!</span>")
		AM.unbuckle_mob(M)
	return TRUE

/datum/component/riding/proc/force_dismount(mob/living/M, silent)
	var/atom/movable/AM = parent
	AM.unbuckle_mob(M)

/datum/component/riding/proc/handle_vehicle_offsets()
	var/atom/movable/AM = parent
	var/AM_dir = "[AM.dir]"
	var/passindex = 0
	for(var/m in AM.buckled_mobs)
		passindex++
		var/mob/living/buckled_mob = m
		var/list/offsets = get_offsets(passindex)
		var/rider_dir = get_rider_dir(passindex)
		buckled_mob.setDir(rider_dir)
		dir_loop:
			for(var/offsetdir in offsets)
				if(offsetdir == AM_dir)
					var/list/diroffsets = offsets[offsetdir]
					buckled_mob.pixel_x = diroffsets[1]
					if(diroffsets.len >= 2)
						buckled_mob.pixel_y = diroffsets[2]
					if(diroffsets.len == 3)
						buckled_mob.layer = diroffsets[3]
					break dir_loop
	var/list/static/default_vehicle_pixel_offsets = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0))
	var/px = default_vehicle_pixel_offsets[AM_dir]
	var/py = default_vehicle_pixel_offsets[AM_dir]
	if(directional_vehicle_offsets[AM_dir])
		if(isnull(directional_vehicle_offsets[AM_dir]))
			px = AM.pixel_x
			py = AM.pixel_y
		else
			px = directional_vehicle_offsets[AM_dir][1]
			py = directional_vehicle_offsets[AM_dir][2]
	AM.pixel_x = px
	AM.pixel_y = py

/datum/component/riding/proc/set_vehicle_dir_offsets(dir, x, y)
	directional_vehicle_offsets["[dir]"] = list(x, y)

//Override this to set your vehicle's various pixel offsets
/datum/component/riding/proc/get_offsets(pass_index) // list(dir = x, y, layer)
	. = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0))
	if(riding_offsets["[pass_index]"])
		. = riding_offsets["[pass_index]"]
	else if(riding_offsets["[RIDING_OFFSET_ALL]"])
		. = riding_offsets["[RIDING_OFFSET_ALL]"]

/datum/component/riding/proc/set_riding_offsets(index, list/offsets)
	if(!islist(offsets))
		return FALSE
	riding_offsets["[index]"] = offsets

//Override this to set the passengers/riders dir based on which passenger they are.
//ie: rider facing the vehicle's dir, but passenger 2 facing backwards, etc.
/datum/component/riding/proc/get_rider_dir(pass_index)
	var/atom/movable/AM = parent
	return AM.dir

//KEYS
/datum/component/riding/proc/keycheck(mob/user)
	return !keytype || istype(user.get_held_item(), keytype)

//BUCKLE HOOKS
/datum/component/riding/proc/restore_position(mob/living/buckled_mob)
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.view_size.reset_to_default()

//MOVEMENT
/datum/component/riding/proc/turf_check(turf/next, turf/current)
	if(allowed_turf_typecache && !allowed_turf_typecache[next.type])
		return (allow_one_away_from_valid_turf && allowed_turf_typecache[current.type])
	else if(forbid_turf_typecache && forbid_turf_typecache[next.type])
		return (allow_one_away_from_valid_turf && !forbid_turf_typecache[current.type])
	return TRUE

/datum/component/riding/proc/handle_ride(mob/user, direction)
	var/atom/movable/AM = parent
	if(user.incapacitated())
		Unbuckle(user)
		return

	if(world.time < last_vehicle_move + ((last_move_diagonal ? 2 : 1) * vehicle_move_delay))
		return
	last_vehicle_move = world.time

	if(keycheck(user))
		var/turf/next = get_step(AM, direction)
		var/turf/current = get_turf(AM)
		if(!istype(next) || !istype(current))
			return	//not happening.
		if(!turf_check(next, current))
			to_chat(user, "<span class='warning'>Your \the [AM] can not go onto [next]!</span>")
			return
		if(!isturf(AM.loc))
			return
		step(AM, direction)

		if((direction & (direction - 1)) && (AM.loc == next))		//moved diagonally
			last_move_diagonal = TRUE
		else
			last_move_diagonal = FALSE

		handle_vehicle_layer()
		handle_vehicle_offsets()
	else
		to_chat(user, "<span class='warning'>You'll need the keys in one of your hands to [drive_verb] [AM].</span>")

/datum/component/riding/proc/Unbuckle(atom/movable/buckled_thing)
	INVOKE_ASYNC(parent, /atom/movable/.proc/unbuckle_mob, buckled_thing)

///////Yes, I said humans. No, this won't end well...//////////
/datum/component/riding/human
	del_on_unbuckle_all = TRUE

/datum/component/riding/human/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_carrier_unarmed_melee)

/datum/component/riding/human/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
	return ..()

/datum/component/riding/human/vehicle_mob_unbuckle(datum/source, mob/living/buckled_mob, force = FALSE)
	var/mob/living/carbon/human/human_carrier = parent
	human_carrier.remove_movespeed_modifier(MOVESPEED_ID_HUMAN_CARRYING)
	UnregisterSignal(buckled_mob, COMSIG_MOVABLE_PRE_THROW)
	return ..()

/datum/component/riding/human/vehicle_mob_buckle(datum/source, mob/living/buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	var/mob/living/carbon/human/human_carrier = parent

	if(!is_type_in_typecache(buckling_mob, human_carrier.can_ride_typecache))
		buckling_mob.visible_message("<span class='warning'>[buckling_mob] really can't seem to mount [human_carrier]...</span>")
		return COMPONENT_MOVABLE_BUCKLE_STOPPED
	if(human_carrier.buckled || (buckling_mob in human_carrier.buckled_mobs) || (LAZYLEN(human_carrier.buckled_mobs) >= human_carrier.max_buckled_mobs))
		return COMPONENT_MOVABLE_BUCKLE_STOPPED
	if(hands_needed && !equip_buckle_inhands(human_carrier, hands_needed, buckling_mob))
		if(!silent)
			human_carrier.visible_message("<span class='warning'>[human_carrier] can't get a grip on [buckling_mob] because their hands are full!</span>",
				"<span class='warning'>You can't get a grip on [buckling_mob] because your hands are full!</span>")
		return COMPONENT_MOVABLE_BUCKLE_STOPPED
	if(target_hands_needed && !equip_buckle_inhands(buckling_mob, target_hands_needed))
		if(!silent)
			buckling_mob.visible_message("<span class='warning'>[buckling_mob] can't get a grip on [human_carrier] because their hands are full!</span>",
				"<span class='warning'>You can't get a grip on [human_carrier] because your hands are full!</span>")
		return COMPONENT_MOVABLE_BUCKLE_STOPPED

	if(target_hands_needed)
		ride_check_rider_restrained = TRUE

	human_carrier.buckle_lying = lying_buckle
	human_carrier.stop_pulling()
	handle_vehicle_layer()

	human_carrier.add_movespeed_modifier(MOVESPEED_ID_HUMAN_CARRYING, TRUE, 0, NONE, TRUE, HUMAN_CARRY_SLOWDOWN)
	RegisterSignal(buckling_mob, COMSIG_MOVABLE_PRE_THROW, .proc/on_passenger_throw)
	return ..()


/datum/component/riding/human/proc/on_carrier_unarmed_melee(datum/source, atom/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_carrier = parent
	if(human_carrier.a_intent != INTENT_DISARM || !(target in human_carrier.buckled_mobs))
		return
	force_dismount(target)

/datum/component/riding/human/proc/on_passenger_throw(datum/source, atom/target, range, speed, thrower, spin)
	SIGNAL_HANDLER
	force_dismount(source, TRUE)


/datum/component/riding/human/handle_vehicle_layer()
	var/atom/movable/AM = parent
	if(!LAZYLEN(AM.buckled_mobs))
		AM.layer = MOB_LAYER
		return

	for(var/mob/M in AM.buckled_mobs) //ensure proper layering of piggyback and carry, sometimes weird offsets get applied
		M.layer = MOB_LAYER

	if(AM.buckle_lying)
		if(AM.dir == NORTH)
			AM.layer = OBJ_LAYER
		else
			AM.layer = ABOVE_MOB_LAYER
		return

	if(AM.dir == SOUTH)
		AM.layer = ABOVE_MOB_LAYER
	else
		AM.layer = OBJ_LAYER


/datum/component/riding/human/get_offsets(pass_index)
	var/mob/living/carbon/human/H = parent
	if(H.buckle_lying)
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(0, 6), TEXT_WEST = list(0, 6))
	else
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-6, 4), TEXT_WEST = list( 6, 4))


/datum/component/riding/human/force_dismount(mob/living/user, silent)
	var/atom/movable/AM = parent
	AM.unbuckle_mob(user)
	user.Paralyze(2 SECONDS)
	if(!silent)
		user.visible_message("<span class='warning'>[AM] pushes [user] off of [AM.p_them()]!</span>",
			"<span class='warning'>[AM] pushes you off of [AM.p_them()]!</span>")


/datum/component/riding/human/proc/equip_buckle_inhands(mob/living/carbon/human/user, amount_required = 1, riding_target_override)
	var/amount_equipped = 0
	for(var/i in 1 to amount_required)
		var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user, riding_target_override ? riding_target_override : user)
		if(!user.put_in_hands(inhand, TRUE))
			break
		amount_equipped++
	if(amount_equipped >= amount_required)
		return TRUE
	unequip_buckle_inhands(user)
	return FALSE

/datum/component/riding/human/proc/unequip_buckle_inhands(mob/living/carbon/user)
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.parent != user)
			stack_trace("RIDING OFFHAND ON WRONG MOB")
		if(O.selfdeleting)
			continue
		qdel(O)
	return TRUE


/obj/item/riding_offhand
	name = "offhand"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags_item = NOBLUDGEON|DELONDROP|ITEM_ABSTRACT
	resistance_flags = RESIST_ALL
	var/mob/living/carbon/rider
	var/mob/living/parent
	var/selfdeleting = FALSE

/obj/item/riding_offhand/Initialize(mapload, rider)
	. = ..()
	parent = loc
	src.rider = rider
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/on_parent_unbuckle)

/obj/item/riding_offhand/Destroy()
	if(rider in parent.buckled_mobs)
		parent.unbuckle_mob(rider)
	parent = null
	rider = null
	return ..()

/obj/item/riding_offhand/proc/on_parent_unbuckle(datum/source, mob/living/buckled_mob, force = FALSE)
	if(selfdeleting || buckled_mob != rider)
		return
	selfdeleting = TRUE
	qdel(src)

/obj/item/riding_offhand/dropped(mob/user)
	selfdeleting = TRUE
	return ..()

/obj/item/riding_offhand/equipped(mob/user, slot)
	if(loc != rider && loc != parent)
		selfdeleting = TRUE
		qdel(src)
	return ..()
