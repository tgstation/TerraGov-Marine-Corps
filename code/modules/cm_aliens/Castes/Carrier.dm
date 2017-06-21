//Carrier Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Carrier
	caste = "Carrier"
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x2
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
	evolution_threshold = 800
	plasma_gain = 8
	evolves_to = list() //Add more here seperated by commas
	caste_desc = "A carrier of huggies."
	drag_delay = 6 //pulling a big dead xeno is hard
	aura_strength = 1 //Carrier's pheromones are equivalent to Hivelord. Climbs 0.5 up to 2.5
	speed = 0.0
	var/huggers_max = 6
	var/huggers_cur = 0
	var/throwspeed = 1
	var/threw_a_hugger = 0
	var/hugger_delay = 40
	tier = 3
	upgrade = 0
	pixel_x = -16 //Needed for 2x2

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Carrier/proc/throw_hugger,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		///mob/living/carbon/Xenomorph/proc/secure_host
		)

	death(gibbed)
		if(..() && !gibbed && huggers_cur)
			var/obj/item/clothing/mask/facehugger/F
			var/i = 3
			var/chance = 75
			visible_message("<span class='xenowarning'>The chittering mass of tiny aliens is trying to escape [src]!</span>")
			while(i && huggers_cur)
				if(prob(chance))
					huggers_cur--
					F = new(loc)
					step_away(F,src,1)
				i--
				chance -= 30

/mob/living/carbon/Xenomorph/Carrier/can_ventcrawl()
	return

/mob/living/carbon/Xenomorph/Carrier/Stat()
	. = ..()
	if(.)
		stat(null, "Stored Huggers: [huggers_cur] / [huggers_max]")

/mob/living/carbon/Xenomorph/Carrier/proc/throw_hugger(var/mob/living/carbon/T)
	set name = "Throw Facehugger"
	set desc = "Throw one of your facehuggers. MIDDLE MOUSE BUTTON quick-throws."
	set category = "Alien"

	if(!check_state())
		return
	//This shit didn't wanna go into the upgrade area...

	if(huggers_cur <= 0)
		src << "<span class='warning'>You don't have any facehuggers to throw!</span>"
		return

	if(!threw_a_hugger)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(src, "Who should you throw at?") as null|anything in victims
		if(T)
			threw_a_hugger = 1
			var/obj/item/clothing/mask/facehugger/newthrow = new()
			huggers_cur--
			newthrow.loc = loc
			newthrow.throw_at(T, 4, throwspeed)
			visible_message("<span class='xenowarning'>\The [src] throws something towards \the [T]!</span>", \
			"<span class='xenowarning'>You throw a facehugger towards \the [T]!</span>")
			spawn(hugger_delay)
				threw_a_hugger = 0
		else
			src << "<span class='warning'>You see nothing to throw this facehugger at!</span>"
