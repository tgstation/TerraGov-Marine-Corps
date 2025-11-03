

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls/regular_wall.dmi'
	icon_state = "metal-0"
	baseturfs = /turf/open/floor/plating
	opacity = TRUE
	explosion_block = 2

	walltype = "metal"

	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	var/wall_integrity
	var/max_integrity = 1000 //Wall will break down to girders if damage reaches this point

	var/global/damage_overlays[8]

	base_icon_state = "metal"

	var/max_temperature = 1800 //K, walls will take damage if they're next to a fire hotter than this

	var/d_state = 0 //Normal walls are now as difficult to remove as reinforced walls

	var/obj/effect/acid_hole/acided_hole //the acid hole inside the wall

	///The current number of bulletholes in this turf
	var/current_bulletholes = 0
	///A reference to the current bullethole overlay image, this is added and deleted as needed
	var/image/bullethole_overlay
	/**
	 * The variation set we're using
	 * There are 10 sets and it gets picked randomly the first time a wall is shot
	 * It corresponds to the first number in the icon_state (bhole_[**bullethole_variation**]_[current_bulletholes])
	 * Gets reset to 0 if the wall reaches maximum health, so a new variation is picked when the wall gets shot again
	 */
	var/bullethole_variation = 0

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(
		SMOOTH_GROUP_CLOSED_TURFS,
		SMOOTH_GROUP_WALLS,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
	)
	canSmoothWith = list(
		SMOOTH_GROUP_WALLS,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_AIRLOCK,
		SMOOTH_GROUP_WINDOW_FRAME,
		SMOOTH_GROUP_WINDOW_FULLTILE,
		SMOOTH_GROUP_SHUTTERS,
		SMOOTH_GROUP_GIRDER,
	)

/turf/closed/wall/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -40, 8, 1)

/turf/closed/wall/Initialize(mapload, ...)
	. = ..()

	if(isnull(wall_integrity))
		wall_integrity = max_integrity

	for(var/obj/item/explosive/mine/M in src)
		if(M)
			visible_message(span_warning("\The [M] is sealed inside the wall as it is built"))
			qdel(M)

/turf/closed/wall/Destroy(force)
	QDEL_NULL(acided_hole)
	QDEL_NULL(bullethole_overlay)
	return ..()

/turf/closed/wall/ChangeTurf(path, list/new_baseturfs, flags)
	if(acided_hole)
		qdel(acided_hole)
		acided_hole = null

	. = ..()
	if(.) //successful turf change

		var/turf/T
		for(var/i in GLOB.cardinals)
			T = get_step(src, i)

			//update junction type of nearby walls
			if(smoothing_flags)
				QUEUE_SMOOTH(T)

			//nearby glowshrooms updated
			for(var/obj/structure/glowshroom/shroom in T)
				if(!shroom.floor) //shrooms drop to the floor
					shroom.floor = 1
					shroom.icon_state = "glowshroomf"
					shroom.pixel_x = 0
					shroom.pixel_y = 0

		for(var/obj/O in src) //Eject contents!
			if(istype(O, /obj/structure/sign/poster))
				var/obj/structure/sign/poster/P = O
				P.roll_and_drop(src)
			if(!(flags & CHANGETURF_KEEP_WEEDS) && istype(O, /obj/alien/weeds))
				qdel(O)



/turf/closed/wall/MouseDrop_T(mob/M, mob/user)
	if(acided_hole)
		if(M == user && isxeno(user))
			acided_hole.use_wall_hole(user)
			return
	..()


/turf/closed/wall/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return
	if(acided_hole && HAS_TRAIT(xeno_attacker, TRAIT_CAN_TEAR_HOLE)) //Strong and/or big xenos can tear open acided walls
		acided_hole.expand_hole(xeno_attacker)
	else
		return ..()




