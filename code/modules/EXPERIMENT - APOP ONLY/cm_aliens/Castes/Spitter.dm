
/mob/living/carbon/Xenomorph/Spitter
	caste = "Spitter"
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon_state = "Spitter Walking"
	melee_damage_lower = 10
	melee_damage_upper = 22
	health = 180
	maxHealth = 180
	storedplasma = 150
	plasma_gain = 24
	maxplasma = 600
	jellyMax = 500
	spit_delay = 80
	speed = 0.8
	caste_desc = "Ptui!"
	evolves_to = list("Praetorian", "Boiler")
	spit_projectile = /obj/item/projectile/energy/neuro/strong

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/shift_spits,
		/mob/living/carbon/Xenomorph/proc/neurotoxin //Stronger version
		)

/mob/living/carbon/Xenomorph/Spitter/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		neurotoxin(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		neurotoxin(A)
		return
	..()






/* OLD BAYCODE FOR REFERENCE


//ALIEN SPITTER - UPDATED 30MAY2015 - APOPHIS
/mob/living/carbon/alien/humanoid/spitter
	name = "alien spitter"
	caste = "Spitter"
	maxHealth = 300
	health = 300
	storedPlasma = 150
	max_plasma = 600
	icon_state = "Spitter Walking"
	plasma_rate = 30
	var/progress = 0
	var/hasJelly = 1
	var/progressmax = 900
	damagemin = 20
	damagemax = 26
	tacklemin = 2
	tacklemax = 3
	tackle_chance = 75 //Should not be above 100% old was 65
	heal_rate = 3
	psychiccost = 25
	class = 2
	//TEMP VARIABLES
	var/SPITCOOLDOWN = 10
	var/usedspit = 0
	//END TEMP VARIABLES
	Stat()
		..()
		stat(null, "Jelly Progress: [progress]/[progressmax]")
	proc/growJelly()
		spawn while(1)
			if(hasJelly)
				if(progress < progressmax)
					progress = min(progress + 1, progressmax)
			sleep(10)
	proc/canEvolve()
		if(!hasJelly)
			return 0
		if(progress < progressmax)
			return 0
		return 1


/mob/living/carbon/alien/humanoid/spitter/New()
	var/datum/reagents/R = new/datum/reagents(100)
	src.frozen = 1
	spawn (50)
		src.frozen = 0
	reagents = R
	R.my_atom = src
	if(name == "alien spitter")
		name = text("alien spitter ([rand(1, 1000)])")
	real_name = name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/weak_neurotoxin,
	/mob/living/carbon/alien/humanoid/proc/neurotoxin,
	/mob/living/carbon/alien/humanoid/proc/weak_acid,
	/mob/living/carbon/alien/humanoid/proc/corrosive_acid,
	/mob/living/carbon/alien/humanoid/proc/quickspit)
	verbs -= /mob/living/carbon/alien/humanoid/verb/plant
	//var/matrix/M = matrix()
	//M.Scale(1.15,1.1)
	//src.transform = M
	//pixel_y = 3
	growJelly()
	..()



/mob/living/carbon/alien/humanoid/spitter/verb/evolve() // -- TLE
	set name = "Evolve (Jelly)"
	set desc = "Evolve into a Praetorian"
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
	src << "\blue <b>You are growing into a Praetorian!</b>"

	var/mob/living/carbon/alien/humanoid/new_xeno

	new_xeno = new /mob/living/carbon/alien/humanoid/praetorian(loc)
	src << "\green You begin to evolve!"

	for(var/mob/O in viewers(src, null))
		O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
	if(mind)	mind.transfer_to(new_xeno)

	del(src)


	return



//Aimable Spit *********************************************************

/mob/living/carbon/alien/humanoid/spitter/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		spit_neuro(A)

		return
	..()



/mob/living/carbon/alien/humanoid/spitter/verb/spit_neuro(var/atom/T)

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
