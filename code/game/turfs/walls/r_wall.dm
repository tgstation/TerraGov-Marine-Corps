/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "rwall"
	opacity = 1
	density = 1

	damage_cap = 3000
	max_temperature = 6000

	walltype = "rwall"

/turf/closed/wall/r_wall/attack_hand(mob/user)
	if (HULK in user.mutations)
		if (prob(10))
			to_chat(usr, text("<span class='notice'> You smash through the wall.</span>"))
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle_wall(1)
			return
		else
			to_chat(user, "<span class='notice'>You punch the wall.</span>")
			return

	add_fingerprint(user)

/turf/closed/wall/r_wall/attackby(obj/item/W, mob/user)
	if(hull)
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting walls and the relevant effects
	if(thermite)
		if(W.heat_source >= 1000)
			if(hull)
				to_chat(user, "<span class='warning'>[src] is much too tough for you to do anything to it with [W]</span>.")
			else
				if(iswelder(W))
					var/obj/item/tool/weldingtool/WT = W
					WT.remove_fuel(0,user)
				thermitemelt(user)
			return

	if(istype(W, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy)
		var/obj/item/tool/pickaxe/plasmacutter/P = W
		if(!P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_HIGH_MOD))
			return
		if(do_after(user, P.calc_delay(user) * PLASMACUTTER_HIGH_MOD, TRUE, 5, BUSY_ICON_HOSTILE) && P) //Reinforced walls take several times as long as regulars.
			P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_HIGH_MOD)
			dismantle_wall()
		return

	if(damage && iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You start repairing the damage to [src].</span>")
			playsound(src, 'sound/items/Welder.ogg', 25, 1)
			if(do_after(user, max(5, damage / 5, TRUE, 5, BUSY_ICON_FRIENDLY)) && WT && WT.isOn())
				to_chat(user, "<span class='notice'>You finish repairing the damage to [src].</span>")
				take_damage(-damage)
			return
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return


	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if (iswirecutter(W))
				playsound(src, 'sound/items/Wirecutter.ogg', 25, 1)
				src.d_state = 1
				new /obj/item/stack/rods( src )
				to_chat(user, "<span class='notice'>You cut the outer grille.</span>")
				return

		if(1)
			if (isscrewdriver(W))
				to_chat(user, "<span class='notice'>You begin removing the support lines.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', 25, 1)

				if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
					if(!isrwallturf(src))
						return

					if(d_state == 1)
						d_state = 2
						to_chat(user, "<span class='notice'>You remove the support lines.</span>")
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if( istype(W, /obj/item/stack/rods) )
				var/obj/item/stack/O = W
				d_state = 0
				to_chat(user, "<span class='notice'>You replace the outer grille.</span>")
				if (O.amount > 1)
					O.amount--
				else
					qdel(O)
				return

		if(2)
			if(iswelder(W))
				var/obj/item/tool/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					to_chat(user, "<span class='notice'>You begin slicing through the metal cover.</span>")
					playsound(src, 'sound/items/Welder.ogg', 25, 1)

					if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
						if(!isrwallturf(src) || !WT || !WT.isOn())
							return


						if( d_state == 2)
							d_state = 3
							to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return

			if( istype(W, /obj/item/tool/pickaxe/plasmacutter) )

				to_chat(user, "<span class='notice'>You begin slicing through the metal cover.</span>")
				playsound(src, 'sound/items/Welder.ogg', 25, 1)

				if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
					if(!isrwallturf(src))
						return

					if(d_state == 2 )
						d_state = 3
						to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return

		if(3)
			if (iscrowbar(W))

				to_chat(user, "<span class='notice'>You struggle to pry off the cover.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 25, 1)

				if(do_after(user, 100, TRUE, 5, BUSY_ICON_BUILD))
					if(!isrwallturf(src))
						return
					if(d_state == 3 )
						d_state = 4
						to_chat(user, "<span class='notice'>You pry off the cover.</span>")
				return

		if(4)
			if (iswrench(W))

				to_chat(user, "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 25, 1)

				if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
					if(!isrwallturf(src))
						return

					if(d_state == 4)
						d_state = 5
						to_chat(user, "<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return

		if(5)
			if(iswirecutter(W))

				user.visible_message("<span class='notice'>[user] begins uncrimping the hydraulic lines.</span>",
				"<span class='notice'>You begin uncrimping the hydraulic lines.</span>")
				playsound(src, 'sound/items/Wirecutter.ogg', 25, 1)

				if(do_after(user, 60, TRUE, 5, BUSY_ICON_BUILD))
					if(!isrwallturf(src))
						return

					if(d_state == 5)
						d_state++
						user.visible_message("<span class='notice'>[user] finishes uncrimping the hydraulic lines.</span>",
						"<span class='notice'>You finish uncrimping the hydraulic lines.</span>")
				return

		if(6)
			if(iscrowbar(W))

				to_chat(user, "<span class='notice'>You struggle to pry off the outer sheath.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 25, 1)

				if(do_after(user, 100, TRUE, 5, BUSY_ICON_BUILD))
					if(!isrwallturf(src))
						return

					if(d_state == 6)
						to_chat(user, "<span class='notice'>You pry off the outer sheath.</span>")
						dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if (istype(W, /obj/item/tool/pickaxe/diamonddrill))

		to_chat(user, "<span class='notice'>You begin to drill though the wall.</span>")

		if(do_after(user, 200, TRUE, 5, BUSY_ICON_BUILD))
			if(!isrwallturf(src))
				return
			to_chat(user, "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>")
			dismantle_wall()

	//REPAIRING
	else if(damage && istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/MS = W
		user.visible_message("<span class='notice'>[user] starts repairing the damage to [src].</span>",
		"<span class='notice'>You start repairing the damage to [src].</span>")
		playsound(src, 'sound/items/Welder.ogg', 25, 1)
		if(do_after(user, max(5, round(damage / 5)), TRUE, 5, BUSY_ICON_FRIENDLY) && isrwallturf(src))
			user.visible_message("<span class='notice'>[user] finishes repairing the damage to [src].</span>",
			"<span class='notice'>You finish repairing the damage to [src].</span>")
			take_damage(-damage)
			MS.use(1)

		return



	//APC
	else if( istype(W,/obj/item/frame/apc) )
		var/obj/item/frame/apc/AH = W
		AH.try_build(src)

	else if( istype(W,/obj/item/frame/air_alarm) )
		var/obj/item/frame/air_alarm/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/frame/fire_alarm))
		var/obj/item/frame/fire_alarm/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/frame/light_fixture))
		var/obj/item/frame/light_fixture/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/frame/light_fixture/small))
		var/obj/item/frame/light_fixture/small/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/contraband/poster))
		place_poster(W,user)
		return

	return