//Appearance
/turf/closed/wall/examine(mob/user)
	. = ..()

	if(wall_integrity == max_integrity)
		if (acided_hole)
			. += span_warning("It looks fully intact, except there's a large hole that could've been caused by some sort of acid.")
		else
			. += span_notice("It looks fully intact.")
	else
		var/integ = wall_integrity / max_integrity
		if(integ >= 0.6)
			. += span_warning("It looks slightly damaged.")
		else if(integ >= 0.3)
			. += span_warning("It looks moderately damaged.")
		else
			. += span_danger("It looks heavily damaged.")

		if (acided_hole)
			. += span_warning("There's a large hole in the wall that could've been caused by some sort of acid.")

	// todo why does this not use defines?
	switch(d_state)
		if(1)
			. += span_info("The outer plating has been sliced open. A screwdriver should remove the support lines.")
		if(2)
			. += span_info("The support lines have been removed. A blowtorch should slice through the metal cover.")
		if(3)
			. += span_info("The metal cover has been sliced through. A crowbar should pry it off.")
		if(4)
			. += span_info("The metal cover has been removed. A wrench will remove the anchor bolts.")
		if(5)
			. += span_info("The anchor bolts have been removed. Wirecutters will take care of the hydraulic lines.")
		if(6)
			. += span_info("Hydraulic lines are gone. A crowbar will pry off the inner sheath.")
		if(7)
			. += span_info("The inner sheath is gone. A blowtorch should finish off this wall.")

/turf/closed/wall/update_overlays()
	. = ..()
	if(wall_integrity == max_integrity)
		current_bulletholes = 0
		bullethole_variation = 0
		QDEL_NULL(bullethole_overlay)
		return

	if(!damage_overlays[1]) //list hasn't been populated
		var/alpha_inc = 256 / length(damage_overlays)

		for(var/i = 1; i <= length(damage_overlays); i++)
			var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
			img.blend_mode = BLEND_MULTIPLY
			img.alpha = (i * alpha_inc) - 1
			damage_overlays[i] = img

	var/overlay = round((max_integrity - wall_integrity) / max_integrity * length(damage_overlays)) + 1
	if(overlay > length(damage_overlays))
		overlay = length(damage_overlays)

	. += damage_overlays[overlay]

	if(current_bulletholes && current_bulletholes <= BULLETHOLE_MAX)
		if(!bullethole_variation)
			bullethole_variation = rand(1, BULLETHOLE_STATES)
		bullethole_overlay = image('icons/effects/bulletholes.dmi', src, "bhole_[bullethole_variation]_[current_bulletholes]")
	. += bullethole_overlay

/turf/closed/wall/do_acid_melt()
	. = ..()
	if(acided_hole)
		ScrapeAway()
		return
	new /obj/effect/acid_hole(src)

///Applies damage to the wall
/turf/closed/wall/proc/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, armour_penetration = 0)
	if(resistance_flags & INDESTRUCTIBLE) //Hull is literally invincible
		return

	if(!damage_amount)
		return

	if(armor_type)
		damage_amount = modify_by_armor(damage_amount, armor_type, armour_penetration)

	wall_integrity = max(0, wall_integrity - damage_amount)

	if(wall_integrity <= 0)
		// Xenos used to be able to crawl through the wall, should suggest some structural damage to the girder
		if (acided_hole)
			dismantle_wall(1)
		else
			dismantle_wall()
	else
		update_icon()

