

/mob/living/carbon/Xenomorph/Hivelord
	caste = "Hivelord"
	name = "Hivelord"
	desc = "A huge ass xeno covered in weeds! Oh shit!"
	icon = 'icons/xeno/2x2_Xenos.dmi'
	icon_state = "Hivelord Walking"
	melee_damage_lower = 15
	melee_damage_upper = 20
	health = 260
	maxHealth = 260
	storedplasma = 200
	maxplasma = 800
	jellyMax = 0 //Final evolution anyway
	plasma_gain = 28
	evolves_to = list()
	caste_desc = "A builder of REALLY BIG hives."
	adjust_pixel_x = -16
	adjust_pixel_y = -6
	adjust_size_x = 0.8
	adjust_size_y = 0.75
	speed = 1.8
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/proc/build_resin,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel,
		/mob/living/carbon/Xenomorph/proc/tail_attack
		)

/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel() // -- TLE
	set name = "Dig Tunnel (200)"
	set desc = "Place a start or end tunnel. You must place both parts before it is useable and they can NOT be moved. Choose carefully!"
	set category = "Alien"

	if(!check_state())	return

	var/turf/T = loc
	if(!T) //logic
		src << "You can only do this on a turf."
		return

	if(istype(T,/turf/simulated/floor/gm/river))
		src << "What, you want to flood your fellow xenos?"
		return

	if(!istype(T,/turf/simulated/floor/gm))
		src << "You scrape around, but nothing happens. You can only place these on open ground."
		return

	if(locate(/obj/structure/tunnel) in src.loc)
		src << "There's already a tunnel here. Go somewhere else."
		return

	if(tunnel_delay)
		src << "You are not yet ready to fashion a new tunnel. Be patient! Tunneling is hard work!"
		return

	if(!check_plasma(200))
		return

	visible_message("\blue [src] begins carefully digging out a huge, wide tunnel.","\blue You begin carefully digging out a tunnel..")
	if(do_after(src,100))
		if(!start_dig) //Let's start a new one.
			src << "\blue You dig out the beginning of a new tunnel. Go somewhere else and dig a new one to finish it!"
			start_dig = new /obj/structure/tunnel(T)
		else
			src << "\blue You finish digging out the two tunnels and connect them together!"
			var/obj/structure/tunnel/newt = new /obj/structure/tunnel(T)
			newt.other = start_dig
			start_dig.other = newt //Link the two together
			start_dig = null //Now clear it
			tunnel_delay = 1
			spawn(2400)
				src << "\blue Your claws are ready to dig a new tunnel."
				src.tunnel_delay = 0
		playsound(loc, 'sound/weapons/pierce.ogg', 30, 1)
	else
		src << "You were interrupted, and your tunnel collapses, you irresponsible monster you."
		src.storedplasma += 100 //refund half their plasma
	return


//OLD BAYCODE FOR REFERENCE
/*

/mob/living/carbon/alien/humanoid/hivelord
	name = "alien hivelord"
	caste = "Hivelord"
	maxHealth = 320
	health = 320
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Hivelord Walking"
	plasma_rate = 50
	heal_rate = 6
	storedPlasma = 100
	max_plasma = 1000
	damagemin = 10
	damagemax = 15
	tacklemin = 2
	tacklemax = 4
	tackle_chance = 70 //Should not be above 100%
	psychiccost = 32
	class = 3

/mob/living/carbon/alien/humanoid/hivelord/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien hivelord")
		src.name = text("alien hivelord ([rand(1, 1000)])")
	src.real_name = src.name
	verbs -= /mob/living/carbon/alien/verb/ventcrawl

	verbs.Add(/mob/living/carbon/alien/humanoid/proc/resin,/mob/living/carbon/alien/humanoid/proc/corrosive_acid)
	pixel_x = -16
	..()


/mob/living/carbon/alien/humanoid/hivelord/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		var/turf/select
		if(!istype(A, /turf))
			if(istype(A.loc, /turf))
				select = A.loc
			else
				..()
				return
		else
			select = A
		if(select)
			if(get_dist(src, select) <= 3)
				resin2(select)
				return
	..()

/mob/living/carbon/alien/humanoid/hivelord/proc/check_floor(var/turf/location)
	if(istype(location, /turf/simulated/wall) || istype(location, /turf/unsimulated/wall))
		return 0
	for(var/atom/object in range(1, location))
		if(istype(object, /turf/simulated) || istype(object, /obj/structure/lattice) || istype(object, /turf/unsimulated))
			return 1

	return 0

/mob/living/carbon/alien/humanoid/hivelord/verb/resin2(var/turf/location = src.loc) // -- TLE
	set name = "Secrete Hardened Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"
	if(!location)
		if(istype(src.loc, /turf))
			location = src.loc
		else
			return

	if(!canMoveTo(src.loc, location))
		src << "You don't have a line of sight with this location"
		return

	if(powerc(75))
		var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door","resin wall","resin membrane","resin nest","resin floor") //would do it through typesof but then the player choice would have the type path and we don't want the internal workings to be exposed ICly - Urist
		if(!choice || !powerc(75))	return



		var/dist = get_dist(src, location)
		adjustToxLoss(-75)
		if(dist > 3)
			src << "\green Too far away."
			return
		else if(dist > 1 && dist <= 3)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[src] vomits up a thick purple substance and launches it.</B>"), 1)
		else if(dist <= 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[src] vomits up a thick purple substance and begins to shape it!</B>"), 1)
		src << "\green You shape a [choice]."
		switch(choice)
			if("resin door")
				new /obj/structure/mineral_door/resin/hardened(location)
			if("resin wall")
				new /obj/effect/alien/resin/wall/hardened(location)
			if("resin membrane")
				new /obj/effect/alien/resin/membrane/hardened(location)
			if("resin nest")
				new /obj/structure/stool/bed/nest(location)
			if("resin floor")
				if(check_floor(location))
					if(istype(location, /turf))
						location.ChangeTurf(/turf/simulated/floor/resin)
					else
						src << "\green Bad spot for a floor."
				else
					src << "\green Bad spot for a floor."
	return


//hivelords use the same base as generic humanoids.
//hivelord verbs


/obj/structure/mineral_door/resin/hardened
	hardness = 2.5
	health = 200
	color = "#CCCCCC"

/obj/effect/alien/resin/wall/hardened
		name = "resin wall"
		desc = "Purple slime solidified into a wall."
		icon_state = "resinwall" //same as resin, but consistency ho!
		color = "#CCCCCC"
		health = 230

/obj/effect/alien/resin/membrane/hardened
		name = "resin membrane"
		desc = "Purple slime just thin enough to let light pass through."
		icon_state = "resinmembrane"
		opacity = 0
		health = 170
		color = "#CCCCCC"


/turf/simulated/floor/resin
	icon_state = "resinfloor"

	*/

