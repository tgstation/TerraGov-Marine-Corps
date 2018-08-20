

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	icon_state = "0"
	opacity = 1
	var/hull = 0 //1 = Can't be deconstructed by tools or thermite. Used for Sulaco walls
	var/walltype = "metal"
	var/junctiontype //when walls smooth with one another, the type of junction each wall is.
	var/thermite = 0

	tiles_with = list(
		/turf/closed/wall,
		/obj/structure/window/framed,
		/obj/structure/window_frame,
		/obj/structure/girder,
		/obj/machinery/door)

	var/damage = 0
	var/damage_cap = 1000 //Wall will break down to girders if damage reaches this point

	var/damage_overlay
	var/global/damage_overlays[8]

	var/current_bulletholes = 0
	var/bullethole_increment = 1
	var/bullethole_state = 0
	var/image/reusable/bullethole_overlay

	var/max_temperature = 1800 //K, walls will take damage if they're next to a fire hotter than this

	var/d_state = 0 //Normal walls are now as difficult to remove as reinforced walls

	var/obj/effect/acid_hole/acided_hole //the acid hole inside the wall



/turf/closed/wall/New()
	..()
	//smooth wall stuff
	relativewall()
	relativewall_neighbours()

	for(var/obj/item/explosive/mine/M in src)
		if(M)
			visible_message("<span class='warning'>\The [M] is sealed inside the wall as it is built</span>")
			cdel(M)


/turf/closed/wall/ChangeTurf(newtype)
	if(acided_hole)
		cdel(acided_hole)
		acided_hole = null

	. = ..()
	if(.) //successful turf change

		var/turf/T
		for(var/i in cardinal)
			T = get_step(src, i)

			//update junction type of nearby walls
			if(istype(T, /turf/closed/wall))
				T.relativewall()

			//nearby glowshrooms updated
			for(var/obj/effect/glowshroom/shroom in T)
				if(!shroom.floor) //shrooms drop to the floor
					shroom.floor = 1
					shroom.icon_state = "glowshroomf"
					shroom.pixel_x = 0
					shroom.pixel_y = 0

		for(var/obj/O in src) //Eject contents!
			if(istype(O, /obj/structure/sign/poster))
				var/obj/structure/sign/poster/P = O
				P.roll_and_drop(src)
			if(istype(O, /obj/effect/alien/weeds))
				cdel(O)



/turf/closed/wall/MouseDrop_T(mob/M, mob/user)
	if(acided_hole)
		if(M == user && isXeno(user))
			acided_hole.use_wall_hole(user)
			return
	..()


/turf/closed/wall/attack_alien(mob/living/carbon/Xenomorph/user)
	if(acided_hole && user.mob_size == MOB_SIZE_BIG)
		acided_hole.expand_hole(user)
	else
		. = ..()




//Appearance
/turf/closed/wall/examine(mob/user)
	. = ..()

	if(!damage)
		if (acided_hole)
			to_chat(user, "<span class='warning'>It looks fully intact, except there's a large hole that could've been caused by some sort of acid.</span>")
		else
			to_chat(user, "<span class='notice'>It looks fully intact.</span>")
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			to_chat(user, "<span class='warning'>It looks slightly damaged.</span>")
		else if(dam <= 0.6)
			to_chat(user, "<span class='warning'>It looks moderately damaged.</span>")
		else
			to_chat(user, "<span class='danger'>It looks heavily damaged.</span>")

		if (acided_hole)
			to_chat(user, "<span class='warning'>There's a large hole in the wall that could've been caused by some sort of acid.</span>")

	switch(d_state)
		if(1)
			to_chat(user, "<span class='info'>The outer plating has been sliced open. A screwdriver should remove the support lines.</span>")
		if(2)
			to_chat(user, "<span class='info'>The support lines have been removed. A blowtorch should slice through the metal cover.</span>")
		if(3)
			to_chat(user, "<span class='info'>The metal cover has been sliced through. A crowbar should pry it off.</span>")
		if(4)
			to_chat(user, "<span class='info'>The metal cover has been removed. A wrench will remove the anchor bolts.</span>")
		if(5)
			to_chat(user, "<span class='info'>The anchor bolts have been removed. Wirecutters will take care of the hydraulic lines.</span>")
		if(6)
			to_chat(user, "<span class='info'>Hydraulic lines are gone. A crowbar will pry off the inner sheath.</span>")
		if(7)
			to_chat(user, "<span class='info'>The inner sheath is gone. A blowtorch should finish off this wall.</span>")