///Repairs the wall by an amount
/turf/closed/wall/proc/repair_damage(repair_amount, mob/user)
	if(resistance_flags & INDESTRUCTIBLE) //Hull is literally invincible
		return

	if(!repair_amount)
		return

	repair_amount = min(repair_amount, max_integrity - wall_integrity)
	if(user?.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.integrity_repaired += repair_amount
		personal_statistics.mission_integrity_repaired += repair_amount
		personal_statistics.times_repaired++
	wall_integrity += repair_amount
	update_icon()


/turf/closed/wall/proc/make_girder(destroyed_girder = FALSE)
	var/obj/structure/girder/G = new /obj/structure/girder(src)
	G.update_icon()

	if(destroyed_girder)
		G.deconstruct(FALSE)



// Devastated and Explode causes the wall to spawn a damaged girder
// Walls no longer spawn a metal sheet when destroyed to reduce clutter and
// improve visual readability.
/turf/closed/wall/proc/dismantle_wall(devastated = 0, explode = 0)
	if(resistance_flags & INDESTRUCTIBLE) //Hull is literally invincible
		return
	if(devastated)
		make_girder(TRUE)
	else if(explode)
		make_girder(TRUE)
	else
		make_girder(FALSE)

	ScrapeAway()


/turf/closed/wall/ex_act(severity)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			dismantle_wall(FALSE, TRUE)
		if(EXPLODE_HEAVY)
			if(prob(75))
				take_damage(rand(150, 250), BRUTE, BOMB)
			else
				dismantle_wall(TRUE, TRUE)
		if(EXPLODE_LIGHT)
			take_damage(rand(0, 250), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(0, 50), BRUTE, BOMB)

/turf/closed/wall/attack_animal(mob/living/M as mob)
	if(M.wall_smash)
		if((isrwallturf(src)) || (resistance_flags & INDESTRUCTIBLE))
			to_chat(M, span_warning("This [name] is far too strong for you to destroy."))
			return
		else
			if((prob(40)))
				M.visible_message(span_danger("[M] smashes through [src]."),
				span_danger("You smash through the wall."))
				dismantle_wall(1)
				return
			else
				M.visible_message(span_warning("[M] smashes against [src]."),
				span_warning("You smash against the wall."))
				take_damage(rand(25, 75))
				return


/turf/closed/wall/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	else if(istype(I, /obj/item/frame/apc))
		var/obj/item/frame/apc/AH = I
		AH.try_build(src, user)

	else if(istype(I, /obj/item/frame/fire_alarm))
		var/obj/item/frame/fire_alarm/AH = I
		AH.try_build(src, user)

	else if(istype(I, /obj/item/frame/light_fixture))
		var/obj/item/frame/light_fixture/AH = I
		AH.try_build(src, user)

	else if(istype(I, /obj/item/frame/light_fixture/small))
		var/obj/item/frame/light_fixture/small/AH = I
		AH.try_build(src, user)

	else if(istype(I, /obj/item/frame/camera))
		var/obj/item/frame/camera/AH = I
		AH.try_build(src, user)

	//Poster stuff
	else if(istype(I, /obj/item/contraband/poster))
		place_poster(I, user)

	else if(resistance_flags & INDESTRUCTIBLE)
		to_chat(user, "[span_warning("[src] is much too tough for you to do anything to it with [I]")].")

	else if(isplasmacutter(I) && !user.do_actions)
		return

	else if(wall_integrity < max_integrity && iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0, user))
			to_chat(user, span_warning("You need more welding fuel to complete this task."))
			return

		user.visible_message(span_notice("[user] starts repairing the damage to [src]."),
		span_notice("You start repairing the damage to [src]."))
		if(!I.use_tool(src, user, 5 SECONDS, 1, 25, null, BUSY_ICON_FRIENDLY)|| !iswallturf(src))
			return

		user.visible_message(span_notice("[user] finishes repairing the damage to [src]."),
		span_notice("You finish repairing the damage to [src]."))
		repair_damage(250, user)

	else
		//DECONSTRUCTION
		switch(d_state)
			if(0)
				if(iswelder(I))
					var/obj/item/tool/weldingtool/WT = I
					user.visible_message(span_notice("[user] begins slicing through the outer plating."),
					span_notice("You begin slicing through the outer plating."))
					if(!I.use_tool(src, user, 6 SECONDS, 1, 25, null, BUSY_ICON_BUILD))
						return
					if(!iswallturf(src) || !WT?.isOn())
						return

					d_state = 1
					user.visible_message(span_notice("[user] slices through the outer plating."),
					span_notice("You slice through the outer plating."))
			if(1)
				if(isscrewdriver(I))
					user.visible_message(span_notice("[user] begins removing the support lines."),
					span_notice("You begin removing the support lines."))
					playsound(src, 'sound/items/screwdriver.ogg', 25, 1)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						return

					if(!iswallturf(src))
						return

					d_state = 2
					user.visible_message(span_notice("[user] removes the support lines."),
					span_notice("You remove the support lines."))
			if(2)
				if(iswelder(I))
					var/obj/item/tool/weldingtool/WT = I
					user.visible_message(span_notice("[user] begins slicing through the metal cover."),
					span_notice("You begin slicing through the metal cover."))

					if(!I.use_tool(src, user, 6 SECONDS, 1, 25, null, BUSY_ICON_BUILD))
						return

					if(!iswallturf(src) || !WT?.isOn())
						return

					d_state = 3
					user.visible_message(span_notice("[user] presses firmly on the cover, dislodging it."),
					span_notice("You press firmly on the cover, dislodging it."))
			if(3)
				if(iscrowbar(I))
					user.visible_message(span_notice("[user] struggles to pry off the cover."),
					span_notice("You struggle to pry off the cover."))
					playsound(src, 'sound/items/crowbar.ogg', 25, 1)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						return

					if(!iswallturf(src))
						return

					d_state = 4
					user.visible_message(span_notice("[user] pries off the cover."),
					span_notice("You pry off the cover."))
			if(4)
				if(iswrench(I))
					user.visible_message(span_notice("[user] starts loosening the anchoring bolts securing the support rods."),
					span_notice("You start loosening the anchoring bolts securing the support rods."))
					playsound(src, 'sound/items/ratchet.ogg', 25, 1)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						return

					if(!iswallturf(src))
						return

					d_state = 5
					user.visible_message(span_notice("[user] removes the bolts anchoring the support rods."),
					span_notice("You remove the bolts anchoring the support rods."))
			if(5)
				if(iswirecutter(I))
					user.visible_message(span_notice("[user] begins uncrimping the hydraulic lines."),
					span_notice("You begin uncrimping the hydraulic lines."))
					playsound(src, 'sound/items/wirecutter.ogg', 25, 1)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						return

					if(!iswallturf(src))
						return

					d_state = 6
					user.visible_message(span_notice("[user] finishes uncrimping the hydraulic lines."),
					span_notice("You finish uncrimping the hydraulic lines."))
			if(6)
				if(iscrowbar(I))
					user.visible_message(span_notice("[user] struggles to pry off the inner sheath."),
					span_notice("You struggle to pry off the inner sheath."))
					playsound(src, 'sound/items/crowbar.ogg', 25, 1)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						return

					if(!iswallturf(src))
						return

					d_state = 7
					user.visible_message(span_notice("[user] pries off the inner sheath."),
					span_notice("You pry off the inner sheath."))
			if(7)
				if(iswelder(I))
					var/obj/item/tool/weldingtool/WT = I
					user.visible_message(span_notice("[user] begins slicing through the final layer."),
					span_notice("You begin slicing through the final layer."))

					if(!I.use_tool(src, user, 6 SECONDS, 1, 25, null, BUSY_ICON_BUILD))
						return

					if(!iswallturf(src) || !WT?.isOn())
						return

					new /obj/item/stack/rods(src)
					user.visible_message(span_notice("The support rods drop out as [user] slices through the final layer."),
					span_notice("The support rods drop out as you slice through the final layer."))
					dismantle_wall()

		return attack_hand(user)

