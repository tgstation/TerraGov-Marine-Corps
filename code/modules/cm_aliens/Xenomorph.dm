//Xenomorph "generic" parent, does not actually appear in game
//Many of these defines aren't referenced in the castes and so are assumed to be defaulted
//Castes are all merely subchildren of this parent
//Just about ALL the procs are tied to the parent, not to the children
//This is so they can be easily transferred between them without copypasta

//All this stuff was written by Absynth.

/mob/living/carbon/Xenomorph
	var/caste = ""
	name = "Drone"
	desc = "What the hell is THAT?"
	icon = 'icons/xeno/Colonial_Aliens1x1.dmi'
	icon_state = "Drone Walking"
	voice_name = "xenomorph"
	speak_emote = list("hisses")
	melee_damage_lower = 5
	melee_damage_upper = 10 //Arbitrary damage values
	attacktext = "claws"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	universal_understand = 0
	universal_speak = 0
	health = 5
	maxHealth = 5
	hand = 1 //Make right hand active by default. 0 is left hand, mob defines it as null normally
	see_in_dark = 8
	see_infrared = 1
	see_invisible = SEE_INVISIBLE_LEVEL_ONE
	var/dead_icon = "Drone Dead"
	var/language = "Xenomorph"
	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/storedplasma = 0
	var/maxplasma = 10
	var/amount_grown = 0
	var/max_grown = 200
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
	var/caste_desc = "A generic xenomorph. You should never see this."
	var/usedPounce = 0
	var/has_spat = 0
	var/spit_delay = 50 //Delay timer for spitting
	var/has_screeched = 0
	var/middle_mouse_toggle = 0 //This toggles middle mouse clicking for certain abilities.
	var/charge_type = 0 //0: normal. 1: warrior/hunter style pounce. 2: ravager free attack.
	var/armor_deflection = 0 //Chance of deflecting projectiles. No xenos have this yet........
	var/fire_immune = 0 //boolean
	var/adjust_pixel_x = 0

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
	if(adjust_pixel_x != 0) //Adjust large 2x2 sprites
		src.pixel_x += adjust_pixel_x



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