//Xenomorph - Larva - Colonial Marines - Apophis775 - Last Edit: 24JAN2015

/mob/living/carbon/Xenomorph/Larva
	name = "Alien Larva"
	real_name = "Alien Larva"
	speak_emote = list("hisses")
	icon = 'icons/xeno/Colonial_Aliens1x1.dmi'
	caste = "Bloody Larva"
	icon_state = "Bloody Larva"
	language = "Hivemind"
	amount_grown = 0
	max_grown = 200
	maxHealth = 25
	health = 25


/mob/living/carbon/Xenomorph/Larva/New()
	..()
	add_language("Xenomorph") //Bonus language.
	internal_organs += new /datum/organ/internal/xenos/hivenode(src)


//Larva Progression
/mob/living/carbon/Xenomorph/Larva/update_progression()
	..()
	if(amount_grown < max_grown)
		amount_grown++
	return

/mob/living/carbon/Xenomorph/Larva/proc/larva_evolution()

	src << "\blue <b>You are growing into a beautiful alien! It is time to choose a caste.</b>"
	src << "\blue There are three to choose from:"
	src << "<B>Hunters</B> \blue are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves."
	src << "<B>Sentinels</B> \blue are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters."
	src << "<B>Drones</B> \blue are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen."
	caste = alert(src, "Please choose which alien caste you shall belong to.", ,"Hunter","Sentinel","Drone")
	return caste ? "[caste]" : null
