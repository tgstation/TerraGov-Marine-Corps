
/mob/living/carbon/Xenomorph/Carrier
	caste = "Carrier"
	name = "Carrier"
	desc = "An Alien Carrier. It carries huggers."
	icon_state = "Carrier Walking"
	melee_damage_lower = 20
	melee_damage_upper = 30
	tacklemin = 1
	tacklemax = 3
	tackle_chance = 60
	health = 200
	maxHealth = 200
	storedplasma = 50
	maxplasma = 250
	jellyMax = 0
	plasma_gain = 8
	evolves_to = list() //Add more here seperated by commas
	caste_desc = "A carrier of huggies."
	adjust_size_x = 1.1
	adjust_size_y = 1.2
	var/huggers_max = 6
	adjust_pixel_y = 3
	var/huggers_cur = 0
	var/throwspeed = 2
	var/threw_a_hugger = 0
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Carrier/proc/throw_hugger,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/toggle_auras
		)


/mob/living/carbon/Xenomorph/Carrier/Stat()
	..()
	stat(null, "Stored Huggers: [huggers_cur] / [huggers_max]")


/mob/living/carbon/Xenomorph/Carrier/ClickOn(var/atom/A, params)
//FUCK SHIFT CLICK! FUCK YOUUUUUUUU. SHIFT CLICK IS EXAMINE!
	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		throw_hugger(A) //Just try to chuck it, throw_hugger has all the required checks anyway
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		throw_hugger(A) //Just try to chuck it, throw_hugger has all the required checks anyway
		return
	..()

/mob/living/carbon/Xenomorph/Carrier/proc/throw_hugger(var/mob/living/carbon/T)
	set name = "Throw Facehugger"
	set desc = "Throw one of your facehuggers. MIDDLE MOUSE BUTTON quick-throws."
	set category = "Alien"

	if(!check_state())	return

	var/mob/living/carbon/Xenomorph/Carrier/X = src
	if(!istype(X))
		src << "How did you get this verb??" //Lel. Shouldn't be possible, butcha never know. Since this uses carrier-only vars
		return

	if(X.huggers_cur <= 0)
		src << "\red You don't have any facehuggers to throw!"
		return

	if(!X.threw_a_hugger)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(src, "Who should you throw at?") as null|anything in victims
		if(T)
			X.threw_a_hugger = 1
			var/obj/item/clothing/mask/facehugger/newthrow = new()
			X.huggers_cur -= 1
			newthrow.loc = src.loc
			newthrow.throw_at(T, 5, X.throwspeed)
			// src << "You throw a facehugger at [T]."
			visible_message("\red <B>[src] throws something towards [T]!</B>")
			spawn(40)
				X.threw_a_hugger = 0
		else
			src << "\blue You cannot throw at nothing!"
	return





//OLD BAYCODE FOR REFERENCE

/*
/mob/living/carbon/alien/humanoid/carrier/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien carrier")
		name = text("alien carrier ([rand(1, 1000)])")
	real_name = name
	var/matrix/M = matrix()
	M.Scale(1.1,1.15)
	src.transform = M
	pixel_y = 3
	verbs -= /mob/living/carbon/alien/verb/ventcrawl
	verbs -= /atom/movable/verb/pull
	..()



/mob/living/carbon/alien/humanoid/carrier/Life()
	..()

	if(usedthrow < 0)
		usedthrow = 0
	else if(usedthrow > 0)
		usedthrow--

/mob/living/carbon/alien/humanoid/carrier/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] || modifiers["shift"])
		if(facehuggers > 0)
			throw_hugger(A)
		else
			..()
		return
	..()

/mob/living/carbon/alien/humanoid/carrier/verb/throw_hugger(var/mob/living/carbon/human/T)
	set name = "Throw Facehugger"
	set desc = "Throw one of your facehuggers"
	set category = "Alien"
	if(health < 0)
		src << "\red You can't throw huggers when unconcious."
		return
	if (stat == 2)
		src << "\red You can't throw huggers when dead."
		return
	if(facehuggers <= 0)
		src << "\red You don't have any facehuggers to throw!"
		return
	if(usedthrow <= 0)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(src, "Who should you throw at?") as null|anything in victims

		if(T)
			var/obj/item/clothing/mask/facehugger/throw = new()
			facehuggers -= 1
			usedthrow = 1
			throw.loc = src.loc
			throw.throw_at(T, 5, THROWSPEED)
			src << "We throw a facehugger at [throw]"
			visible_message("\red <B>[src] throws something towards [T]!</B>")

		else
			src << "\blue You cannot throw at nothing!"
	else
		src << "\red You need to wait before throwing again!"


/mob/living/carbon/alien/humanoid/carrier/handle_environment()
	if(m_intent == "run" || resting)
		..()
	else
		adjustToxLoss(-heal_rate)

Todo: Overlays for facehuggers.

//Update carrier icons
/mob/living/carbon/alien/humanoid/carrier/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(stat == DEAD)
		//If we mostly took damage from fire
		if(fireloss > 125)
			icon_state = "[caste] Dead - [facehuggers]"
		else
			icon_state = "[caste] Dead - [facehuggers]"
		for(var/image/I in overlays_lying)
			overlays += I
	else if(lying)
		if(resting)
			icon_state = "[caste] Sleeping - [facehuggers]"
		else if(stat == UNCONSCIOUS)
			icon_state = "[caste] Knocked Down - [facehuggers]"
		else
			icon_state = "[caste] Knocked Down - [facehuggers]"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		if(m_intent == "run")		icon_state = "[caste] Running - [facehuggers]"
		else						icon_state = "[caste] Walking - [facehuggers]"
		for(var/image/I in overlays_standing)
			overlays += I
			*/