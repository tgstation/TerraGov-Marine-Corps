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
	var/organ_id
	/// State of the organ
	var/organ_status = ORGAN_HEALTHY

/datum/internal_organ/process()
		return 0

/datum/internal_organ/Destroy()
	owner = null
	organ_holder = null
	return ..()

/datum/internal_organ/proc/rejuvenate()
	damage=0

/datum/internal_organ/New(mob/living/carbon/carbon_mob)
	..()
	if(!istype(carbon_mob))
		return

	carbon_mob.internal_organs |= src
	owner = carbon_mob
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/clean_owner)

	if(!ishuman(carbon_mob))
		return
	var/mob/living/carbon/human/human = carbon_mob
	var/datum/limb/limb = human.get_limb(parent_limb)
	LAZYDISTINCTADD(limb.internal_organs, src)

///Signal handler to prevent hard del
/datum/internal_organ/proc/clean_owner()
	SIGNAL_HANDLER
	owner = null

/datum/internal_organ/proc/take_damage(amount, silent= FALSE)
	if(SSticker.mode?.flags_round_type & MODE_NO_PERMANENT_WOUNDS)
		return
	if(amount <= 0)
		heal_organ_damage(-amount)
		return
	if(robotic == ORGAN_ROBOT)
		damage += (amount * 0.8)
	else
		damage += amount

	var/datum/limb/parent = owner.get_limb(parent_limb)
	if (!silent)
		owner.custom_pain("Something inside your [parent.display_name] hurts a lot.", 1)
	set_organ_status()

/// Set the correct organ state
/datum/internal_organ/proc/set_organ_status()
	if(damage > min_broken_damage)
		if(organ_status != ORGAN_BROKEN)
			organ_status = ORGAN_BROKEN
			return TRUE
		return FALSE
	if(damage > min_bruised_damage)
		if(organ_status != ORGAN_BRUISED)
			organ_status = ORGAN_BRUISED
			return TRUE
		return FALSE
	if(organ_status != ORGAN_HEALTHY)
		organ_status = ORGAN_HEALTHY
		return TRUE

/datum/internal_organ/proc/heal_organ_damage(amount)
	damage = max(damage - amount, 0)
	set_organ_status()

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

/datum/internal_organ/heart // This is not set to vital because death immediately occurs in blood.dm if it is removed. Also, all damage effects are handled there.
	name = "heart"
	parent_limb = "chest"
	removed_type = /obj/item/organ/heart
	robotic_type = /obj/item/organ/heart/prosthetic
	organ_id = ORGAN_HEART

/datum/internal_organ/heart/process()
	. = ..()

	if(organ_status == ORGAN_BRUISED && prob(5))
		owner.emote("me", 1, "grabs at [owner.p_their()] chest!")
	else if(organ_status == ORGAN_BROKEN && prob(20))
		owner.emote("me", 1, "clutches [owner.p_their()] chest!")

/datum/internal_organ/heart/set_organ_status()
	var/old_organ_status = organ_status
	. = ..()
	if(!.)
		return
	// For example, bruised heart will leave you with 25 stamina buffer
	owner.max_stamina_buffer += (old_organ_status - organ_status) * 25
	owner.maxHealth += (old_organ_status - organ_status) * 20

/datum/internal_organ/heart/prosthetic //used by synthetic species
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/heart/prosthetic

/datum/internal_organ/lungs
	name = "lungs"
	parent_limb = "chest"
	removed_type = /obj/item/organ/lungs
	robotic_type = /obj/item/organ/lungs/prosthetic
	organ_id = ORGAN_LUNGS

/datum/internal_organ/lungs/process()
	..()

	if((organ_status == ORGAN_BRUISED && prob(5)) || (organ_status == ORGAN_BROKEN && prob(20)))
		owner.emote("me", 1, "gasps for air!")

/datum/internal_organ/lungs/set_organ_status()
	var/old_organ_status = organ_status
	. = ..()
	if(!.)
		return
	// For example, bruised lungs will reduce stamina regen by 40%, broken by 80%
	owner.stamina_regen_multiplier += (old_organ_status - organ_status) * 0.40
	// Slowdown added when the heart is damaged
	owner.add_movespeed_modifier(id = name, multiplicative_slowdown = organ_status)

/datum/internal_organ/lungs/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/lungs/prosthetic


/datum/internal_organ/liver
	name = "liver"
	parent_limb = "chest"
	removed_type = /obj/item/organ/liver
	robotic_type = /obj/item/organ/liver/prosthetic
	var/alcohol_tolerance = 0.005 //lower value, higher resistance.
	organ_id = ORGAN_LIVER