/turf/closed/wall/r_wall/can_be_dissolved()
	if(hull)
		return 0
	else
		return 2


//Just different looking wall
/turf/closed/wall/r_wall/research
	icon_state = "research"
	walltype = "research"

/turf/closed/wall/r_wall/dense
	icon_state = "iron0"
	walltype = "iron"
	hull = 1

/turf/closed/wall/r_wall/unmeltable
	name = "heavy reinforced wall"
	desc = "A huge chunk of ultra-reinforced metal used to seperate rooms. Looks virtually indestructible."
	icon_state = "rwall"
	walltype = "rwall"
	hull = 1

/turf/closed/wall/r_wall/unmeltable/attackby() //This should fix everything else. No cables, etc
	return





//Chigusa

/turf/closed/wall/r_wall/chigusa
	name = "facility wall"
	icon = 'icons/turf/chigusa.dmi'
	icon_state = "chigusa0"
	walltype = "chigusa"

/turf/closed/wall/r_wall/chigusa/handle_icon_junction(junction)
	if (!walltype)
		return
	//lets make some detailed randomized shit happen.
	var/r1 = rand(0,10) //Make a random chance for this to happen
	var/r2 = rand(0,2) // Which wall if we do choose it
	if(junction == 12)
		switch(r1)
			if(0 to 8)
				icon_state = "[walltype]12"
			if(9 to 10)
				icon_state = "deco_wall[r2]"
	else
		icon_state = "[walltype][junction]"



//Prison

/turf/closed/wall/r_wall/prison
	name = "reinforced metal wall"
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "rwall0"
	walltype = "rwall"

/turf/closed/wall/r_wall/prison_unmeltable
	name = "heavy reinforced wall"
	desc = "A huge chunk of ultra-reinforced metal used to seperate rooms. Looks virtually indestructible."
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "rwall0"
	walltype = "rwall"
	hull = 1

/turf/closed/wall/r_wall/prison_unmeltable/ex_act(severity) //Should make it indestructable
		return

/turf/closed/wall/r_wall/prison_unmeltable/fire_act(exposed_temperature, exposed_volume)
		return

/turf/closed/wall/r_wall/prison_unmeltable/attackby() //This should fix everything else. No cables, etc
		return
