

/mob/living/carbon/Xenomorph/Hivelord
	caste = "Hivelord"
	name = "Hivelord"
	desc = "A huge ass xeno covered in weeds! Oh shit!"
	icon = 'icons/xeno/2x2_Xenos.dmi'
	icon_state = "Hivelord Walking"
	melee_damage_lower = 15
	melee_damage_upper = 20
	health = 220
	maxHealth = 220
	storedplasma = 200
	maxplasma = 800
	jellyMax = 0 //Final evolution anyway
	plasma_gain = 35
	evolves_to = list()
	caste_desc = "A builder of REALLY BIG hives."
	adjust_pixel_x = -16
	adjust_pixel_y = -6
	adjust_size_x = 0.8
	adjust_size_y = 0.75
	speed = 1.5
	big_xeno = 1
	var/speed_activated = 0

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/proc/build_resin,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		/mob/living/carbon/Xenomorph/Hivelord/proc/toggle_speed,
		/mob/living/carbon/Xenomorph/proc/secure_host
		)

/mob/living/carbon/Xenomorph/Hivelord/proc/toggle_speed()
	set name = "Resin Walker"
	set desc = "Become one with the weeds. This is a toggleable ability that drains plasma until deactivated, but GREATLY increases your movement speed on weeds."
	set category = "Alien"

	if(!check_state()) return

	if(speed_activated)
		src << "You feel less in tune with the resin."
		speed_activated = 0
		return

	if(!check_plasma(50)) return

	speed_activated = 1
	src << "You become one with the resin. You feel the urge to run!"
	return

/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel() // -- TLE
	set name = "Dig Tunnel (200)"
	set desc = "Place a start or end tunnel. You must place both parts before it is useable and they can NOT be moved. Choose carefully!"
	set category = "Alien"

	if(!check_state())	return

	var/turf/T = loc
	if(!T) //logic
		src << "You can only do this on a turf."
		return

	if(istype(T,/turf/unsimulated/floor/gm/river))
		src << "What, you want to flood your fellow xenos?"
		return

	if(!istype(T,/turf/unsimulated/floor/gm))
		if(!istype(T,/turf/unsimulated/floor/snow))
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