/datum/internal_organ/liver/process()
	..()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent(/datum/reagent/medicine/dylovene))
			//Healthy liver suffers on its own
			if (damage < min_broken_damage)
				take_damage(0.2 * PROCESS_ACCURACY, TRUE)
			//Damaged one shares the fun
			else
				var/datum/internal_organ/O = pick(owner.internal_organs)
				if(O)
					O.take_damage(0.2  * PROCESS_ACCURACY, TRUE)

		// Heal a bit if needed and we're not busy. This allows recovery from low amounts of toxins.
		if(!owner.drunkenness && owner.getToxLoss() <= 15 && min_bruised_damage > damage > 0)
			if(!owner.reagents.has_reagent(/datum/reagent/medicine/dylovene)) // Detox effect
				heal_organ_damage(0.2 * PROCESS_ACCURACY)
			else
				heal_organ_damage(0.04 * PROCESS_ACCURACY)

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(organ_status == ORGAN_BRUISED)
			filter_effect -= 1
		if(organ_status == ORGAN_BROKEN)
			filter_effect -= 2

		// Do some reagent filtering/processing.
		for(var/datum/reagent/R in owner.reagents.reagent_list)
			// Damaged liver means some chemicals are very dangerous
			// The liver is also responsible for clearing out alcohol and toxins.
			// Ethanol and all drinks and all poisons are bad.K
			if(istype(R, /datum/reagent/consumable/ethanol) || istype(R, /datum/reagent/toxin))
				if(filter_effect < 3)
					var/toxloss = istype(R, /datum/reagent/toxin) ? 0.3 : 0.1
					owner.adjustToxLoss(toxloss * PROCESS_ACCURACY)
				owner.reagents.remove_reagent(R.type, R.custom_metabolism*filter_effect)

		//Heal toxin damage slowly if not damaged
		if(damage < 5 && prob(25))
			owner.adjustToxLoss(-0.5)

		if(organ_status == ORGAN_BRUISED && prob(25))
			owner.adjustToxLoss(0.1 * (damage/2))
		else if(organ_status == ORGAN_BROKEN && prob(50))
			owner.adjustToxLoss(0.3 * (damage/2))

/datum/internal_organ/liver/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/liver/prosthetic
	alcohol_tolerance = 0.003

/datum/internal_organ/kidneys
	name = "kidneys"
	parent_limb = "groin"
	removed_type = /obj/item/organ/kidneys
	robotic_type = /obj/item/organ/kidneys/prosthetic
	organ_id = ORGAN_KIDNEYS

/datum/internal_organ/kidneys/process()
	..()

	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	var/datum/reagent/coffee = locate(/datum/reagent/consumable/drink/coffee) in owner.reagents.reagent_list
	if(coffee)
		if(organ_status == ORGAN_BRUISED)
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(organ_status == ORGAN_BROKEN)
			owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

	if(organ_status == ORGAN_BRUISED && prob(25))
		owner.adjustToxLoss(0.1 * (damage/3))
	else if(organ_status == ORGAN_BROKEN && prob(50))
		owner.adjustToxLoss(0.2 * (damage/3))

/datum/internal_organ/kidneys/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/kidneys


/datum/internal_organ/brain
	name = "brain"
	parent_limb = "head"
	removed_type = /obj/item/organ/brain
	robotic_type = /obj/item/organ/brain/prosthetic
	vital = TRUE
	organ_id = ORGAN_BRAIN

/datum/internal_organ/brain/prosthetic //used by synthetic species
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/brain/prosthetic

/datum/internal_organ/brain/xeno
	removed_type = /obj/item/organ/brain/xeno
	robotic_type = null

/datum/internal_organ/brain/zombie
	vital = FALSE

/datum/internal_organ/eyes
	name = "eyes"
	parent_limb = "head"
	removed_type = /obj/item/organ/eyes
	robotic_type = /obj/item/organ/eyes/prosthetic
	var/eye_surgery_stage = 0 //stores which stage of the eye surgery the eye is at
	organ_id = ORGAN_EYES

/datum/internal_organ/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(organ_status == ORGAN_BRUISED)
		owner.set_blurriness(20)
	if(organ_status == ORGAN_BROKEN)
		owner.set_blindness(20)

/datum/internal_organ/eyes/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/eyes/prosthetic


/datum/internal_organ/appendix
	name = "appendix"
	parent_limb = "groin"
	removed_type = /obj/item/organ/appendix
	organ_id = ORGAN_APPENDIX

/datum/internal_organ/proc/remove(mob/user)

	if(!removed_type) return 0

	var/obj/item/organ/removed_organ = new removed_type(get_turf(user), src)

	if(istype(removed_organ))
		organ_holder = removed_organ

	return removed_organ
