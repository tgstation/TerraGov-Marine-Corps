
/mob/living/carbon/Xenomorph/Ravager
	caste = "Ravager"
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	melee_damage_lower = 28
	melee_damage_upper = 52
	tacklemin = 3
	tacklemax = 6
	tackle_chance = 80
	health = 180
	maxHealth = 180
	storedplasma = 50
	plasma_gain = 8
	maxplasma = 100
	jellyMax = 0
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
	armor_deflection = 75
	big_xeno = 1
	attack_delay = -2

	adjust_pixel_x = -16
	adjust_pixel_y = -6

	adjust_size_x = 0.8
	adjust_size_y = 0.75

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
			X.pass_flags = PASSTABLE
			X.usedPounce = 1 //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
			if(readying_tail) readying_tail = 0
			X.throw_at(T, X.CHARGEDISTANCE, X.CHARGESPEED, src)
			spawn(5)
				X.pass_flags = 0
			spawn(X.CHARGECOOLDOWN)
				X.usedPounce = 0
				X << "Your exoskeleton quivers as you get ready to charge again."

		else
			X << "\blue You cannot charge at nothing!"

	return

