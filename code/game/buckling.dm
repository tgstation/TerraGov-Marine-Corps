//Interaction
/atom/movable/proc/mouse_buckle_handling(atom/movable/dropping, mob/living/user)
	if(isliving(dropping))
		. = dropping
	else if(isgrabitem(dropping))
		var/obj/item/grab/grab_item = dropping
		if(isliving(grab_item.grabbed_thing))
		
			. = grab_item.grabbed_thing
	if(. && user_buckle_mob(., user))
		return TRUE

//procs that handle the actual buckling and unbuckling //TODO replace the args in this proc with flags
/atom/movable/proc/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(!isliving(buckling_mob))
		return FALSE

	if(check_loc && buckling_mob.loc != loc)
		return FALSE

	if((!(buckle_flags & CAN_BUCKLE) && !force) || buckling_mob.buckled || (LAZYLEN(buckled_mobs) >= max_buckled_mobs) || (buckle_flags & BUCKLE_REQUIRES_RESTRAINTS && !buckling_mob.restrained()) || buckling_mob == src)
		return FALSE

	if(!(buckling_mob.buckle_flags & CAN_BE_BUCKLED) && !force)
		if(!silent)
			if(buckling_mob == usr)
				balloon_alert_to_viewers("can't buckle")
			else
				balloon_alert_to_viewers("can't buckle [buckling_mob] to [src]")
		return FALSE

	// This signal will check if the mob is mounting this atom to ride it. There are 3 possibilities for how this goes
	// 1. This movable doesn't have a ridable element and can't be ridden, so nothing gets returned, so continue on
	// 2. There's a ridable element but we failed to mount it for whatever reason (maybe it has no seats left, for example), so we cancel the buckling
	// 3. There's a ridable element and we were successfully able to mount, so keep it going and continue on with buckling
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PREBUCKLE, buckling_mob, force, check_loc, lying_buckle , hands_needed, target_hands_needed, silent) & COMPONENT_BLOCK_BUCKLE)
		return FALSE


	if(buckling_mob.pulledby)
		if(buckle_flags & BUCKLE_PREVENTS_PULL)
			buckling_mob.pulledby.stop_pulling()
		else if(isliving(buckling_mob.pulledby))
			var/mob/living/buckling_living = buckling_mob.pulledby
			buckling_living.reset_pull_offsets(buckling_living, TRUE)
			if(!anchored)
				buckling_living.start_pulling(src)

	if(buckling_mob.loc != loc)
		buckling_mob.forceMove(loc)

	if(pulledby)
		buckling_mob.set_glide_size(pulledby.glide_size)
	else
		buckling_mob.set_glide_size(glide_size)

	buckling_mob.glide_modifier_flags |= GLIDE_MOD_BUCKLED
	buckling_mob.buckled = src
	buckling_mob.setDir(dir)
	LAZYADD(buckled_mobs, buckling_mob)
	if(buckle_lying != -1)
		ADD_TRAIT(buckling_mob, TRAIT_FLOORED, BUCKLE_TRAIT)
	buckling_mob.throw_alert("buckled", /atom/movable/screen/alert/restrained/buckled)
	post_buckle_mob(buckling_mob, silent)

	RegisterSignal(buckling_mob, COMSIG_LIVING_DO_RESIST, PROC_REF(resisted_against))
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	return TRUE

/obj/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	. = ..()
	if(!.)
		return
	if(resistance_flags & ON_FIRE) //Sets the mob on fire if you buckle them to a burning atom/movableect
		buckling_mob.adjust_fire_stacks(1)
		buckling_mob.IgniteMob()


/atom/movable/proc/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	if(!isliving(buckled_mob) || buckled_mob.buckled != src || (!(buckle_flags & CAN_BUCKLE) && !force))
		return
	. = buckled_mob
	buckled_mob.buckled = null
	buckled_mob.glide_modifier_flags &= ~GLIDE_MOD_BUCKLED
	buckled_mob.reset_glide_size()
	buckled_mob.anchored = initial(buckled_mob.anchored)
	if(buckle_lying != -1)
		REMOVE_TRAIT(buckled_mob, TRAIT_FLOORED, BUCKLE_TRAIT)
	buckled_mob.clear_alert("buckled")
	LAZYREMOVE(buckled_mobs, buckled_mob)

	UnregisterSignal(buckled_mob, COMSIG_LIVING_DO_RESIST)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNBUCKLE, buckled_mob, force)
	post_unbuckle_mob(.)


/atom/movable/proc/unbuckle_all_mobs(force = FALSE)
	if(!LAZYLEN(buckled_mobs))
		return
	for(var/buckled_mob in buckled_mobs)
		unbuckle_mob(buckled_mob, force)


//Handle any extras after buckling
//Called on buckle_mob()
/atom/movable/proc/post_buckle_mob(mob/living/buckled_mob)


//same but for unbuckle
/atom/movable/proc/post_unbuckle_mob(mob/living/buckled_mob)


//Wrapper procs that handle sanity and user feedback
/atom/movable/proc/user_buckle_mob(mob/living/buckling_mob, mob/living/user, check_loc = TRUE, silent)
	if(!user.user_can_buckle(buckling_mob))
		return FALSE

	add_fingerprint(user, "buckle")
	var/hands_req = 0
	if(buckle_flags & BUCKLE_NEEDS_HAND)
		hands_req = 1
	else if(buckle_flags & BUCKLE_NEEDS_TWO_HANDS)
		hands_req = 2
	. = buckle_mob(buckling_mob, check_loc = check_loc, target_hands_needed = hands_req)
	if(!.)
		return FALSE
	if(!silent)
		if(buckling_mob == user)
			buckling_mob.visible_message(span_notice("[buckling_mob] buckles [buckling_mob.p_them()]self to [src]."),
				span_notice("You buckle yourself to [src]."),
				span_hear("You hear metal clanking."))
		else
			buckling_mob.visible_message(span_warning("[user] buckles [buckling_mob] to [src]!"),
				span_warning("[user] buckles you to [src]!"),
				span_hear("You hear metal clanking."))
	return TRUE


/atom/movable/proc/user_unbuckle_mob(mob/living/buckled_mob, mob/user, silent)
	var/mob/living/unbuckling_living = unbuckle_mob(buckled_mob)
	if(QDELETED(unbuckling_living))
		return
	if(!silent)
		if(buckled_mob == user)
			buckled_mob.visible_message(
				span_notice("[buckled_mob] unbuckled [buckled_mob.p_them()]self from [src]."),
				span_notice("You unbuckle yourself from [src]."),
				span_notice("You hear metal clanking"))
		else
			var/by_user = user ? " by [user]" : ""
			buckled_mob.visible_message(
				span_notice("[buckled_mob] was unbuckled[by_user]!"),
				span_notice("You were unbuckled from [src][by_user]]."),
				span_notice("You hear metal clanking."))
	add_fingerprint(user, "unbuckle")
	if(isliving(unbuckling_living.pulledby))
		var/mob/living/pulling_living = unbuckling_living.pulledby
		pulling_living.set_pull_offsets(unbuckling_living)
	return unbuckling_living

///Returns TRUE or FALSE depending on whether src can buckle buckling_mob into something
/mob/living/proc/user_can_buckle(mob/living/buckling_mob)
	if(!Adjacent(src, buckling_mob))
		return FALSE
	if(!isturf(loc))
		return FALSE
	if(incapacitated())
		return FALSE
	if(buckling_mob.anchored)
		return FALSE
	return TRUE

/mob/living/carbon/xenomorph/user_can_buckle(mob/living/buckling_mob)
	if(buckling_mob.stat)
		return FALSE
	return ..()