#define BULLETHOLE_STATES 10 //How many variations of bullethole patterns there are
#define BULLETHOLE_MAX 8 * 3 //Maximum possible bullet holes.
//Formulas. These don't need to be defines, but helpful green. Should likely reuse these for a base 8 icon system.
#define cur_increment(v) round((v-1)/8)+1
#define base_dir(v,i) v-(i-1)*8
#define cur_dir(v) round(v+round(v)/3)

/turf/closed/wall/update_icon()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	if(!damage) //If the thing was healed for damage; otherwise update_icon() won't run at all, unless it was strictly damaged.
		overlays.Cut()
		damage_overlay = initial(damage_overlay)
		current_bulletholes = initial(current_bulletholes)
		bullethole_increment = initial(current_bulletholes)
		bullethole_state = initial(current_bulletholes)
		cdel(bullethole_overlay)
		bullethole_overlay = null
		return

	var/overlay = round(damage / damage_cap * damage_overlays.len) + 1
	if(overlay > damage_overlays.len) overlay = damage_overlays.len

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
			bullethole_overlay = rnew(/image/reusable, list('icons/effects/bulletholes.dmi', src, "bhole_[bullethole_state]_[bullethole_increment]"))
			//for(var/mob/M in view(7)) to_chat(M, bullethole_overlay)
		if(cur_increment(current_bulletholes) > bullethole_increment) bullethole_overlay.icon_state = "bhole_[bullethole_state]_[++bullethole_increment]"

		var/base_direction = base_dir(current_bulletholes,bullethole_increment)
		var/current_direction = cur_dir(base_direction)
		dir = current_direction
		/*Hack. Image overlays behave as the parent object, so that means they are also attached to it and follow its directional.
		Luckily, it doesn't matter what direction the walls are set to, they link together via icon_state it seems.
		But I haven't thoroughly tested it.*/
		overlays += bullethole_overlay
		//to_chat(world, "<span class='debuginfo'>Increment: <b>[bullethole_increment]</b>, Direction: <b>[current_direction]</b></span>")

#undef BULLETHOLE_STATES
#undef BULLETHOLE_MAX
#undef cur_increment
#undef base_dir
#undef cur_dir

/turf/closed/wall/proc/generate_overlays()
	var/alpha_inc = 256 / damage_overlays.len

	for(var/i = 1; i <= damage_overlays.len; i++)
		var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
		img.blend_mode = BLEND_MULTIPLY
		img.alpha = (i * alpha_inc) - 1
		damage_overlays[i] = img

//Damage
/turf/closed/wall/proc/take_damage(dam)
	if(hull) //Hull is literally invincible
		return
	if(!dam)
		return

	damage = max(0, damage + dam)

	if(damage >= damage_cap)
		// Xenos used to be able to crawl through the wall, should suggest some structural damage to the girder
		if (acided_hole)
			dismantle_wall(1)
		else
			dismantle_wall()
	else
		update_icon()


/turf/closed/wall/proc/make_girder(destroyed_girder = FALSE)
	var/obj/structure/girder/G = new /obj/structure/girder(src)
	G.icon_state = "girder[junctiontype]"
	G.original = src.type

	if (destroyed_girder)
		G.dismantle()



// Devastated and Explode causes the wall to spawn a damaged girder
// Walls no longer spawn a metal sheet when destroyed to reduce clutter and
// improve visual readability.
/turf/closed/wall/proc/dismantle_wall(devastated = 0, explode = 0)
	if(hull) //Hull is literally invincible
		return
	if(devastated)
		make_girder(TRUE)
	else if (explode)
		make_girder(TRUE)
	else
		make_girder(FALSE)

	cdel(src)

