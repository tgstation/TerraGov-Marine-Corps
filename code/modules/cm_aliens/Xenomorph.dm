//Xenomorph Super - Colonial Marines - Apophis775 - Last Edit: 8FEB2015

/mob/living/carbon/Xenomorph
	var/caste = ""
	name = "Drone"
	desc = "What the hell is THAT?"
	icon = 'icons/xeno/Colonial_Aliens1x1.dmi'
	icon_state = "Drone Walking"
	voice_name = "xenomorph"
	speak_emote = list("hisses")
	melee_damage_lower = 12
	melee_damage_upper = 16
	attacktext = "claws"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	universal_understand = 0
	universal_speak = 0
	health = 5
	maxHealth = 5
	hand = 1 //Make right hand active by default. 0 is left hand, mob defines it as null normally
	see_in_dark = 20 //This doesn't actually seem to do anything??
	see_infrared = 1
	see_invisible = SEE_INVISIBLE_LEVEL_ONE
	var/dead_icon = "Drone Dead"
	var/language = "Xenomorph"
	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/storedplasma = 0
	var/maxplasma = 50
	var/amount_grown = 0
	var/max_grown = 10
	var/time_of_birth
	var/plasma_gain = 5
	var/mob/living/carbon/Xenomorph/new_xeno
	var/jelly = 0 //variable to check if they ate delicious jelly or not
	var/jellyGrow = 0 //how much the jelly has grown
	var/jellyMax = 0 //max amount jelly will grow till evolution
	var/list/evolves_to = list() //This is where you add castes to evolve into. "Seperated", "by", "commas"
	var/tacklemin = 2
	var/tacklemax = 4
	var/tackle_chance = 50
	var/is_intelligent = 0 //If they can use consoles, etc. Set on Queen
	var/can_slash = 1
	var/caste_desc = "A generic xenomorph. You should never see this."
	var/usedPounce = 0
	var/speed = 0 //Speed bonus/penalties. Positive makes you go slower. (1.5 is equivalent to FAT mutation)
	//This list of inherent verbs lets us take any proc basically anywhere and add them.
	//If they're not a xeno subtype it might crash or do weird things, like using human verb procs
	//It should add them properly on New() and should reset/readd them on evolves
	var/list/inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate
		)

/mob/living/carbon/Xenomorph/New()
	..()
	time_of_birth = world.time
	add_language("Xenomorph") //xenocommon
	add_language("Hivemind") //hivemind
	add_inherent_verbs()

	internal_organs += new /datum/organ/internal/xenos/hivenode(src)


/*	src.frozen = 1 //Freeze the alien in place a moment, while it evolves... WHY DOESN'T THIS WORK? 08FEB2015
	spawn (25)
		src.frozen = 0*/

	name = "[initial(name)] ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	gender = NEUTER

/mob/living/carbon/Xenomorph/Stat()
	..()
	if(istype(src,/mob/living/carbon/Xenomorph/Larva))
		stat(null, "Progress: [amount_grown]/[max_grown]")
	stat(null, "Plasma: [storedplasma]/[maxplasma]")

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
/mob/living/carbon/Xenomorph/mind_initialize()
	..()
	if(caste != "" && caste != null && mind != null)
		mind.special_role = caste

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