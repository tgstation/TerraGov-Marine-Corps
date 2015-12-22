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
	plasma_gain = 20
	is_intelligent = 1
	speed = 2.6
	jellyMax = 0
	adjust_pixel_x = -16
	adjust_pixel_y = -6
	adjust_size_x = 0.9
	adjust_size_y = 0.85
	fire_immune = 1
	big_xeno = 1
	armor_deflection = 70
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
		)


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

	//playsound(loc, 'sound/voice/alien_queen_screech.ogg', 100, 0, 100, -1)  /TEMP FIX AFTER XMAS
	playsound(loc, 'sound/voice/alien_cena.ogg', 100, 0, 100, -1)
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

/* Old queen code and Notes from CM - REFERENCE ONLY

/mob/living/carbon/alien/humanoid/queen

	status_flags = CANPARALYSE
	heal_rate = 4
	plasma_rate = 20
	var/usedscreech = 0
	tacklemin = 4
	tacklemax = 8
	tackle_chance = 90 //Should not be above 100%

/datum/hive_controller
	var/mob/living/carbon/alien/humanoid/queen/active_queen
	var/psychicstrength = 5
	var/psychicstrengthmax = 500
	var/psychicstrengthused = 0
	var/list/mob/living/carbon/alien/xenos = list()
	var/count = 0

	New()
		process_controller()

	proc/process_controller()
		spawn while(1)
			count += 1
			if(count >= 3 && active_queen && psychicstrength < psychicstrengthmax)
				psychicstrength += 1
				count = 0
			if(istype(active_queen))
				if(active_queen.stat == DEAD)
					psychicstrength = round(psychicstrength / 2)
					for(var/mob/xeno in xenos)
						xeno << "\red The queen has died! You feel the strength of your hivemind decrease greatly."
					active_queen = null
			sleep(50)

/var/global/datum/hive_controller/hive_controller = new()

/mob/living/carbon/alien/proc/hivemind_check(var/amt)

	if(hive_controller)
		if(( hive_controller.psychicstrengthused + (amt/2)) <= hive_controller.psychicstrength )
			return 1
		else
			return 0

/mob/living/carbon/alien/New()
	..()
	if(hive_controller)
		hive_controller.psychicstrengthused += src.psychiccost / 2

/mob/living/carbon/alien/Del()
	if(hive_controller)
		hive_controller.psychicstrengthused -= src.psychiccost / 2
	..()


/mob/living/carbon/alien/death(gibbed)
	..(gibbed)
	if(hive_controller)
		hive_controller.psychicstrengthused -= src.psychiccost / 4

/mob/living/carbon/alien/Stat()
	..()
	stat(null, "Hivemind Strength: [hive_controller.psychicstrengthused]/[hive_controller.psychicstrength]")

/mob/living/carbon/alien/humanoid/queen/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	hive_controller.active_queen = src
	verbs -= /atom/movable/verb/pull
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/resin)
	verbs -= /mob/living/carbon/alien/verb/ventcrawl
	//var/matrix/M = matrix()
	//M.Scale(1.3,1.45)
	//src.transform = M
	pixel_x = -16
	..()



/mob/living/carbon/alien/humanoid/queen/Life()
	..()

	if(usedscreech <= 0)
		usedscreech = 0
	usedscreech--


//Queen verbs


/mob/living/carbon/alien/humanoid/queen/verb/lay_jelly()

	set name = "Produce Royal Jelly (350)"
	set desc = "Produce a sac of fluid which furthers the evolution of the hive."
	set category = "Alien"

	if(locate(/obj/royaljelly) in get_turf(src) || locate(/obj/effect/alien/egg) in get_turf(src))
		src << "There's already royal jelly or egg here."
		return

	if(powerc(350,1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-350)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has shaped a sac and filled it with a greenish fluid!</B>"), 1)
		new /obj/royaljelly(loc)
	return

/mob/living/carbon/alien/humanoid/queen/verb/screech()
	set name = "Screech (250)"
	set desc = "Emit a screech that stuns prey."
	set category = "Alien"

	if(usedscreech >= 1)
		src << "\red Our screech is not ready.."
		return
	if(powerc(250))
		adjustToxLoss(-250)
		for(var/mob/O in view())
			playsound(loc, 'sound/effects/screech2.ogg', 25, 1, -1)
			O << "\red [src] emits a paralyzing screech!"

		for (var/mob/living/carbon/human/M in oview())
			if(istype(M.l_ear, /obj/item/clothing/ears/earmuffs) || istype(M.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
			if (get_dist(src.loc, M.loc) <= 4)
				M.stunned += 3
				M.drop_l_hand()
				M.drop_r_hand()
			else if(get_dist(src.loc, M.loc) >= 5)
				M.stunned += 2

		usedscreech = 30

	return
//End queen verbs

/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s"
	pixel_x = -16

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(lying)
		if(resting)					icon_state = "queen_sleep"
		else						icon_state = "queen_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "queen_s"
		for(var/image/I in overlays_standing)
			overlays += I*/
