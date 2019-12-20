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

//procs that handle the actual buckling and unbuckling
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
				to_chat(buckling_mob, "<span class='warning'>You are unable to buckle yourself to [src]!</span>")
			else
				to_chat(usr, "<span class='warning'>You are unable to buckle [buckling_mob] to [src]!</span>")
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent) & COMPONENT_MOVABLE_BUCKLE_STOPPED)
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
	buckling_mob.update_canmove()
	buckling_mob.throw_alert("buckled", /obj/screen/alert/restrained/buckled)
	post_buckle_mob(buckling_mob, silent)

	RegisterSignal(buckling_mob, COMSIG_LIVING_DO_RESIST, .proc/resisted_against)
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
	buckled_mob.update_canmove()
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
/atom/movable/proc/user_buckle_mob(mob/living/buckling_mob, mob/user, check_loc = TRUE, silent)
	if(!Adjacent(user, src) || !isturf(user.loc) || user.incapacitated() || buckling_mob.anchored)
		return FALSE

	add_fingerprint(user, "buckle")
	. = buckle_mob(buckling_mob, check_loc = check_loc)
	if(!.)
		return FALSE
	if(!silent)
		if(buckling_mob == user)
			buckling_mob.visible_message("<span class='notice'>[buckling_mob] buckles [buckling_mob.p_them()]self to [src].</span>",
				"<span class='notice'>You buckle yourself to [src].</span>",
				"<span class='hear'>You hear metal clanking.</span>")
		else
			buckling_mob.visible_message("<span class='warning'>[user] buckles [buckling_mob] to [src]!</span>",
				"<span class='warning'>[user] buckles you to [src]!</span>",
				"<span class='hear'>You hear metal clanking.</span>")
	return TRUE


/atom/movable/proc/user_unbuckle_mob(mob/living/buckled_mob, mob/user, silent)
	var/mob/living/unbuckling_living = unbuckle_mob(buckled_mob)
	if(QDELETED(unbuckling_living))
		return
	if(!silent)
		if(buckled_mob == user)
			buckled_mob.visible_message(
				"<span class='notice'>[buckled_mob] unbuckled [buckled_mob.p_them()]self from [src].</span>",
				"<span class='notice'>You unbuckle yourself from [src].</span>",
				"<span class='notice'>You hear metal clanking</span>")
		else
			var/by_user = user ? " by [user]" : ""
			buckled_mob.visible_message(
				"<span class='notice'>[buckled_mob] was unbuckled[by_user]!</span>",
				"<span class='notice'>You were unbuckled from [src][by_user]].</span>",
				"<span class='notice'>You hear metal clanking.</span>")
	add_fingerprint(user, "unbuckle")
	if(isliving(unbuckling_living.pulledby))
		var/mob/living/pulling_living = unbuckling_living.pulledby
		pulling_living.set_pull_offsets(unbuckling_living)
	return unbuckling_living
