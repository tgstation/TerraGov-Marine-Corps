//Xenomorph - Drone - Colonial Marines - Apophis775 - Last Edit: 24JAN2015

/mob/living/carbon/Xenomorph/Drone
	caste = "Drone"
	name = "Drone"
	desc = "An Alien Drone"
	icon = 'icons/xeno/Colonial_Aliens1x1.dmi'
	icon_state = "Drone Walking"
//	pass_flags = PASSTABLE
	melee_damage_lower = 12
	melee_damage_upper = 16
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 170
	maxHealth = 170
	storedplasma = 350
	maxplasma = 750
	evolves_to = list("Queen") //Add more here seperated by commas
	caste_desc = "A builder of hives. Only drones may evolve into Queens."

//new drone Code 06FEB2015

mob/living/carbon/Xenomorph/Drone/New()
	..()
	jelly = 0
	jellyMax = 1200
	verbs += /mob/living/proc/ventcrawl

// either freeze is currently broken and needs to be investigated...
	/
	src.frozen = 1
	spawn (25)
		src.frozen = 0
//	verbs.Add(/mob/living/carbon/Xenomorph/proc/resin,/mob/living/carbon/Xenomorph/proc/weak_acid) //This will be enabled later
//	growJelly()  TEMP DISABLED (was infinite Looping?)







/* OLD CM Drone Notes And Code - FOR REFERENCE ONLY

	plasma_rate = 13
	tacklemin = 2
	tacklemax = 4 //old max 5
	tackle_chance = 40 //Should not be above 100% old chance 50
	psychiccost = 30



/mob/living/carbon/alien/humanoid/drone/verb/evolve2() // -- TLE
	set name = "Evolve (Jelly)"
	set desc = "Evolve into your next form"
	set category = "Alien"
	if(!hivemind_check(psychiccost))
		src << "\red Your queen's psychic strength is not powerful enough for you to evolve further."
		return
	if(!canEvolve())
		if(hasJelly)
			src << "You are not ready to evolve yet"
		else
			src << "You need a mature royal jelly to evolve"
		return
	if(src.stat != CONSCIOUS)
		src << "You are unable to do that now."
		return
	if(jellyProgress >= jellyProgressMax)	//TODO ~Carn
		//green is impossible to read, so i made these blue and changed the formatting slightly
		src << "<B>Hivelord</B> \blue The ULTIMATE hive construction alien.  Capable of building massive hives, that's to it's tremendous Plasma reserve.  However, it is very slow and weak."
		src << "<B>Carrier</B> \blue The latest advance in Alien Evolution.  Capable of holding upto 6 runners, and throwing them a far distance, directly to someones face."
		var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hivelord","Carrier")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Hivelord")
				new_xeno = new /mob/living/carbon/alien/humanoid/hivelord(loc)
			if("Carrier")
				new_xeno = new /mob/living/carbon/alien/humanoid/carrier(loc)
		if(mind)	mind.transfer_to(new_xeno)
		del(src)
		return
	else
		src << "\red You are not ready to evolve."
		return

	del(src)


	return



*/