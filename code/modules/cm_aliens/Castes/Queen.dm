//Xenomorph - Queen- Colonial Marines - Apophis775 - Last Edit: 24JAN2015

/mob/living/carbon/Xenomorph/Queen
	caste = "Queen"
	name = "Queen"
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon = 'icons/xeno/Colonial_Queen.dmi'
	icon_state = "Queen Walking"
//	pass_flags = PASSTABLE
	melee_damage_lower = 30
	melee_damage_upper = 46
	tacklemin = 4
	tacklemax = 6
	tackle_chance = 80
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 300
	maxHealth = 300
	amount_grown = 0
	max_grown = 10
	storedplasma = 300
	maxplasma = 700
	plasma_gain = 30
	is_intelligent = 1
	speed = 1
	jellyMax = 0
	adjust_pixel_x = -16
	adjust_pixel_y = -6
//	adjust_size_x = 0.9 Removing these should fix blurriness. let's try.
//	adjust_size_y = 0.85
	fire_immune = 1
	big_xeno = 1
	armor_deflection = 75
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs and royal jelly."
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/Queen/proc/lay_egg,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/psychic_whisper,
		/mob/living/carbon/Xenomorph/Queen/proc/gut,
		/mob/living/carbon/Xenomorph/proc/build_resin,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/Queen/proc/screech,
		/mob/living/carbon/Xenomorph/Queen/proc/produce_jelly,
		/mob/living/carbon/Xenomorph/proc/claw_toggle,
		// /mob/living/carbon/Xenomorph/proc/bestial_roar,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		/mob/living/carbon/Xenomorph/Queen/proc/set_orders,
		/mob/living/carbon/Xenomorph/proc/secure_host
		)

/mob/living/carbon/Xenomorph/Queen/gib()
	death(1) //Prevents resetting queen death timer.
	return

/mob/living/carbon/Xenomorph/Queen/proc/lay_egg()

	set name = "Lay Egg (100)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(!check_state()) return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(locate(/obj/effect/alien/egg) in get_turf(src) || locate(/obj/royaljelly) in get_turf(src)) //Turn em off for now
		src << "There's already an egg or royal jelly here."
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "Your eggs wouldn't grow well enough here. Lay them on resin."
		return

	if(check_plasma(100)) //New plasma check proc, removes/updates plasma automagically
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(T)
	return

/obj/royaljelly
	name = "royal jelly"
	desc = "A greenish-yellow blob of slime that encourages xenomorph evolution."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "jelly"
	anchored = 1
	opacity = 0
	density = 0
	layer = 3.4 //On top of most things

/obj/royaljelly/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(!istype(M,/mob/living/carbon/Xenomorph) || istype(M,/mob/living/carbon/Xenomorph/Larva))
		return

	if(M.jelly)
		M << "You're already filled with delicious jelly."
		return

	if(!M.jellyMax)
		M << "Doesn't smell very good to you. You aren't able to evolve further using jelly."
		return

	M.jelly = 1
	visible_message("\green [M] greedily devours the [src].","You greedily gulp down the [src].")
	del(src)

/mob/living/carbon/Xenomorph/Queen/proc/produce_jelly()

	set name = "Produce Jelly (350)"
	set desc = "Squirt out some royal jelly for hive advancement."
	set category = "Alien"

	if(!check_state())
		return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(locate(/obj/effect/alien/egg) in get_turf(src) || locate(/obj/royaljelly) in get_turf(src))
		src << "There's already an egg or royal jelly here."
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "Your jelly would rot here. Lay them on resin."
		return

	if(check_plasma(350)) //New plasma check proc, removes/updates plasma automagically
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] squirts out a greenish blob of jelly.</B>"), 1)
		new /obj/royaljelly(T)
	return

/mob/living/carbon/Xenomorph/Queen/proc/screech()
	set name = "Screech (250)"
	set desc = "Emit a screech that stuns prey."
	set category = "Alien"

	if(!check_state()) return

	if(has_screeched)
		src << "\red Your vocal chords are not yet prepared."
		return

	if(!check_plasma(250))
		return

	has_screeched = 1
	spawn(500)
		has_screeched = 0
		src << "You feel your throat muscles vibrate. You are ready to screech again."

	playsound(loc, 'sound/voice/alien_queen_screech.ogg', 100, 0, 100, -1)
	//playsound(loc, 'sound/voice/alien_cena.ogg', 100, 0, 100, -1)  - Special Times Only
	visible_message("\red <B> \The [src] emits an ear-splitting guttural roar!</B>")
	create_shriekwave() //Adds the visual effect. Wom wom wom

	for(var/mob/M in view())
		if(M && M.client)
			if(istype(M,/mob/living/carbon/Xenomorph))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 30, 1) // 50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for (var/mob/living/carbon/human/M in oview())
		if(istype(M.l_ear, /obj/item/clothing/ears/earmuffs) || istype(M.r_ear, /obj/item/clothing/ears/earmuffs))
			continue
		var/dist = get_dist(src,M)
		if (dist <= 4)
			M << "\blue An ear-splitting guttural roar shakes the ground beneath your feet!"
			M.stunned += 4 //Seems the effect lasts between 3-8 seconds.
			M.Weaken(1)
//			M.drop_l_hand() //Weaken will drop them on the floor anyway
//			M.drop_r_hand()
			if(!M.ear_deaf)
				M.ear_deaf += 8 //Deafens them temporarily
		else if(dist >= 5 && dist < 7)
			M.stunned += 3
			M << "\blue The sound stuns you!"
	return

/mob/living/carbon/Xenomorph/Queen/proc/gut()
	set category = "Alien"
	set name = "Gut (200)"
	set desc = "While pulling someone, rip their guts out or tear them apart."

	if(!check_state())	return

	if(last_special > world.time)
		return

	var/mob/living/carbon/victim = src.pulling
	if(!victim || isnull(victim) || !istype(victim))
		src << "You're not pulling anyone that can be gutted."
		return

	if(locate(/obj/item/alien_embryo) in victim || locate(/obj/item/alien_embryo) in victim.contents) // Maybe they ate it??
		src << "Not with a widdle alium inside! How cruel!"
		return

	if(istype(victim,/mob/living/carbon/Xenomorph))
		src << "Hey now, that's just not cool."
		return

	var/turf/cur_loc = victim.loc
	if(!cur_loc) return //logic
	if(!cur_loc || !istype(cur_loc)) return

	if(!check_plasma(200))
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> lifts [victim] into the air...</span>")
	if(do_after(src,80))
		if(!victim || isnull(victim)) return
		if(victim.loc != cur_loc) return
		visible_message("<span class='warning'><b>\The [src]</b> viciously wrenches [victim] apart!</span>")
		emote("roar")
		src.attack_log += text("\[[time_stamp()]\] <font color='red'>gibbed [victim.name] ([victim.ckey])</font>")
		victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>was gibbed by [src.name] ([src.ckey])</font>")
		victim.gib() //Splut

/mob/living/carbon/Xenomorph/Queen/proc/set_orders()
	set category = "Alien"
	set name = "Set Hive Orders (50)"
	set desc = "Give some specific orders to the hive. They can see this on the status pane."

	if(!check_state()) return
	if(!check_plasma(50)) return
	if(last_special > world.time) return

	var/txt = copytext(sanitize(input("Set the hive's orders to what? Leave blank to clear it.","Hive Orders","")),1,MAX_MESSAGE_LEN)

	if(txt)
		xeno_message("<B>The Queen has given a new order. Check Status pane for details.</b>")
		hive_orders = txt
	else
		hive_orders = ""

	last_special = world.time + 150
