//Ravager Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Ravager
	caste = "Ravager"
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	melee_damage_lower = 30
	melee_damage_upper = 50
	tacklemin = 3
	tacklemax = 6
	tackle_chance = 80
	health = 180
	maxHealth = 180
	storedplasma = 50
	plasma_gain = 8
	maxplasma = 100
	jelly = 1
	jellyMax = 800
	caste_desc = "A brutal, devastating front-line attacker."
	speed = -1.2 //Not as fast as runners, but faster than other xenos.
	evolves_to = list()
	var/usedcharge = 0 //What's the deal with the all caps?? They're not constants :|
	var/CHARGESPEED = 2
	var/CHARGESTRENGTH = 2
	var/CHARGEDISTANCE = 4
	var/CHARGECOOLDOWN = 120
	charge_type = 2 //Claw at end of charge
	fire_immune = 1
	armor_deflection = 55
	big_xeno = 1
	attack_delay = -2
	tier = 3
	upgrade = 0
	pixel_x = -16
	// adjust_pixel_y = -6
	// adjust_size_x = 0.8
	// adjust_size_y = 0.75

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Ravager/proc/charge,
		/mob/living/carbon/Xenomorph/proc/tail_attack
		)

/mob/living/carbon/Xenomorph/Ravager/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		charge(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		charge(A)
		return
	..()

/mob/living/carbon/Xenomorph/Ravager/proc/charge(var/atom/T)
	set name = "Charge (20)"
	set desc = "Charge towards something! Raaaugh!"
	set category = "Alien"

	if(!check_state())	return

	if(!istype(src,/mob/living/carbon/Xenomorph/Ravager))
		src << "How did you get this verb??" //Shouldn't be possible. Ravagers have some vars here that aren't in other castes.
		return

	//Hate using :
	var/mob/living/carbon/Xenomorph/Ravager/X = src

	if(!usedPounce)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(6))
				if(C && istype(C) && !C.lying && !C.stat)
					victims += C
			T = input(X, "Who should you charge towards?") as null|anything in victims

		if(T)
			if(!check_plasma(20))
				return
			visible_message("\red <B>[X] charges towards [T]!</B>","\red <b> You charge at [T]!</B>" )
			emote("roar") //heheh
			X.flags_pass = PASSTABLE
			X.usedPounce = 1 //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
			if(readying_tail) readying_tail = 0
			X.throw_at(T, X.CHARGEDISTANCE, X.CHARGESPEED, src)
			spawn(5)
				X.flags_pass = 0
			spawn(X.CHARGECOOLDOWN)
				X.usedPounce = 0
				X << "Your exoskeleton quivers as you get ready to charge again."

		else
			X << "\blue You cannot charge at nothing!"

	return


//Super hacky firebreathing Halloween rav.
/mob/living/carbon/Xenomorph/Ravager/ravenger
	name = "Ravenger"
	desc = "It's a goddamn dragon! Run! RUUUUN!"
	is_intelligent = 1
	hardcore = 1
	melee_damage_lower = 70
	melee_damage_upper = 90
	tacklemin = 3
	tacklemax = 6
	tackle_chance = 85
	health = 600
	maxHealth = 600
	storedplasma = 200
	plasma_gain = 15
	maxplasma = 200
	upgrade = 3
	var/used_fire_breath = 0

	New()
		..()
		verbs -= /mob/living/carbon/Xenomorph/Ravager/proc/charge
		verbs -= /mob/living/carbon/Xenomorph/proc/transfer_plasma
		verbs -= /mob/living/carbon/Xenomorph/verb/hive_status
		verbs -= /mob/living/carbon/Xenomorph/proc/regurgitate
		verbs -= /mob/living/carbon/Xenomorph/verb/Upgrade
		verbs += /mob/living/carbon/Xenomorph/Ravager/ravenger/proc/breathe_fire
		spawn(15) name = "Ravenger"

	ClickOn(var/atom/A, params)
		var/list/modifiers = params2list(params)
		if(modifiers["middle"] && middle_mouse_toggle)
			breathe_fire(A)
			return
		if(modifiers["shift"] && shift_mouse_toggle)
			breathe_fire(A)
			return
		..()

/mob/living/carbon/Xenomorph/Ravager/ravenger/proc/breathe_fire(atom/A)
	set waitfor = 0
	if(world.time <= used_fire_breath + 75) return
	var/list/turf/turfs = getline2(src,A)
	var/distance = 0
	var/obj/structure/window/W
	var/turf/T
	playsound(src, 'sound/weapons/flamethrower_2.ogg', 80, 1)
	visible_message("<span class='danger'>[src] breathes a stream of flame!</span>","<span class='danger'>You unleash your fire breathe on your enemies!</span>")
	used_fire_breath = world.time
	for(T in turfs)
		if(T == loc) 			continue
		if(distance >= 5) 	break
		if(DirBlocked(T,dir))  break
		else if(DirBlocked(T,turn(dir,180))) break
		if(locate(/obj/effect/alien/resin/wall,T) || locate(/obj/structure/mineral_door/resin,T) || locate(/obj/effect/alien/resin/membrane,T)) break
		W = locate() in T
		if(W)
			if(W.is_full_window()) 	break
			if(W.dir == dir) 	break
		flame_turf(T)
		distance++
		sleep(1)

/mob/living/carbon/Xenomorph/Ravager/ravenger/proc/flame_turf(turf/T)
	if(!istype(T)) return

	if(!locate(/obj/flamer_fire) in T) // No stacking flames!
		var/obj/flamer_fire/F =  new/obj/flamer_fire(T)
		processing_objects.Add(F)
	else return

	for(var/mob/living/carbon/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)		continue

		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune) 	continue
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || istype(H.wear_suit,/obj/item/clothing/suit/space/rig/atmos)) continue

		M.adjustFireLoss(rand(20,50))  //fwoom!
		M << "[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!"