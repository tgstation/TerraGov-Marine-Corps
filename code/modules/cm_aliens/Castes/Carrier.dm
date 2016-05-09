
/mob/living/carbon/Xenomorph/Carrier
	caste = "Carrier"
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon_state = "Carrier Walking"
	melee_damage_lower = 20
	melee_damage_upper = 30
	tacklemin = 2
	tacklemax = 3
	tackle_chance = 60
	health = 175
	maxHealth = 175
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
	var/throwspeed = 1
	var/threw_a_hugger = 0
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Carrier/proc/throw_hugger,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		/mob/living/carbon/Xenomorph/proc/secure_host
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



