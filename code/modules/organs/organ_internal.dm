#define PROCESS_ACCURACY 10

/****************************************************
				INTERNAL ORGANS
****************************************************/


/datum/internal_organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null
	var/vital //Lose a vital limb, die immediately.
	var/damage = 0 // amount of damage to the organ
	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/parent_limb = "chest"
	var/robotic = 0 //1 for 'assisted' organs (e.g. pacemaker), 2 for actual cyber organ.
	var/cut_away = FALSE //internal organ has its links to the body severed, organ is ready to be removed.
	var/removed_type //When removed, forms this object.
	var/robotic_type //robotic version of removed_type, used in mechanize().
	var/rejecting            // Is this organ already being rejected?
	var/obj/item/organ/organ_holder // If not in a body, held in this item.
	var/list/transplant_data
	var/germ_level = 0		// INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE


/datum/internal_organ/proc/process()
		return 0

//Germs
/datum/internal_organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < MIN_ANTIBIOTICS)
		return

	if (germ_level < 10)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_ONE)
		germ_level -= 4
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 3	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes


/datum/internal_organ/proc/rejuvenate()
	damage=0

/datum/internal_organ/proc/is_bruised()
	return damage >= min_bruised_damage

/datum/internal_organ/proc/is_broken()
	return damage >= min_broken_damage || cut_away

/datum/internal_organ/New(mob/living/carbon/M)
	..()
	if(M && istype(M))

		M.internal_organs |= src
		src.owner = M

		var/mob/living/carbon/human/H = M
		if(istype(H))
			var/datum/limb/E = H.get_limb(parent_limb)
			if(E.internal_organs == null)
				E.internal_organs = list()
			E.internal_organs |= src

/datum/internal_organ/process()

	//Process infections
	if (robotic >= 2 || (owner.species && owner.species.flags & IS_PLANT))	//TODO make robotic internal and external organs separate types of organ instead of a flag
		germ_level = 0
		return

	if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

		if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
			germ_level--

		if (germ_level >= INFECTION_LEVEL_ONE/2)
			//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
			if(antibiotics < MIN_ANTIBIOTICS && prob(round(germ_level/6)))
				germ_level++

		if (germ_level >= INFECTION_LEVEL_TWO)
			var/datum/limb/parent = owner.get_limb(parent_limb)
			//spread germs
			if (antibiotics < MIN_ANTIBIOTICS && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30) ))
				parent.germ_level++

			if (prob(3))	//about once every 30 seconds
				take_damage(1,silent=prob(30))

/datum/internal_organ/proc/take_damage(amount, var/silent=0)
	if(src.robotic == ORGAN_ROBOT)
		src.damage += (amount * 0.8)
	else
		src.damage += amount

	var/datum/limb/parent = owner.get_limb(parent_limb)
	if (!silent)
		owner.custom_pain("Something inside your [parent.display_name] hurts a lot.", 1)

/datum/internal_organ/proc/heal_damage(amount)
	if(damage < amount)
		damage = 0
	else
		damage -= amount

/datum/internal_organ/proc/emp_act(severity)
	switch(robotic)
		if(0)
			return
		if(1)
			switch (severity)
				if (1.0)
					take_damage(20,0)
					return
				if (2.0)
					take_damage(7,0)
					return
				if(3.0)
					take_damage(3,0)
					return
		if(2)
			switch (severity)
				if (1.0)
					take_damage(40,0)
					return
				if (2.0)
					take_damage(15,0)
					return
				if(3.0)
					take_damage(10,0)
					return

/datum/internal_organ/proc/mechanize() //Being used to make robutt hearts, etc
	if(robotic_type)
		robotic = ORGAN_ROBOT
		removed_type = robotic_type


/datum/internal_organ/proc/mechassist() //Used to add things like pacemakers, etc
	robotic = ORGAN_ASSISTED
	min_bruised_damage = 15
	min_broken_damage = 35

/****************************************************
				INTERNAL ORGANS TYPES
****************************************************/

/datum/internal_organ/heart // This is not set to vital because death immediately occurs in blood.dm if it is removed.
	name = "heart"
	parent_limb = "chest"
	removed_type = /obj/item/organ/heart
	robotic_type = /obj/item/organ/heart/prosthetic

/datum/internal_organ/heart/prosthetic //used by synthetic species
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/heart/prosthetic

/datum/internal_organ/lungs
	name = "lungs"
	parent_limb = "chest"
	removed_type = /obj/item/organ/lungs
	robotic_type = /obj/item/organ/lungs/prosthetic

/datum/internal_organ/lungs/process()
	..()
	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(!owner.reagents.get_reagent_amount("peridaxon") >= 0.05)
		if(is_bruised())
			if(prob(2))
				spawn owner.emote("me", 1, "coughs up blood!")
				owner.drip(10)
			if(prob(4))
				spawn owner.emote("me", 1, "gasps for air!")
				owner.losebreath += 15