/turf/closed/wall/ex_act(severity)
	if(hull)
		return
	switch(severity)
		if(1)
			dismantle_wall(0, 1)
		if(2)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1, 1)
		if(3)
			take_damage(rand(0, 250))

/turf/closed/wall/proc/thermitemelt(mob/user)
	if(hull)
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay(src)
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = FLY_LAYER

	to_chat(user, "<span class='warning'>The thermite starts melting through [src].</span>")
	spawn(50)
		dismantle_wall()

	spawn(50)
		if(O) cdel(O)
	return


//Interactions
/turf/closed/wall/attack_paw(mob/user as mob)
	if((HULK in user.mutations))
		if(prob(40))
			user.visible_message("<span class='danger'>[user] smashes through [src].</span>",
			"<span class='danger'>You smash through the wall.</span>")
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
			dismantle_wall(1)
			return
		else
			user.visible_message("<span class='warning'>[user] punches [src].</span>",
			"<span class='warning'>You punch the wall.</span>")
			take_damage(rand(25, 75))
			return

	return attack_hand(user)


/turf/closed/wall/attack_animal(mob/living/M as mob)
	if(M.wall_smash)
		if((istype(src, /turf/closed/wall/r_wall)) || hull)
			to_chat(M, "<span class='warning'>This [name] is far too strong for you to destroy.</span>")
			return
		else
			if((prob(40)))
				M.visible_message("<span class='danger'>[M] smashes through [src].</span>",
				"<span class='danger'>You smash through the wall.</span>")
				dismantle_wall(1)
				return
			else
				M.visible_message("<span class='warning'>[M] smashes against [src].</span>",
				"<span class='warning'>You smash against the wall.</span>")
				take_damage(rand(25, 75))
				return

/turf/closed/wall/attack_hand(mob/user as mob)
	if(HULK in user.mutations)
		if((prob(40)) && !hull)
			user.visible_message("<span class='danger'>[user] smashes through [src].</span>",
			"<span class='danger'>You smash through [src].</span>")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
			dismantle_wall(1)
			return
		else
			user.visible_message("<span class='warning'>[user] punches [src].</span>",
			"<span class='warning'>You punch [src].</span>")
			take_damage(rand(25, 75))
			return

	add_fingerprint(user)



