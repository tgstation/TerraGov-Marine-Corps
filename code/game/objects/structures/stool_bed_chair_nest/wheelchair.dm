
//MAKE ME A OFFICE CHAIR SUBTYPE!!

/obj/structure/bed/chair/wheelchair
	name = "wheelchair"
	desc = "You sit in this. Either by will or force."
	icon_state = "wheelchair"
	anchored = FALSE
	buckle_flags = CAN_BUCKLE
	drag_delay = 1 //pulling something on wheels is easy
	var/bloodiness = 0
	var/move_delay = 6


/obj/structure/bed/chair/wheelchair/relaymove(mob/user, direction)
	if(world.time <= last_move_time + move_delay)
		return
	// Redundant check?
	if(user.incapacitated() || user.lying_angle)
		return

	if(propelled) //can't manually move it mid-propelling.
		return

	if(ishuman(user))
		var/mob/living/carbon/human/driver = user
		var/datum/limb/left_hand = driver.get_limb("l_hand")
		var/datum/limb/right_hand = driver.get_limb("r_hand")
		var/working_hands = 2
		move_delay = initial(move_delay)
		if(!left_hand?.is_usable())
			move_delay += 4 //harder to move a wheelchair with a single hand
			working_hands--
		else if(left_hand.is_broken())
			move_delay++
		if(!right_hand?.is_usable())
			move_delay += 4
			working_hands--
		else if(right_hand.is_broken())
			move_delay += 2
		if(!working_hands)
			return // No hands to drive your chair? Tough luck!
		if(driver.pulling?.drag_delay)	//Dragging stuff can slow you down a bit.
			var/pull_delay = driver.pulling.drag_delay
			if(ismob(driver.pulling))
				var/mob/M = driver.pulling
				if(M.buckled) //if the pulled mob is buckled to an object, we use that object's drag_delay.
					pull_delay = M.buckled.drag_delay
			move_delay += max(driver.pull_speed + pull_delay + 3 * driver.grab_state, 0) //harder grab makes you slower

		if(istype(driver.get_active_held_item(), /obj/item/weapon/gun)) //Wheelchair user has a gun out, so obviously can't move
			return

		if(driver.next_move_slowdown)
			move_delay += driver.next_move_slowdown
			driver.next_move_slowdown = 0

	step(src, direction)


/obj/structure/bed/chair/wheelchair/Moved()
	. = ..()
	if(bloodiness)
		create_track()
	cut_overlays()
	if(LAZYLEN(buckled_mobs))
		handle_rotation_overlayed()


/obj/structure/bed/chair/wheelchair/post_buckle_mob(mob/living/user)
	. = ..()
	handle_rotation_overlayed()

/obj/structure/bed/chair/wheelchair/post_unbuckle_mob()
	. = ..()
	cut_overlays()

/obj/structure/bed/chair/wheelchair/setDir(newdir)
	. = ..()
	handle_rotation(newdir)

/obj/structure/bed/chair/wheelchair/handle_rotation(direction)
	if(LAZYLEN(buckled_mobs))
		handle_rotation_overlayed()
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/structure/bed/chair/wheelchair/proc/handle_rotation_overlayed()
	cut_overlays()
	var/image/V = image(icon = icon, icon_state = "w_overlay", layer = FLY_LAYER, dir = src.dir)
	add_overlay(V)


/obj/structure/bed/chair/wheelchair/Bump(atom/A)
	. = ..()
	if(!LAZYLEN(buckled_mobs))
		return

	if(propelled)
		var/mob/living/occupant = buckled_mobs[1]
		unbuckle_mob(occupant)

		if (propelled)
			occupant.throw_at(A, 3, propelled)

		var/def_zone = ran_zone()
		var/blocked = occupant.get_soft_armor("melee", def_zone)
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, blocked)
		occupant.apply_effect(6, WEAKEN, blocked)
		occupant.apply_effect(6, STUTTER, blocked)
		occupant.apply_damage(10, BRUTE, def_zone)
		UPDATEHEALTH(occupant)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 25, 1)
		if(isliving(A))
			var/mob/living/victim = A
			def_zone = ran_zone()
			blocked = victim.get_soft_armor("melee", def_zone)
			victim.apply_effect(6, STUN, blocked)
			victim.apply_effect(6, WEAKEN, blocked)
			victim.apply_effect(6, STUTTER, blocked)
			victim.apply_damage(10, BRUTE, def_zone)
			UPDATEHEALTH(victim)
		occupant.visible_message(span_danger("[occupant] crashed into \the [A]!"))

/obj/structure/bed/chair/wheelchair/proc/create_track()
	var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
	var/newdir = get_dir(get_step(loc, dir), loc)
	if(newdir == dir)
		B.setDir(newdir)
	else
		newdir = newdir|dir
		if(newdir == 3)
			newdir = 1
		else if(newdir == 12)
			newdir = 4
		B.setDir(newdir)
	bloodiness--
