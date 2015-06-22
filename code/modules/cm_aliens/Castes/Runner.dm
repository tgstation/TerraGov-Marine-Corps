//Xenomorph Runner - Colonial Marines - Apophis775 - Last Edit: 8FEB2015

/mob/living/carbon/Xenomorph/Runner
	caste = "Runner"
	name = "Alien Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon_state = "Runner Walking"
	melee_damage_lower = 13
	melee_damage_upper = 18
	health = 80
	maxHealth = 80
	storedplasma = 50
	plasma_gain = 1
	maxplasma = 100
	jellyMax = 750
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	speed = -2.2
	evolves_to = list("Hunter")
	charge_type = 1 //Pounce

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/Pounce,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		)


/mob/living/carbon/Xenomorph/Runner/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		Pounce(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		Pounce(A)
		return
	..()





/*OLD CM ALIEN RUNNER NOTES AND CODE - REFERENCE ONLY Apophis

//ALIEN RUNNER - UPDATED 07JAN2015 - APOPHIS
/mob/living/carbon/alien/humanoid/runner

	plasma_rate = 5

	tacklemin = 2
	tacklemax = 4
	tackle_chance = 80 //Should not be above 100%
	heal_rate = 4
	psychiccost = 25
	var/usedpounce = 0


	//RUNNERS NOW USE JELLY, SINCE THEY EVOLVE INTO HUNTERS
	var/hasJelly = 0
	var/jellyProgress = 0
	var/jellyProgressMax = 750
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

/mob/living/carbon/alien/humanoid/runner/New()
	var/datum/reagents/R = new/datum/reagents(100)
	src.frozen = 1
	spawn (25)
		src.frozen = 0
	reagents = R
	R.my_atom = src
	if(name == "alien runner")
		name = text("alien runner ([rand(1, 1000)])")
	real_name = name
	growJelly()
	verbs -= /atom/movable/verb/pull
	verbs -= /mob/living/carbon/alien/humanoid/verb/plant
	//var/matrix/M = matrix()
	//M.Scale(1.15,1.1)
	//src.transform = M
	//pixel_y = 3
	..()



/mob/living/carbon/alien/humanoid/runner


	handle_regular_hud_updates()

		..() //-Yvarov
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


/mob/living/carbon/alien/humanoid/runner/verb/evolve2() // -- TLE
	set name = "Evolve (Jelly)"
	set desc = "Evolve into a Warrior"
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
	src << "\blue <b>You are growing into a Warrior!</b>"

	var/mob/living/carbon/alien/humanoid/new_xeno

	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
	src << "\green You begin to evolve!"

	for(var/mob/O in viewers(src, null))
		O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
	if(mind)	mind.transfer_to(new_xeno)

	del(src)


	return

/mob/living/carbon/alien/humanoid/runner/verb/Pounce()
	set name = "Pounce (25)"
	set desc = "Pounce onto your prey."
	set category = "Alien"

	if(usedpounce >= 1)
		src << "\red We must wait before pouncing again.."
		return

	if(powerc(25))
		var/targets[] = list()
		for(var/mob/living/carbon/human/M in oview())
			if(M.stat)	continue//Doesn't target corpses or paralyzed persons.
			targets.Add(M)

		if(targets.len)
			var/mob/living/carbon/human/target=pick(targets)
			var/atom/targloc = get_turf(target)
			if (!targloc || !istype(targloc, /turf) || get_dist(src.loc,targloc)>=3)
				src << "We cannot reach our prey!"
				return
			if(src.weakened >= 1 || src.paralysis >= 1 || src.stunned >= 1)
				src << "We cannot pounce if we are stunned.."
				return

			visible_message("\red <B>[src] pounces on [target]!</B>")
			if(src.m_intent == "walk")
				src.m_intent = "run"
				src.hud_used.move_intent.icon_state = "running"
			src.loc = targloc
			usedpounce = 5
			adjustToxLoss(-50)
			if(target.r_hand && istype(target.r_hand, /obj/item/weapon/shield/riot) || target.l_hand && istype(target.l_hand, /obj/item/weapon/shield/riot))
				if (prob(35))	// If the human has riot shield in his hand
					src.weakened = 5//Stun the fucker instead
					visible_message("\red <B>[target] blocked [src] with his shield!</B>")
				else
					src.canmove = 0
					src.frozen = 1
					target.Weaken(2)
					spawn(15)
						src.frozen = 0
			else
				src.canmove = 0
				src.frozen = 1
				target.Weaken(2)

			spawn(15)
				src.frozen = 0
		else
			src << "\red We sense no prey.."

	return


/mob/living/carbon/alien/humanoid/runner/Life()
	..()

	if(usedpounce <= 0)
		usedpounce = 0
	usedpounce--

//Stops runners from pulling APOPHIS775 03JAN2015
/mob/living/carbon/alien/humanoid/runner/start_pulling(var/atom/movable/AM)
	src << "<span class='warning'>You don't have the dexterity to pull anything.</span>"
	return*/
