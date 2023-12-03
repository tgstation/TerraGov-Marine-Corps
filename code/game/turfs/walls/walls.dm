

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

	var/damage_overlay
	var/global/damage_overlays[8]

	var/current_bulletholes = 0
	var/bullethole_increment = 1
	var/bullethole_state = 0
	var/image/bullethole_overlay
	base_icon_state = "metal"

	var/max_temperature = 1800 //K, walls will take damage if they're next to a fire hotter than this

	var/d_state = 0 //Normal walls are now as difficult to remove as reinforced walls

	var/obj/effect/acid_hole/acided_hole //the acid hole inside the wall

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(
		SMOOTH_GROUP_CLOSED_TURFS,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
	)
	canSmoothWith = list(
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_AIRLOCK,
		SMOOTH_GROUP_WINDOW_FRAME,
		SMOOTH_GROUP_WINDOW_FULLTILE,
		SMOOTH_GROUP_SHUTTERS,
		SMOOTH_GROUP_GIRDER,
	)

/turf/closed/wall/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

/turf/closed/wall/Initialize(mapload, ...)
	. = ..()

	if(isnull(wall_integrity))
		wall_integrity = max_integrity

	for(var/obj/item/explosive/mine/M in src)
		if(M)
			visible_message(span_warning("\The [M] is sealed inside the wall as it is built"))
			qdel(M)


/turf/closed/wall/ChangeTurf(newtype)
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
			if(istype(O, /obj/alien/weeds))
				qdel(O)



/turf/closed/wall/MouseDrop_T(mob/M, mob/user)
	if(acided_hole)
		if(M == user && isxeno(user))
			acided_hole.use_wall_hole(user)
			return
	..()


/turf/closed/wall/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return
	if(acided_hole && (X.mob_size == MOB_SIZE_BIG || X.xeno_caste.caste_flags & CASTE_IS_STRONG)) //Strong and/or big xenos can tear open acided walls
		acided_hole.expand_hole(X)
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

#define BULLETHOLE_STATES 10 //How many variations of bullethole patterns there are
#define BULLETHOLE_MAX 8 * 3 //Maximum possible bullet holes.
//Formulas. These don't need to be defines, but helpful green. Should likely reuse these for a base 8 icon system.
#define cur_increment(v) round((v-1)/8)+1
#define base_dir(v,i) v-(i-1)*8
#define cur_dir(v) round(v+round(v)/3)

/turf/closed/wall/update_icon()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	if(wall_integrity == max_integrity) //If the thing was healed for damage; otherwise update_icon() won't run at all, unless it was strictly damaged.
		overlays.Cut()
		damage_overlay = initial(damage_overlay)
		current_bulletholes = initial(current_bulletholes)
		bullethole_increment = initial(current_bulletholes)
		bullethole_state = initial(current_bulletholes)
		qdel(bullethole_overlay)
		bullethole_overlay = null
		return

	var/overlay = round((max_integrity - wall_integrity) / max_integrity * length(damage_overlays)) + 1
	if(overlay > length(damage_overlays)) overlay = length(damage_overlays)

	if(!damage_overlay || overlay != damage_overlay)
		overlays -= damage_overlays[damage_overlay]
		damage_overlay = overlay
		overlays += damage_overlays[damage_overlay]

		if(current_bulletholes > BULLETHOLE_MAX) //Could probably get away with a unique layer, but let's keep it standardized.
			overlays -= bullethole_overlay //We need this to be the top layer, no matter what, but only if the layer is at max bulletholes.
			overlays += bullethole_overlay

	if(current_bulletholes && current_bulletholes <= BULLETHOLE_MAX)
		overlays -= bullethole_overlay
		if(!bullethole_overlay)
			bullethole_state = rand(1, BULLETHOLE_STATES)
			bullethole_overlay = image('icons/effects/bulletholes.dmi', src, "bhole_[bullethole_state]_[bullethole_increment]")
			//for(var/mob/M in view(7)) to_chat(M, bullethole_overlay)
		if(cur_increment(current_bulletholes) > bullethole_increment) bullethole_overlay.icon_state = "bhole_[bullethole_state]_[++bullethole_increment]"

		var/base_direction = base_dir(current_bulletholes,bullethole_increment)
		var/current_direction = cur_dir(base_direction)
		setDir(current_direction)
		/*Hack. Image overlays behave as the parent object, so that means they are also attached to it and follow its directional.
		Luckily, it doesn't matter what direction the walls are set to, they link together via icon_state it seems.
		But I haven't thoroughly tested it.*/
		overlays += bullethole_overlay
		//to_chat(world, span_debuginfo("Increment: <b>[bullethole_increment]</b>, Direction: <b>[current_direction]</b>"))

