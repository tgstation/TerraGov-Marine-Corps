
/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	///The limb this wound is on
	var/datum/limb/parent_limb
	///number representing the current stage
	var/current_stage = 0

	///description of the wound
	var/desc = "wound"

	///amount of damage this wound has
	var/damage = 0
	// amount of damage the current wound type requires(less means we need to apply the next healing stage)
	var/min_damage = 0

	/*  These are defined by the wound type and should not be changed */

	///stages such as "cut", "deep cut", etc.
	var/list/stages
	///one of CUT, BRUISE, BURN
	var/damage_type = CUT
	// whether this wound needs a bandage/salve to heal at all
	// the maximum amount of damage that this wound can have and still autoheal
	var/autoheal_cutoff = 15

	// helper lists
	var/tmp/list/desc_list = list()
	var/tmp/list/damage_list = list()

/datum/wound/New(initial_damage, datum/limb/plimb)
	parent_limb = plimb
	//reading from a list("stage" = damage) is pretty difficult, so build two separate
	//lists from them instead
	for(var/V in stages)
		desc_list += V
		damage_list += stages[V]

	damage = initial_damage

	// initialize with the appropriate stage
	current_stage = stages.len

	while(current_stage > 1 && damage_list[current_stage-1] <= initial_damage)
		current_stage--

	min_damage = damage_list[current_stage]
	desc = desc_list[current_stage]

/datum/wound/process()
	if(damage <= 0)
		qdel(src)

/datum/wound/Destroy()
	if(parent_limb)
		parent_limb.wounds -= src
	parent_limb = null
	. = ..()

/datum/wound/proc/can_autoheal()
	if(damage <= autoheal_cutoff)
		return TRUE

/**
 *heal the given amount of damage, and if the given amount of damage was more
 *than what needed to be healed, return how much heal was left
 *set @heals_internal to also heal internal organ damage
 */
/datum/wound/proc/heal_wound_damage(heal_amount)
	// either, the entire wound, or the heal_amount
	var/healed_damage = min(damage, heal_amount)
	heal_amount -= healed_damage // If the heal was large, we may have only removed the small exisitng damage
	damage -= healed_damage // Heal the wound

	// Update the stages
	while(damage < damage_list[current_stage] && current_stage < desc_list.len)
		current_stage++
	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]

	// return amount of healing still leftover, can be used for other wounds
	return heal_amount

///Reopens the wound again
/datum/wound/proc/open_wound(initial_damage)
	damage += initial_damage

	var/damage_per_wound = damage
	while(current_stage > 1 && damage_list[current_stage - 1] <= damage_per_wound)
		current_stage--

	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]

/** INTERNAL BLEEDING **/
/datum/wound/internal_bleeding
	stages = list("severed artery" = 30, "cut artery" = 20, "damaged artery" = 10, "bruised artery" = 5)
	autoheal_cutoff = 5

/datum/wound/internal_bleeding/process()

	var/bicardose = parent_limb.owner.reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine)
	var/inaprovaline = parent_limb.owner.reagents.get_reagent_amount(/datum/reagent/medicine/inaprovaline)
	var/old_qc = parent_limb.owner.reagents.get_reagent_amount(/datum/reagent/medicine/quickclotplus)
	var/quickclot = parent_limb.owner.reagents.get_reagent_amount(/datum/reagent/medicine/quickclot)

	if(!(can_autoheal() || (bicardose && inaprovaline) || quickclot))	//bicaridine and inaprovaline stop internal wounds from growing bigger with time, unless it is so small that it is already healing
		parent_limb.createwound(CUT, 0.1)
	if(bicardose >= 30)	//overdose of bicaridine begins healing IB
		damage -= 0.2
	if(old_qc >= 5)	//overdose of QC+ heals IB extremely fast.
		damage -= 5

	if(!quickclot) //Quickclot stops bleeding, magic!
		parent_limb.owner.blood_volume = max(0, parent_limb.owner.blood_volume - damage/30)
		if(prob(1))
			parent_limb.owner.custom_pain("You feel a stabbing pain in your [parent_limb.display_name]!", 1)

	return ..()
