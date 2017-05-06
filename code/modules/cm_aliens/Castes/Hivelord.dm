//Hivelord Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

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
	jelly = 1
	jellyMax = 800
	plasma_gain = 35
	evolves_to = list()
	caste_desc = "A builder of REALLY BIG hives."
	pixel_x = -16
	speed = 1.5
	big_xeno = 1
	drag_delay = 6 //pulling a big dead xeno is hard
	var/speed_activated = 0
	tier = 2
	upgrade = 0
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/proc/build_resin,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		/mob/living/carbon/Xenomorph/Hivelord/proc/toggle_speed,
	//	/mob/living/carbon/Xenomorph/proc/secure_host
		)

/mob/living/carbon/Xenomorph/Hivelord/can_ventcrawl()
	return

/mob/living/carbon/Xenomorph/Hivelord/proc/toggle_speed()
	set name = "Resin Walker"
	set desc = "Become one with the weeds. This is a toggleable ability that drains plasma until deactivated, but GREATLY increases your movement speed on weeds."
	set category = "Alien"

	if(!check_state())
		return

	if(speed_activated)
		src << "<span class='warning'>You feel less in tune with the resin.</span>"
		speed_activated = 0
		return

	if(!check_plasma(50))
		return

	speed_activated = 1
	src << "<span class='notice'>You become one with the resin. You feel the urge to run!</span>"

/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel() // -- TLE
	set name = "Dig Tunnel (200)"
	set desc = "Place a start or end tunnel. You must place both parts before it is useable and they can NOT be moved. Choose carefully!"
	set category = "Alien"

	if(!check_state())
		return

	var/turf/T = loc
	if(!istype(T)) //logic
		src << "<span class='warning'>You can't do that from there.</span>"
		return

	if(istype(T, /turf/unsimulated/floor/gm/river))
		src << "<span class='warning'>There's no way you can dig there without flooding your tunnel.</span>"
		return

	if(!istype(T, /turf/unsimulated/floor/gm) && !istype(T, /turf/unsimulated/floor/snow) && !istype(T, /turf/unsimulated/floor/mars))
		src << "<span class='warning'>You scrape around, but you can't seem to dig through that kind of floor.</span>"
		return

	if(locate(/obj/structure/tunnel) in loc)
		src << "<span class='warning'>There already is a tunnel here.</span>"
		return

	if(tunnel_delay)
		src << "<span class='warning'>You are not ready to dig a tunnel again.</span>"
		return

	if(get_active_hand())
		src << "<span class='xenowarning'>You need an empty claw for this!</span>"
		r_FAL

	if(!check_plasma(200))
		return

	visible_message("<span class='xenonotice'>[src] begins digging out a tunnel entrance.</span>", \
	"<span class='xenonotice'>You begin digging out a tunnel entrance.</span>")
	if(do_after(src, 100, 1))
		if(!start_dig) //Let's start a new one.
			visible_message("<span class='xenonotice'>\The [src] digs out a tunnel entrance.</span>", \
			"<span class='xenonotice'>You dig out the first entrance to your tunnel.</span>")
			start_dig = new /obj/structure/tunnel(T)
		else
			src << "<span class='xenonotice'>You dig your tunnel all the way to the original entrance, connecting both entrances!</span>"
			var/obj/structure/tunnel/newt = new /obj/structure/tunnel(T)
			newt.other = start_dig
			start_dig.other = newt //Link the two together
			start_dig = null //Now clear it
			tunnel_delay = 1
			spawn(2400)
				src << "<span class='notice'>You are ready to dig a tunnel again.</span>"
				tunnel_delay = 0
		playsound(loc, 'sound/weapons/pierce.ogg', 30, 1)
	else
		src << "<span class='warning'>Your tunnel caves in as you stop digging it.</span>"
		storedplasma += 100 //Refund half their plasma
