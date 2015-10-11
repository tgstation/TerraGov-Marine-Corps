
/mob/living/carbon/Xenomorph/Sentinel
	caste = "Sentinel"
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon_state = "Sentinel Walking"
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 140
	maxHealth = 140
	storedplasma = 75
	plasma_gain = 10
	maxplasma = 300
	jellyMax = 750
	spit_delay = 90
	caste_desc = ""
	evolves_to = list("Spitter")
	spit_projectile = /obj/item/projectile/energy/neuro

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/neurotoxin //Weakest version
		)

/mob/living/carbon/Xenomorph/Sentinel/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		neurotoxin(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		neurotoxin(A)
		return
	..()

// OLD CODE FOR REFERENCE

/*
/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "Sentinel"
	maxHealth = 200
	health = 200
	storedPlasma = 75
	max_plasma = 300
	icon_state = "Sentinal Walking"
	plasma_rate = 7
	damagemin = 18
	damagemax = 24
	tacklemin = 2
	tacklemax = 4
	tackle_chance = 50 //Should not be above 100%
	heal_rate = 6
	var/hasJelly = 0
	var/jellyProgress = 0
	var/jellyProgressMax = 750
	psychiccost = 25
	class = 1
	//TEMP VARIABLES
	var/SPITCOOLDOWN = 10
	var/usedspit = 0
	//END TEMP VARIABLES
	Stat()
		..()
		stat(null, "Jelly Progress: [jellyProgress]/[jellyProgressMax]")
	proc/growJelly()
		spawn while(1)
			if(hasJelly)
				if(jellyProgress < jellyProgressMax)
					jellyProgress = min(jellyProgress + 1, jellyProgressMax)
			sleep(10)
	proc/canEvolve()
		if(!hasJelly)
			return 0
		if(jellyProgress < jellyProgressMax)
			return 0
		return 1


/mob/living/carbon/alien/humanoid/sentinel/New()
	var/datum/reagents/R = new/datum/reagents(100)
	src.frozen = 1
	spawn (25)
		src.frozen = 0
	reagents = R
	R.my_atom = src
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/weak_acid,
	/mob/living/carbon/alien/humanoid/proc/weak_neurotoxin,
	/mob/living/carbon/alien/humanoid/proc/quickspit
	)
	verbs -= /mob/living/carbon/alien/humanoid/verb/plant
	growJelly()
	..()


/mob/living/carbon/alien/humanoid/sentinel/verb/evolve2() // -- TLE
	set name = "Evolve (Jelly)"
	set desc = "Evolve into a Spitter"
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
	if(health<maxHealth)
		src << "\red You are too hurt to Evolve."
		return
	src << "\blue <b>You are growing into a Spitter!</b>"

	var/mob/living/carbon/alien/humanoid/new_xeno

	new_xeno = new /mob/living/carbon/alien/humanoid/spitter(loc)
	src << "\green You begin to evolve!"

	for(var/mob/O in viewers(src, null))
		O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
	if(mind)	mind.transfer_to(new_xeno)

	del(src)


	return



//Aimable Spit *********************************************************

/mob/living/carbon/alien/humanoid/sentinel/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		spit_neuro(A)

		return
	..()



/mob/living/carbon/alien/humanoid/sentinel/verb/spit_neuro(var/atom/T)

	set name = "Spit Neurotoxin (75)"
	set desc = "Spit Weak Neurotoxin."
	set category = "Alien"
	if(powerc(75))
		if(usedspit <= world.time)
			if(!T)
				var/list/victims = list()
				for(var/mob/living/carbon/human/C in oview(7))
					victims += C
				T = input(src, "Who should we spit Neurotoxin at?") as null|anything in victims

			if(T)
				usedspit = world.time + SPITCOOLDOWN * 15

				src << "We spit at [T]"
				visible_message("\red <B>[src] spits at [T]!</B>")

				var/turf/curloc = src.loc
				var/atom/targloc
				if(!istype(T, /turf/))
					targloc = get_turf(T)
				else
					targloc = T
				if (!targloc || !istype(targloc, /turf) || !curloc)
					return
				if (targloc == curloc)
					return
				var/obj/item/projectile/energy/weak_neurotoxin/A = new /obj/item/projectile/energy/weak_neurotoxin(src.loc)
				A.current = curloc
				A.yo = targloc.y - curloc.y
				A.xo = targloc.x - curloc.x
				adjustToxLoss(-75)
				A.process()

			else
				src << "\blue You cannot spit at nothing!"
		else
			src << "\red You need to wait before spitting!"
	else
		src << "\red You need more plasma."

//END AIMABLE SPIT *****************************************

*/