
/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	///number representing the current stage
	var/current_stage = 0

	///description of the wound
	var/desc = "wound"

	///amount of damage this wound causes
	var/damage = 0
	///ticks of bleeding left.
	var/bleed_timer = 0
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

/datum/wound/New(initial_damage)

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

	bleed_timer += damage*2.5

///the amount of damage per wound
//CLEAR OUT LATER
/datum/wound/proc/wound_damage()
	return damage

/datum/wound/proc/can_autoheal()
	if(wound_damage() <= autoheal_cutoff)
		return TRUE

/**
 *heal the given amount of damage, and if the given amount of damage was more
 *than what needed to be healed, return how much heal was left
 *set @heals_internal to also heal internal organ damage
 */
/datum/wound/proc/heal_wound_damage(heal_amount, heals_internal = FALSE)
	// If the wound is internal, and we don't heal internal wounds just pass through.

	// either, the entire wound, or the heal_amount
	var/healed_damage = min(damage, heal_amount)
	heal_amount -= healed_damage // If the heal was large, we may have only removed the small exisitng damage
	damage -= healed_damage // Heal the wound

	// Update the stages
	while(wound_damage() < damage_list[current_stage] && current_stage < desc_list.len)
		current_stage++
	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]

	// return amount of healing still leftover, can be used for other wounds
	return heal_amount

///Reopens the wound again
/datum/wound/proc/open_wound(initial_damage)
	damage += initial_damage
	bleed_timer += damage

	var/damage_per_wound = damage
	while(current_stage > 1 && damage_list[current_stage - 1] <= damage_per_wound)
		current_stage--

	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]

	// returns whether this wound can absorb the given amount of damage.
	// this will prevent large amounts of damage being trapped in less severe wound types
/datum/wound/proc/can_worsen(incoming_dmg_type, incoming_dmg)
	if (damage_type != incoming_dmg_type)
		return FALSE //incompatible damage types

	//with 1.5*, a shallow cut will be able to carry at most 30 damage,
	//37.5 for a deep cut
	//52.5 for a flesh wound, etc.
	var/max_wound_damage = 1.5 * src.damage_list[1]
	if (damage + incoming_dmg > max_wound_damage)
		return FALSE

	return TRUE

/** WOUND DEFINITIONS **/

//Mostly dead. Kill entirely or leave to generate a suitable internal?.
/proc/get_wound_type(type = CUT, damage)
	return null //no wound


/** INTERNAL BLEEDING **/
/datum/wound/internal_bleeding
	stages = list("severed artery" = 30, "cut artery" = 20, "damaged artery" = 10, "bruised artery" = 5)
	autoheal_cutoff = 5
