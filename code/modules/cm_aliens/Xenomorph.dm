//Xenomorph Super - Colonial Marines - Apophis775 - Last Edit: 8FEB2015

/mob/living/carbon/human/Xenomorph
	var/caste = ""
	name = "Drone"
	desc = "What the hell is THAT?"
	icon = 'icons/xeno/Colonial_Aliens1x1.dmi'
	icon_state = "Drone Walking"
	pass_flags = PASSTABLE
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "Bites"
	attack_sound = null
	friendly = "Nuzzles"
	wall_smash = 0
	health = 5
	maxHealth = 5
	var/storedplasma = 0
	var/maxplasma = 50
	var/amount_grown = 0
	var/max_grown = 10
	var/time_of_birth
	var/language
	var/mob/living/carbon/Xenomorph/new_xeno
	var/jelly = 0 //variable to check if they ate delicious jelly or not
	var/jellyGrow = 0 //how much the jelly has grown
	var/jellyMax = 0 //max amount jelly will grow till evolution

/mob/living/carbon/human/Xenomorph/New()
	..()
	time_of_birth = world.time
	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide


/*	src.frozen = 1 //Freeze the alien in place a moment, while it evolves... WHY DOESN'T THIS WORK? 08FEB2015
	spawn (25)
		src.frozen = 0*/

	name = "[initial(name)] ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()

	if(language)
		add_language(language)
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	gender = NEUTER


/*
/mob/living/carbon/Xenomorph/u_equip(obj/item/W as obj)
	return

/mob/living/carbon/Xenomorph/Stat()
	..()
	stat(null, "Progress: [amount_grown]/[max_grown]")

/mob/living/carbon/Xenomorph/restrained()
	return 0

/mob/living/carbon/Xenomorph/can_use_vents()
	return

/mob/living/carbon/Xenomorph/proc/update_progression()
	return

//Show_Inv might get removed later, depending on how I make the aliens.
/mob/living/carbon/Xenomorph/show_inv(mob/user as mob)
	return


//Mind Initializer
/mob/living/carbon/Xenomorph/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

/mob/living/carbon/Xenomorph/Drone/mind_initialize()
	..()
	mind.special_role = "Drone"



//Environment Handling
/mob/living/carbon/Xenomorph/handle_environment(var/datum/gas_mixture/environment)

	if(!environment) return

	var/turf/T = get_turf(src)
	if(environment.gas["phoron"] > 0 || (T && locate(/obj/effect/alien/weeds) in T.contents))
		update_progression()
		adjustBruteLoss(-1)
		adjustFireLoss(-1)
		adjustToxLoss(-1)
		adjustOxyLoss(-1)
*/



//Xenomorph Hud Health Adjuster Apophis 08FEB2015

/*  Enable later, and it may need to be adjusted once the hud is operational
/mob/living/carbon/Xenomorph

	handle_regular_hud_updates()

		..()
		var/HP = (health/maxHealth)*100

		if (healths)
			if (stat != 2)
				switch(HP)
					if(80 to INFINITY)
						healths.icon_state = "health0"
					if(60 to 80)
						healths.icon_state = "health1"
					if(40 to 60)
						healths.icon_state = "health2"
					if(20 to 40)
						healths.icon_state = "health3"
					if(0 to 20)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"
*/