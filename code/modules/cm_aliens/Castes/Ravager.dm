
/mob/living/carbon/Xenomorph/Ravager
	caste = "Ravager"
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	melee_damage_lower = 28
	melee_damage_upper = 52
	health = 350
	maxHealth = 350
	storedplasma = 50
	plasma_gain = 8
	maxplasma = 100
	jellyMax = 0
	caste_desc = "A brutal, devastating front-line attacker."
	speed = -1.1 //Not as fast as runners, but faster than other xenos.
	evolves_to = list()
	var/usedcharge = 0 //What's the deal with the all caps?? They're not constants :|
	var/CHARGESPEED = 2
	var/CHARGESTRENGTH = 2
	var/CHARGEDISTANCE = 4
	var/CHARGECOOLDOWN = 120
	charge_type = 2 //Claw at end of charge
	fire_immune = 1
	armor_deflection = 75

	adjust_pixel_x = -16
	adjust_pixel_y = -6

	adjust_size_x = 0.8
	adjust_size_y = 0.75

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/charge
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





//OLD BAYCODE FOR REFERENCE
/*
/mob/living/carbon/alien/humanoid/ravager
	name = "alien ravager"
	caste = "Ravager"
	maxHealth = 500
	health = 500
	storedPlasma = 50
	max_plasma = 50
	icon_state = "Ravager Walking"
	plasma_rate = 6
	damagemin = 50
	damagemax = 75
	tacklemin = 4
	tacklemax = 7
	tackle_chance = 90 //Should not be above 100%
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	var/usedcharge = 0
	var/CHARGESPEED = 1
	var/CHARGECOOLDOWN = 6 // in seconds
	var/CHARGESTRENGTH = 4
	var/CHARGEDISTANCE = 4
	var/ATTACKTIME = 1.3 // in seconds
	var/nextattack = 0
	psychiccost = 32
	class = 3

/mob/living/carbon/alien/humanoid/ravager/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien ravager")
		name = text("alien ravager ([rand(1, 1000)])")
	real_name = name
	var/matrix/M = matrix()
	M.Scale(1.15,1.15)
	src.transform = M
	verbs -= /mob/living/carbon/alien/verb/ventcrawl
	verbs -= /mob/living/carbon/alien/humanoid/verb/plant
	pixel_x = -18
	..()

/mob/living/carbon/alien/humanoid/ravager

	handle_environment()
		if(m_intent == "run" || resting)
			..()
		else
			adjustToxLoss(-heal_rate)

/proc/oppositedir(var/dir)
	var/newdir
	switch(dir)
		if(1)
			newdir = 2
		if(2)
			newdir = 1
		if(3)
			newdir = 4
		if(4)
			newdir = 3
		else
			newdir = 2
	return newdir

/mob/living/carbon/alien/humanoid/ravager/ClickOn(var/atom/A, params)



	var/list/modifiers = params2list(params)
	if(modifiers["middle"] || modifiers["shift"])
		charge(A)

		return

	// Give Ravagers 2x the reach (BUG: CAN ATTACK THROUGH WALLS)
	// var/mob/living/carbon/human/C = A
	// if(C)
		// if(src.nextattack <= world.time)
			// src.nextattack = world.time + ATTACKTIME * 10
			// if(get_dist(src, C) == 2)
				// face_atom(C)
				// C.attack_alien(src)
				// return

	..()

/mob/living/carbon/alien/humanoid/ravager/verb/charge(var/mob/living/carbon/human/T)
	set name = "Charge"
	set desc = "Charge towards something."
	set category = "Alien"

	if(health<0)
		src << "You can't charge while unconcious!"
		return
	if(stat == 2)
		src << "You can't charge while dead!"

	if(usedcharge <= world.time)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(src, "Who should we charge towards?") as null|anything in victims

		if(T)
			usedcharge = world.time + CHARGECOOLDOWN * 10
			src.throw_at(T, CHARGEDISTANCE, CHARGESPEED)
			src << "We charge at [T]"
			visible_message("\red <B>[src] charges towards [T]!</B>")
			charging = CHARGESTRENGTH
			spawn(25)
				charging = 0


		else
			src << "\blue You cannot charge at nothing!"
	else
		src << "\red You need to wait before charging!"


*/