/turf/closed/wall/get_acid_delay()
	return 5 SECONDS

/turf/closed/wall/dissolvability(acid_strength)
	return 0.5

/turf/closed/wall/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_WALL_SLAM_DAMAGE, is_sharp = FALSE)
	if(!isliving(grab.grabbed_thing))
		return

	var/mob/living/grabbed_mob = grab.grabbed_thing
	step_towards(grabbed_mob, src)
	var/damage = (user.skills.getRating(SKILL_UNARMED) * UNARMED_SKILL_DAMAGE_MOD)
	var/state = user.grab_state
	switch(state)
		if(GRAB_PASSIVE)
			damage += base_damage
			grabbed_mob.visible_message(span_warning("[user] slams [grabbed_mob] against [src]!"))
			log_combat(user, grabbed_mob, "slammed", "", "against [src]")
		if(GRAB_AGGRESSIVE)
			damage += base_damage * 1.5
			grabbed_mob.visible_message(span_danger("[user] bashes [grabbed_mob] against [src]!"))
			log_combat(user, grabbed_mob, "bashed", "", "against [src]")
			if(prob(50))
				grabbed_mob.Paralyze(2 SECONDS)
				user.drop_held_item()
		if(GRAB_NECK)
			damage += base_damage * 2
			grabbed_mob.visible_message(span_danger("<big>[user] crushes [grabbed_mob] against [src]!</big>"))
			log_combat(user, grabbed_mob, "crushed", "", "against [src]")
			grabbed_mob.Paralyze(2 SECONDS)
			user.drop_held_item()
	grabbed_mob.apply_damage(damage, blocked = MELEE, updating_health = TRUE, attacker = user)
	take_damage(damage, BRUTE, MELEE)
	playsound(src, SFX_SLAM, 40)
	return TRUE