#undef BULLETHOLE_STATES
#undef BULLETHOLE_MAX
#undef cur_increment
#undef base_dir
#undef cur_dir

/turf/closed/wall/proc/generate_overlays()
	var/alpha_inc = 256 / length(damage_overlays)

	for(var/i = 1; i <= length(damage_overlays); i++)
		var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
		img.blend_mode = BLEND_MULTIPLY
		img.alpha = (i * alpha_inc) - 1
		damage_overlays[i] = img

///Applies damage to the wall
/turf/closed/wall/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", armour_penetration = 0)
	if(resistance_flags & INDESTRUCTIBLE) //Hull is literally invincible
		return

	if(!damage_amount)
		return

	if(damage_flag)
		damage_amount = modify_by_armor(damage_amount, damage_flag, armour_penetration)

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

	else if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
		return

	else if(wall_integrity < max_integrity && iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0, user))
			to_chat(user, span_warning("You need more welding fuel to complete this task."))
			return

		user.visible_message(span_notice("[user] starts repairing the damage to [src]."),
		span_notice("You start repairing the damage to [src]."))
		add_overlay(GLOB.welding_sparks)
		playsound(src, 'sound/items/welder.ogg', 25, 1)
		if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || !iswallturf(src) || !WT?.isOn())
			cut_overlay(GLOB.welding_sparks)
			return

		user.visible_message(span_notice("[user] finishes repairing the damage to [src]."),
		span_notice("You finish repairing the damage to [src]."))
		cut_overlay(GLOB.welding_sparks)
		repair_damage(250, user)

	else
		//DECONSTRUCTION
		switch(d_state)
			if(0)
				if(iswelder(I))
					var/obj/item/tool/weldingtool/WT = I
					playsound(src, 'sound/items/welder.ogg', 25, 1)
					user.visible_message(span_notice("[user] begins slicing through the outer plating."),
					span_notice("You begin slicing through the outer plating."))
					add_overlay(GLOB.welding_sparks)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						cut_overlay(GLOB.welding_sparks)
						return

					if(!iswallturf(src) || !WT?.isOn())
						cut_overlay(GLOB.welding_sparks)
						return

					d_state = 1
					user.visible_message(span_notice("[user] slices through the outer plating."),
					span_notice("You slice through the outer plating."))
					cut_overlay(GLOB.welding_sparks)
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
					add_overlay(GLOB.welding_sparks)
					playsound(src, 'sound/items/welder.ogg', 25, 1)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						cut_overlay(GLOB.welding_sparks)
						return

					if(!iswallturf(src) || !WT?.isOn())
						cut_overlay(GLOB.welding_sparks)
						return

					d_state = 3
					user.visible_message(span_notice("[user] presses firmly on the cover, dislodging it."),
					span_notice("You press firmly on the cover, dislodging it."))
					cut_overlay(GLOB.welding_sparks)
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
					playsound(src, 'sound/items/welder.ogg', 25, 1)
					add_overlay(GLOB.welding_sparks)

					if(!do_after(user, 6 SECONDS, NONE, src, BUSY_ICON_BUILD))
						cut_overlay(GLOB.welding_sparks)
						return

					if(!iswallturf(src) || !WT?.isOn())
						cut_overlay(GLOB.welding_sparks)
						return

					new /obj/item/stack/rods(src)
					user.visible_message(span_notice("The support rods drop out as [user] slices through the final layer."),
					span_notice("The support rods drop out as you slice through the final layer."))
					cut_overlay(GLOB.welding_sparks)
					dismantle_wall()

		return attack_hand(user)

/turf/closed/wall/get_acid_delay()
	return 5 SECONDS

/turf/closed/wall/dissolvability(acid_strength)
	return 0.5
