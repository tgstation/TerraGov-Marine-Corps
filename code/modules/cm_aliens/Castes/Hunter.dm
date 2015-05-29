
/mob/living/carbon/Xenomorph/Hunter
	caste = "Hunter"
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon_state = "Hunter Walking"
	melee_damage_lower = 20
	melee_damage_upper = 35
	health = 250
	maxHealth = 250
	storedplasma = 50
	plasma_gain = 8
	maxplasma = 100
	jellyMax = 900
	caste_desc = "A fast, powerful front line combatant."
	speed = -1.5 //Not as fast as runners, but faster than other xenos
	evolves_to = list("Ravager")

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/Pounce,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		)








// OLD CODE FOR REFERENCE

/*
/mob/living/carbon/alien/humanoid/hunter
	name = "alien warrior"
	caste = "Hunter"
	maxHealth = 250 //old maxhealth was 210
	health = 250
	storedPlasma = 100
	max_plasma = 150
	icon_state = "Hunter Walking"
	plasma_rate = 8 //old plasma was 7
	damagemin = 30
	damagemax = 35
	tacklemin = 3
	tacklemax = 5
	tackle_chance = 80 //Should not be above 100%
	heal_rate = 4
	class = 2
	var/usedpounce = 0

	var/hasJelly = 1
	var/jellyProgress = 0
	var/jellyProgressMax = 900
	psychiccost = 25
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


/mob/living/carbon/alien/humanoid/hunter/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	growJelly()
	src.frozen = 1
	spawn (50)
		src.frozen = 0
	reagents = R
	R.my_atom = src
	if(name == "alien warrior")
		name = text("alien warrior ([rand(1, 1000)])")
	real_name = name
	verbs -= /mob/living/carbon/alien/humanoid/verb/plant


/mob/living/carbon/alien/humanoid/hunter

	handle_environment()
		if(m_intent == "run" || resting)
			..()
		else
			adjustToxLoss(-heal_rate)

/mob/living/carbon/alien/humanoid/hunter/Life()
	..()

	if(usedpounce <= 0)
		usedpounce = 0
	usedpounce--


//Hunter verbs
/mob/living/carbon/alien/humanoid/hunter/verb/pounce()
	set name = "Pounce (50)"
	set desc = "Pounce onto your prey."
	set category = "Alien"

	if(usedpounce >= 1)
		src << "\red We must wait before pouncing again.."
		return

	if(powerc(50))
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
			usedpounce = 12
			adjustToxLoss(-50)
			if(target.r_hand && istype(target.r_hand, /obj/item/weapon/shield/riot) || target.l_hand && istype(target.l_hand, /obj/item/weapon/shield/riot))
				if (prob(35))	// If the human has riot shield in his hand
					src.weakened = 1.5//Stun the fucker instead
					visible_message("\red <B>[target] blocked [src] with his shield!</B>")
				else
					src.canmove = 0
					src.frozen = 1
					target.Weaken(3)
					spawn(30)
						src.frozen = 0
			else
				src.canmove = 0
				src.frozen = 1
				target.Weaken(3)

			spawn(30)
				src.frozen = 0
		else
			src << "\red We sense no prey.."

	return
//End hunter verbs

//Hunter procs

//End hunter procs


/mob/living/carbon/alien/humanoid/hunter/verb/evolve2() // -- TLE
	set name = "Evolve (Jelly)"
	set desc = "Evolve into a Ravager"
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
	src << "\blue <b>You are growing into a Ravager!</b>"

	var/mob/living/carbon/alien/humanoid/new_xeno

	new_xeno = new /mob/living/carbon/alien/humanoid/ravager(loc)
	src << "\green You begin to evolve!"

	for(var/mob/O in viewers(src, null))
		O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
	if(mind)	mind.transfer_to(new_xeno)

	del(src)


	return
*/
