
/mob/living/carbon/Xenomorph/Xenoborg
	caste = "Xenoborg"
	name = "Xenoborg"
	desc = "What.. what is this monstrosity? A cyborg in the shape of a xenomorph?! What hath our science wrought?"
	icon_state = "Xenoborg Walking"
	melee_damage_lower = 24
	melee_damage_upper = 24
	health = 300
	maxHealth = 300
	storedplasma = 1500
	plasma_gain = 0
	maxplasma = 1500
	jellyMax = 0
	caste_desc = "Oh dear god!"
	speed = -1.8
	evolves_to = list() //Cannot evolve.
	charge_type = 1 //Pounce
	is_intelligent = 1
	universal_speak = 1
	universal_understand = 1
	speak_emote = list("buzzes", "beeps")
	armor_deflection = 90
	fire_immune = 1
	is_robotic = 1
	var/gun_on = 0

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/Pounce,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/Xenoborg/proc/fire_cannon
		)

	New()
		..()
		add_language("English")
		add_language("Sol Common")
		add_language("Tradeband")


/mob/living/carbon/Xenomorph/Xenoborg/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		if(!gun_on)
			Pounce(A)
		else
			fire_cannon(A)
		return

	if(modifiers["shift"] && shift_mouse_toggle)
		if(!gun_on)
			Pounce(A)
		else
			fire_cannon(A)
		return
	..()

/mob/living/carbon/Xenomorph/Xenoborg/proc/fire_cannon(var/atom/T)
	set name = "Fire Cannon (5)"
	set desc = "Blast a sucker! Use middle mouse button for best results."
	set category = "Alien"

	if(!check_state())	return

	if(!gun_on)
		src << "Your autocannon is turned off."
		return

	if(usedPounce)
		return

	if(!check_plasma(5))
		return

	if(!T)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in oview(7))
			if(C && istype(C) && !C.stat && !C.lying )
				victims += C
		T = input(src, "Who should you shoot towards?") as null|anything in victims

	if(T && !isnull(T.loc))

		var/turf/M = get_turf(src)
		var/turf/U = get_turf(T)
		if (!istype(M) || !istype(U))
			return
		face_atom(T)
		/*
		var/obj/item/projectile/bullet/m4a3/B = new(M)
		B.accuracy = 300 //Never misses.
		B.armor_pierce = 50
		B.original = U
		B.starting = M

		B.current = M
		B.yo = U.y - M.y
		B.xo = U.x - M.x
		B.def_zone = ran_zone() //Random body part.
		B.firer = src
		B.shot_from = src

		spawn( 1 )
			B.process()
			*/

		visible_message("\red <B>[src] shoots its autocannon!</B>","\red <b>You shoot your autocannon!</B>" )
		playsound(src.loc,'sound/weapons/Gunshot_smg.ogg',60,1)
		usedPounce = 1
		spawn(1)
			usedPounce = 0

	else
		storedplasma += 5 //Since we already stole 5
		src << "\blue You cannot shoot at nothing! Try using middle mouse toggle."
	return

/mob/living/carbon/Xenomorph/Xenoborg/emp_act(severity)
	src.visible_message("[src] visibly shudders!","\red WARN__--d-sEIE)(*##&&$*@#*&#")
	adjustBruteLoss(50 * severity)
	adjustFireLoss(50 * severity)
	Weaken(10)
	updatehealth()

/mob/living/carbon/Xenomorph/Xenoborg/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(user && O && stat != DEAD)
		if(istype(O,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = O
			updatehealth()
			if(health < maxHealth)
				if(!WT.remove_fuel(10))
					user << "\red You need more welding fuel to repair this xenoborg."
					return
				adjustBruteLoss(-20)
				adjustFireLoss(-20)
				updatehealth()
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				src.visible_message("\red [user] repairs some damage to the [src].")
				return
			else
				user << "The [src] is not damaged."
				return
		if(istype(O,/obj/item/weapon/cell))
			var/obj/item/weapon/cell/C = O
			if(storedplasma >= maxplasma)
				user << "[src] does not need a new cell right now."
				return
			src.visible_message("\red [user] carefully inserts [C] into the [src]'s power supply port.")
			storedplasma += C.charge
			if(storedplasma > maxplasma) storedplasma = maxplasma
			src << "\blue You feel your power recharging. Charge now at: [storedplasma]/[maxplasma]"
			del(O)
			user.update_inv_l_hand(0) //Update the user sprites after the del, just to be safe.
			user.update_inv_r_hand()
	return ..() //Just do normal stuff then.

/mob/living/carbon/Xenomorph/Xenoborg/verb/toggle_gun()
	set name = "Toggle Autocannon"
	set desc = "Turns on or off click behavior for middle mouse, between pounce and gun."
	set category = "Alien"

	if(!gun_on)
		visible_message("\blue [src] begins to spin up its arm-embedded autocannon.","\blue You begin to spin up your autocannon.")
		gun_on = 1
	else
		visible_message("\blue [src] lowers its autocannon.","\blue You lower your autocannon.")
		gun_on = 0

	return