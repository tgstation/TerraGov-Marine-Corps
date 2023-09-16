
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
	var/removed_type //When removed, forms this object.
	var/robotic_type //robotic version of removed_type, used in mechanize().
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

/datum/internal_organ/New(mob/living/carbon/carbon_mob)
	..()
	if(!istype(carbon_mob))
		return

	carbon_mob.internal_organs |= src
	owner = carbon_mob
	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(clean_owner))

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
	. = ..()
	if(!.)
		return
	// For example, bruised lungs will reduce stamina regen by 40%, broken by 80%
	owner.add_stamina_regen_modifier(name, organ_status * -0.40)
	// Slowdown added when the heart is damaged
	owner.add_movespeed_modifier(id = name, override = TRUE, multiplicative_slowdown = organ_status)

/datum/internal_organ/lungs/take_damage(amount, silent= FALSE)
	owner.adjust_Losebreath(amount) //Hits of 1 damage or less won't do anything due to how losebreath works, but any stronger and we'll get the wind knocked out of us for a bit. Mostly just flavor.
	return ..()

/datum/internal_organ/lungs/prosthetic
	robotic = ORGAN_ROBOT
	removed_type = /obj/item/organ/lungs/prosthetic


/datum/internal_organ/liver
	name = "liver"
	parent_limb = "chest"
	removed_type = /obj/item/organ/liver
	robotic_type = /obj/item/organ/liver/prosthetic
	organ_id = ORGAN_LIVER
	///lower value, higher resistance.
	var/alcohol_tolerance = 0.005
	///How fast we clean out toxins/toxloss. Adjusts based on organ damage.
	var/filter_rate = 3

/datum/internal_organ/liver/process()
	..()

	//High toxins levels are dangerous if you aren't actively treating them. 100 seconds to hit bruised from this alone
	if(owner.getToxLoss() >= (80 - 20 * organ_status))
		//Healthy liver suffers on its own
		if (organ_status != ORGAN_BROKEN)
			take_damage(0.2, TRUE)
		//Damaged one shares the fun
		else
			var/datum/internal_organ/O = pick(owner.internal_organs)
			O?.take_damage(0.2, TRUE)

	// Heal a bit if needed and we're not busy. This allows recovery from low amounts of toxins.
	if(!owner.drunkenness && owner.getToxLoss() <= 15 && organ_status == ORGAN_HEALTHY)
		heal_organ_damage(0.04)

	// Do some reagent filtering/processing.
	for(var/datum/reagent/potential_toxin AS in owner.reagents.reagent_list)
		//Liver helps clear out any toxins but with drawbacks if damaged
		if(istype(potential_toxin, /datum/reagent/consumable/ethanol) || istype(potential_toxin, /datum/reagent/toxin))
			if(organ_status != ORGAN_HEALTHY)
				owner.adjustToxLoss(0.3 * organ_status)
			owner.reagents.remove_reagent(potential_toxin.type, potential_toxin.custom_metabolism * filter_rate * 0.1)

	//Heal toxin damage slowly if not damaged. If broken, increase it instead.
	owner.adjustToxLoss((2 - filter_rate) * 0.1)
	if(prob(organ_status)) //Just under once every three minutes while bruised, twice as often while broken.
		owner.vomit() //No stomach, so the liver can cause vomiting instead. Stagger and slowdown plus feedback that something's wrong.

/datum/internal_organ/liver/set_organ_status()
	. = ..()
	if(!.)
		return
	filter_rate = initial(filter_rate) - organ_status

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
	///Tracks the number of reagent/medicine datums we currently have
	var/current_medicine_count = 0
	///How many drugs we can take before they overwhelm us. Decreases with damage
	var/current_medicine_cap = 5
	///Whether we were over cap the last time we checked.
	var/old_overflow = FALSE
	///Total medicines added since last tick
	var/new_medicines = 0
	///Total medicines removed since last tick
	var/removed_medicines = 0

/datum/internal_organ/kidneys/New(mob/living/carbon/carbon_mob)
	. = ..()
	if(!carbon_mob)
		return
	RegisterSignal(carbon_mob.reagents, COMSIG_NEW_REAGENT_ADD, PROC_REF(owner_added_reagent))
	RegisterSignal(carbon_mob.reagents, COMSIG_REAGENT_DELETING, PROC_REF(owner_removed_reagent))

/datum/internal_organ/kidneys/clean_owner()
	if(owner?.reagents)
		UnregisterSignal(owner.reagents, list(COMSIG_NEW_REAGENT_ADD, COMSIG_REAGENT_DELETING))
	return ..()

///Signaled proc. Check if the added reagent was under reagent/medicine. If so, increment medicine counter and potentially notify owner.
/datum/internal_organ/kidneys/proc/owner_added_reagent(datum/source, reagent_type, amount)
	SIGNAL_HANDLER
	if(!ispath(reagent_type, /datum/reagent/medicine))
		return
	new_medicines++

///Signaled proc. Check if the removed reagent was under reagent/medicine. If so, decrement medicine counter and potentially notify owner.
/datum/internal_organ/kidneys/proc/owner_removed_reagent(datum/source, reagent_type)
	SIGNAL_HANDLER
	if(!ispath(reagent_type, /datum/reagent/medicine))
		return
	removed_medicines++

/datum/internal_organ/kidneys/set_organ_status()
	. = ..()
	if(!.)
		return
	current_medicine_cap = initial(current_medicine_cap) - 2 * organ_status

/datum/internal_organ/kidneys/process()
	..()

	var/bypass = FALSE

	if(owner.bodytemperature <= 170) //No sense worrying about a chem cap if we're in cryo anyway. Still need to clear tick counts.
		bypass = TRUE

	current_medicine_count += new_medicines //We want to include medicines that were individually both added and removed this tick
	var/overflow = current_medicine_count - current_medicine_cap //This catches any case where a reagent was added with volume below its metabolism
	current_medicine_count -= removed_medicines //Otherwise, you can microdose infinite chems without kidneys complaining

	new_medicines = 0
	removed_medicines = 0

	if(overflow < 1 || bypass)
		if(old_overflow)
			to_chat(owner, span_notice("You don't feel as overwhelmed by all the drugs any more."))
			old_overflow = FALSE
		return

	if(!old_overflow)
		to_chat(owner, span_warning("All the different drugs in you are starting to make you feel off..."))
		old_overflow = TRUE

	owner.set_drugginess(3)
	if(prob(overflow * (organ_status + 1) * 10))
		owner.Confused(2 SECONDS * (organ_status + 1))

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

/datum/internal_organ/brain/set_organ_status()
	var/old_organ_status = organ_status
	. = ..()
	if(!.)
		return
	owner.set_skills(owner.skills.modifyAllRatings(old_organ_status - organ_status))
	if(organ_status >= ORGAN_BRUISED)
		ADD_TRAIT(owner, TRAIT_DROOLING, BRAIN_TRAIT)
	else
		REMOVE_TRAIT(owner, TRAIT_DROOLING, BRAIN_TRAIT)

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