/datum/internal_organ/lungs/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/lungs/prosthetic


/datum/internal_organ/liver
	name = "liver"
	parent_limb = "chest"
	removed_type = /obj/item/organ/liver
	robotic_type = /obj/item/organ/liver/prosthetic

/datum/internal_organ/liver/process()
	..()

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			owner << "\red Your skin itches."
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
			//Healthy liver suffers on its own
			if (src.damage < min_broken_damage)
				src.damage += 0.2 * PROCESS_ACCURACY
			//Damaged one shares the fun
			else
				var/datum/internal_organ/O = pick(owner.internal_organs)
				if(O)
					O.damage += 0.2  * PROCESS_ACCURACY

		//Detox can heal small amounts of damage
		if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
			src.damage -= 0.2 * PROCESS_ACCURACY

		if(src.damage < 0)
			src.damage = 0

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(!owner.reagents.get_reagent_amount("peridaxon") >= 0.05)
			if(is_bruised())
				filter_effect -= 1
			if(is_broken())
				filter_effect -= 2

		// Do some reagent filtering/processing.
		for(var/datum/reagent/R in owner.reagents.reagent_list)
			// Damaged liver means some chemicals are very dangerous
			// The liver is also responsible for clearing out alcohol and toxins.
			// Ethanol and all drinks are bad.K
			if(istype(R, /datum/reagent/ethanol))
				if(filter_effect < 3)
					owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
				owner.reagents.remove_reagent(R.id, R.custom_metabolism*filter_effect)
			// Can't cope with toxins at all
			else if(istype(R, /datum/reagent/toxin))
				if(filter_effect < 3)
					owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)
				owner.reagents.remove_reagent(R.id, ALCOHOL_METABOLISM*filter_effect)

		//Heal toxin damage slowly if not damaged
		if(damage < 5 && prob(25))
			owner.adjustToxLoss(-0.5)

		//Deal toxin damage if damaged
		if(!owner.reagents.get_reagent_amount("peridaxon") >= 0.05)
			if(is_bruised() && prob(25))
				owner.adjustToxLoss(0.1 * (damage/2))
			else if(is_broken() && prob(50))
				owner.adjustToxLoss(0.3 * (damage/2))

/datum/internal_organ/liver/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/liver/prosthetic

/datum/internal_organ/kidneys
	name = "kidneys"
	parent_limb = "groin"
	removed_type = /obj/item/organ/kidneys
	robotic_type = /obj/item/organ/kidneys/prosthetic

/datum/internal_organ/kidneys/process()
	..()

	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	var/datum/reagent/coffee = locate(/datum/reagent/drink/coffee) in owner.reagents.reagent_list
	if(coffee && !owner.reagents.get_reagent_amount("peridaxon") >= 0.05)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(is_broken())
			owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

	//Deal toxin damage if damaged
	if(!owner.reagents.get_reagent_amount("peridaxon") >= 0.05)
		if(is_bruised() && prob(25))
			owner.adjustToxLoss(0.1 * (damage/3))
		else if(is_broken() && prob(50))
			owner.adjustToxLoss(0.2 * (damage/3))

/datum/internal_organ/kidneys/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/kidneys


/datum/internal_organ/brain
	name = "brain"
	parent_limb = "head"
	removed_type = /obj/item/organ/brain
	robotic_type = /obj/item/organ/brain/prosthetic
	vital = 1

/datum/internal_organ/brain/prosthetic //used by synthetic species
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/brain/prosthetic

/datum/internal_organ/brain/xeno
	removed_type = /obj/item/organ/brain/xeno
	robotic_type = null

/datum/internal_organ/eyes
	name = "eyes"
	parent_limb = "head"
	removed_type = /obj/item/organ/eyes
	robotic_type = /obj/item/organ/eyes/prosthetic
	var/eye_surgery_stage = 0 //stores which stage of the eye surgery the eye is at

/datum/internal_organ/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(!owner.reagents.get_reagent_amount("peridaxon") >= 0.05)
		if(is_bruised())
			owner.eye_blurry = 20
		if(is_broken())
			owner.eye_blind = 20

/datum/internal_organ/eyes/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/eyes/prosthetic


/datum/internal_organ/appendix
	name = "appendix"
	parent_limb = "groin"
	removed_type = /obj/item/organ/appendix

/datum/internal_organ/proc/remove(var/mob/user)

	if(!removed_type) return 0

	var/obj/item/organ/removed_organ = new removed_type(get_turf(user), src)

	if(istype(removed_organ))
		organ_holder = removed_organ

	return removed_organ