/turf/closed/wall/attackby(obj/item/W, mob/user)

	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(W.heat_source >= 1000)
			if(hull)
				to_chat(user, "<span class='warning'>[src] is much too tough for you to do anything to it with [W]</span>.")
			else
				if(istype(W, /obj/item/tool/weldingtool))
					var/obj/item/tool/weldingtool/WT = W
					WT.remove_fuel(0,user)
				thermitemelt(user)
			return

	if(istype(W,/obj/item/frame/apc))
		var/obj/item/frame/apc/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/frame/air_alarm))
		var/obj/item/frame/air_alarm/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/frame/fire_alarm))
		var/obj/item/frame/fire_alarm/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/frame/light_fixture))
		var/obj/item/frame/light_fixture/AH = W
		AH.try_build(src)
		return

	if(istype(W,/obj/item/frame/light_fixture/small))
		var/obj/item/frame/light_fixture/small/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	if(istype(W,/obj/item/contraband/poster))
		place_poster(W,user)
		return

	if(hull)
		to_chat(user, "<span class='warning'>[src] is much too tough for you to do anything to it with [W]</span>.")
		return

	if(damage && istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			user.visible_message("<span class='notice'>[user] starts repairing the damage to [src].</span>",
			"<span class='notice'>You start repairing the damage to [src].</span>")
			playsound(src, 'sound/items/Welder.ogg', 25, 1)
			if(do_after(user, max(5, round(damage / 5)), TRUE, 5, BUSY_ICON_FRIENDLY) && istype(src, /turf/closed/wall) && WT && WT.isOn())
				user.visible_message("<span class='notice'>[user] finishes repairing the damage to [src].</span>",
				"<span class='notice'>You finish repairing the damage to [src].</span>")
				take_damage(-damage)
			return
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return

	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if(istype(W, /obj/item/tool/weldingtool))

				var/obj/item/tool/weldingtool/WT = W
				playsound(src, 'sound/items/Welder.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] begins slicing through the outer plating.</span>",
				"<span class='notice'>You begin slicing through the outer plating.</span>")

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall) || !WT || !WT.isOn())	return

					if(!d_state)
						d_state++
						user.visible_message("<span class='notice'>[user] slices through the outer plating.</span>",
						"<span class='notice'>You slice through the outer plating.</span>")
				return

		if(1)
			if(istype(W, /obj/item/tool/screwdriver))

				user.visible_message("<span class='notice'>[user] begins removing the support lines.</span>",
				"<span class='notice'>You begin removing the support lines.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall)) return

					if(d_state == 1)
						d_state++
						user.visible_message("<span class='notice'>[user] removes the support lines.</span>",
						"<span class='notice'>You remove the support lines.</span>")
				return

		if(2)
			if(istype(W, /obj/item/tool/weldingtool))

				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] begins slicing through the metal cover.</span>",
				"<span class='notice'>You begin slicing through the metal cover.</span>")
				playsound(src, 'sound/items/Welder.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall) || !WT || !WT.isOn())	return

					if(d_state == 2)
						d_state++
						user.visible_message("<span class='notice'>[user] presses firmly on the cover, dislodging it.</span>",
						"<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return

		if(3)
			if(istype(W, /obj/item/tool/crowbar))

				user.visible_message("<span class='notice'>[user] struggles to pry off the cover.</span>",
				"<span class='notice'>You struggle to pry off the cover.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall)) return

					if(d_state == 3)
						d_state++
						user.visible_message("<span class='notice'>[user] pries off the cover.</span>",
						"<span class='notice'>You pry off the cover.</span>")
				return

		if(4)
			if(istype(W, /obj/item/tool/wrench))

				user.visible_message("<span class='notice'>[user] starts loosening the anchoring bolts securing the support rods.</span>",
				"<span class='notice'>You start loosening the anchoring bolts securing the support rods.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall)) return

					if(d_state == 4)
						d_state++
						user.visible_message("<span class='notice'>[user] removes the bolts anchoring the support rods.</span>",
						"<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return

		if(5)
			if(istype(W, /obj/item/tool/wirecutters))

				user.visible_message("<span class='notice'>[user] begins uncrimping the hydraulic lines.</span>",
				"<span class='notice'>You begin uncrimping the hydraulic lines.</span>")
				playsound(src, 'sound/items/Wirecutter.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall)) return

					if(d_state == 5)
						d_state++
						user.visible_message("<span class='notice'>[user] finishes uncrimping the hydraulic lines.</span>",
						"<span class='notice'>You finish uncrimping the hydraulic lines.</span>")
				return

		if(6)
			if(istype(W, /obj/item/tool/crowbar))

				user.visible_message("<span class='notice'>[user] struggles to pry off the inner sheath.</span>",
				"<span class='notice'>You struggle to pry off the inner sheath.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall)) return

					if(d_state == 6)
						d_state++
						user.visible_message("<span class='notice'>[user] pries off the inner sheath.</span>",
						"<span class='notice'>You pry off the inner sheath.</span>")
				return

		if(7)
			if(istype(W, /obj/item/tool/weldingtool))

				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] begins slicing through the final layer.</span>",
				"<span class='notice'>You begin slicing through the final layer.</span>")
				playsound(src, 'sound/items/Welder.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!istype(src, /turf/closed/wall) || !WT || !WT.isOn())	return

					if(d_state == 7)
						new /obj/item/stack/rods(src)
						user.visible_message("<span class='notice'>The support rods drop out as [user] slices through the final layer.</span>",
						"<span class='notice'>The support rods drop out as you slice through the final layer.</span>")
						dismantle_wall()
				return

	return attack_hand(user)

/turf/closed/wall/can_be_dissolved()
	return !hull
