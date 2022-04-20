
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
	///internal wounds can only be fixed through surgery
	var/internal = FALSE
	// maximum stage at which bleeding should still happen, counted from the right rather than the left of the list
	// 1 means all stages except the last should bleed
	var/max_bleeding_stage = 1
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

	max_bleeding_stage = desc_list.len - max_bleeding_stage

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
	if(internal && !heals_internal)
		// heal nothing
		return heal_amount

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

//Note that the MINIMUM damage before a wound can be applied should correspond to
//the damage amount for the stage with the same name as the wound.
//e.g. /datum/wound/cut/deep should only be applied for 15 damage and up,
//because in it's stages list, "deep cut" = 15.
/proc/get_wound_type(type = CUT, damage)
	switch(type)
		if(CUT)
			switch(damage)
				if(70 to INFINITY)
					return /datum/wound/cut/massive
				if(60 to 70)
					return /datum/wound/cut/gaping_big
				if(50 to 60)
					return /datum/wound/cut/gaping
				if(25 to 50)
					return /datum/wound/cut/flesh
				if(15 to 25)
					return /datum/wound/cut/deep
				if(0 to 15)
					return /datum/wound/cut/small
		if(BRUISE)
			return /datum/wound/bruise
		if(BURN)
			switch(damage)
				if(50 to INFINITY)
					return /datum/wound/burn/carbonised
				if(40 to 50)
					return /datum/wound/burn/deep
				if(30 to 40)
					return /datum/wound/burn/severe
				if(15 to 30)
					return /datum/wound/burn/large
				if(0 to 15)
					return /datum/wound/burn/moderate
	return null //no wound

/** CUTS **/
// link wound descriptions to amounts of damage

/datum/wound/cut/small
	max_bleeding_stage = 2
	stages = list("ugly ripped cut" = 20, "ripped cut" = 10, "cut" = 5, "healing cut" = 2, "small scab" = 0)
	damage_type = CUT

/datum/wound/cut/deep
	max_bleeding_stage = 3
	stages = list("ugly deep ripped cut" = 25, "deep ripped cut" = 20, "deep cut" = 15, "clotted cut" = 8, "scab" = 2, "fresh skin" = 0)
	damage_type = CUT

/datum/wound/cut/flesh
	max_bleeding_stage = 4
	stages = list("ugly ripped flesh wound" = 35, "ugly flesh wound" = 30, "flesh wound" = 25, "blood soaked clot" = 15, "large scab" = 5, "fresh skin" = 0)
	damage_type = CUT

/datum/wound/cut/gaping
	max_bleeding_stage = 2
	stages = list("gaping wound" = 50, "large blood soaked clot" = 25, "large clot" = 15, "small angry scar" = 5, "small straight scar" = 0)
	damage_type = CUT

/datum/wound/cut/gaping_big
	max_bleeding_stage = 2
	stages = list("big gaping wound" = 60, "healing gaping wound" = 40, "large angry scar" = 10, "large straight scar" = 0)
	damage_type = CUT

datum/wound/cut/massive
	max_bleeding_stage = 2
	stages = list("massive wound" = 70, "massive healing wound" = 50, "massive angry scar" = 10,  "massive jagged scar" = 0)
	damage_type = CUT

/** BRUISES **/
/datum/wound/bruise
	stages = list("monumental bruise" = 80, "huge bruise" = 50, "large bruise" = 30,\
				"moderate bruise" = 20, "small bruise" = 10, "tiny bruise" = 5)
	max_bleeding_stage = 3
	autoheal_cutoff = 30
	damage_type = BRUISE

/** BURNS **/
/datum/wound/burn/moderate
	stages = list("ripped burn" = 10, "moderate burn" = 5, "healing moderate burn" = 2, "fresh skin" = 0)
	damage_type = BURN

/datum/wound/burn/large
	stages = list("ripped large burn" = 20, "large burn" = 15, "healing large burn" = 5, "fresh skin" = 0)
	damage_type = BURN

/datum/wound/burn/severe
	stages = list("ripped severe burn" = 35, "severe burn" = 30, "healing severe burn" = 10, "burn scar" = 0)
	damage_type = BURN

/datum/wound/burn/deep
	stages = list("ripped deep burn" = 45, "deep burn" = 40, "healing deep burn" = 15,  "large burn scar" = 0)
	damage_type = BURN

/datum/wound/burn/carbonised
	stages = list("carbonised area" = 50, "healing carbonised area" = 20, "massive burn scar" = 0)
	damage_type = BURN

/** INTERNAL BLEEDING **/
/datum/wound/internal_bleeding
	internal = 1
	stages = list("severed artery" = 30, "cut artery" = 20, "damaged artery" = 10, "bruised artery" = 5)
	autoheal_cutoff = 5
	max_bleeding_stage = 0	//all stages bleed. It's called internal bleeding after all.

/** EXTERNAL ORGAN LOSS **/
/datum/wound/lost_limb
	damage_type = CUT
	stages = list("ripped stump" = 65, "bloody stump" = 50, "clotted stump" = 25, "scarred stump" = 0)
	max_bleeding_stage = 3

/datum/wound/lost_limb/small
	stages = list("ripped stump" = 40, "bloody stump" = 30, "clotted stump" = 15, "scarred stump" = 0)
