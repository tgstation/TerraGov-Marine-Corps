
/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	///The limb this wound is on
	var/datum/limb/parent_limb

	///description of the wound
	var/desc = "wound"

	///amount of damage this wound has
	var/damage = 0

	/*  These are defined by the wound type and should not be changed */

	///one of CUT, BRUISE, BURN
	var/damage_type = CUT
	// the maximum amount of damage that this wound can have and still autoheal
	var/autoheal_cutoff = 15

/datum/wound/New(initial_damage, datum/limb/plimb)
	parent_limb = plimb
	damage = initial_damage
	parent_limb.wounds += src
	return ..()

///Called by the parent limb every life tick by default
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
 */
/datum/wound/proc/heal_wound_damage(heal_amount)
	// either, the entire wound, or the heal_amount
	var/healed_damage = min(damage, heal_amount)
	heal_amount -= healed_damage // If the heal was large, we may have only removed the small exisitng damage
	damage -= healed_damage // Heal the wound

	// return amount of healing still leftover, can be used for other wounds
	return heal_amount

///Reopens the wound again. Remove applied treatment, if there is any, and add new damage
/datum/wound/proc/open_wound(initial_damage)
	damage += initial_damage

/** INTERNAL BLEEDING **/
/datum/wound/internal_bleeding
	desc = "damaged artery"
	autoheal_cutoff = 0

/datum/wound/internal_bleeding/process()

	var/bicardose = parent_limb.owner.reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine)
	var/inaprovaline = parent_limb.owner.reagents.get_reagent_amount(/datum/reagent/medicine/inaprovaline)
	var/quickclot = parent_limb.owner.reagents.get_reagent_amount(/datum/reagent/medicine/quickclot)

	if(!(bicardose && inaprovaline))	//bicaridine and inaprovaline stop internal wounds from harming the parent limb over time
		parent_limb.createwound(CUT, 0.1)

	if(!quickclot) //Quickclot stops bleeding, magic!
		parent_limb.owner.blood_volume = max(0, parent_limb.owner.blood_volume - damage/30)
		if(prob(1))
			parent_limb.owner.custom_pain("You feel a stabbing pain in your [parent_limb.display_name]!", 1)

	return ..()
