/obj/structure/stool/bed/chair/wheelchair
	name = "wheelchair"
	desc = "You sit in this. Either by will or force."
	icon_state = "wheelchair"
	anchored = 0
	drag_delay = 0 //pulling something on wheels is easy
	var/bloodiness = 0
	var/move_delay = 4


/obj/structure/stool/bed/chair/wheelchair/handle_rotation()
	overlays.Cut()
	var/image/O = image(icon = 'icons/obj/objects.dmi', icon_state = "w_overlay", layer = FLY_LAYER, dir = src.dir)
	overlays += O
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/stool/bed/chair/wheelchair/relaymove(mob/user, direction)
	if(world.time <= l_move_time + move_delay)
		return
	// Redundant check?
	if(user.stat || user.stunned || user.weakened || user.paralysis || user.lying || user.restrained())
		return

	if(propelled) //can't manually move it mid-propelling.
		return

	if(ishuman(user))
		var/mob/living/carbon/human/driver = user
		var/datum/organ/external/left_hand = driver.get_organ("l_hand")
		var/datum/organ/external/right_hand = driver.get_organ("r_hand")
		var/working_hands = 2
		move_delay = initial(move_delay)
		if(!left_hand || (left_hand.status & ORGAN_DESTROYED))
			move_delay += 4 //harder to move a wheelchair with a single hand
			working_hands--
		else if((left_hand.status & ORGAN_BROKEN) && !(left_hand.status & ORGAN_SPLINTED))
			move_delay++
		if(!right_hand || (right_hand.status & ORGAN_DESTROYED))
			move_delay += 4
			working_hands--
		else if((right_hand.status & ORGAN_BROKEN) && !(right_hand.status & ORGAN_SPLINTED))
			move_delay += 2
		if(!working_hands)
			return // No hands to drive your chair? Tough luck!

	step(src, direction)


/obj/structure/stool/bed/chair/wheelchair/Move()
	. = ..()
	if(. && bloodiness)
		create_track()

/obj/structure/stool/bed/chair/wheelchair/Bump(atom/A)
	..()
	if(!buckled_mob)	return

	if(propelled)
		var/mob/living/occupant = buckled_mob
		unbuckle()

		if (propelled)
			occupant.throw_at(A, 3, propelled)

		var/def_zone = ran_zone()
		var/blocked = occupant.run_armor_check(def_zone, "melee")
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, blocked)
		occupant.apply_effect(6, WEAKEN, blocked)
		occupant.apply_effect(6, STUTTER, blocked)
		occupant.apply_damage(10, BRUTE, def_zone)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			def_zone = ran_zone()
			blocked = victim.run_armor_check(def_zone, "melee")
			victim.apply_effect(6, STUN, blocked)
			victim.apply_effect(6, WEAKEN, blocked)
			victim.apply_effect(6, STUTTER, blocked)
			victim.apply_damage(10, BRUTE, def_zone)
		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/stool/bed/chair/wheelchair/proc/create_track()
	var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
	var/newdir = get_dir(get_step(loc, dir), loc)
	if(newdir == dir)
		B.dir = newdir
	else
		newdir = newdir|dir
		if(newdir == 3)
			newdir = 1
		else if(newdir == 12)
			newdir = 4
		B.dir = newdir
	bloodiness--
