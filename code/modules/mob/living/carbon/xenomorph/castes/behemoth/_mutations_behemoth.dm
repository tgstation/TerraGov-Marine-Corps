// I need this to load first because I wanna use the defines here, which is why it has an underscore in the file name.

// ***************************************
// *********** SHELL: Foundations
// ***************************************
#define FOUNDATIONS_MAXIMUM_AMOUNT 2 // Maximum amount of Earth Pillars that we can create with this mutation active.
#define FOUNDATIONS_HEALTH_REDUCTION 0.4 // as a percentage

/datum/mutation_upgrade/shell/foundations
	name = "Foundations"
	desc = "You can now create additional Earth Pillars, but their maximum health is reduced."

/datum/mutation_upgrade/shell/foundations/get_desc_for_alert(new_amount)
	if(!new_amount)
		return
	return "You can now create up to [FOUNDATIONS_MAXIMUM_AMOUNT] Earth Pillars, but their maximum health is reduced by [FOUNDATIONS_HEALTH_REDUCTION * 100]%."

/datum/mutation_upgrade/shell/foundations/on_mutation_enabled()
	. = ..()
	for(var/datum/action/ability/activable/xeno/earth_riser/riser_action in xenomorph_owner.actions)
		riser_action.creation_limit = FOUNDATIONS_MAXIMUM_AMOUNT
		riser_action.update_button_icon()

/datum/mutation_upgrade/shell/foundations/on_mutation_disabled()
	. = ..()
	for(var/datum/action/ability/activable/xeno/earth_riser/riser_action in xenomorph_owner.actions)
		riser_action.creation_limit = initial(riser_action.creation_limit)
		while(length(riser_action.active_pillars) > riser_action.creation_limit) // Destroys excess pillars.
			riser_action.alternate_action_activate()
		riser_action.update_button_icon()


// ***************************************
// *********** SPUR: Earth's Might
// ***************************************
#define EARTH_MIGHT_ADDITIONAL_DAMAGE 1.3 // 30%
#define EARTH_MIGHT_PILLAR_DAMAGE 0.5 // 50%

/datum/mutation_upgrade/spur/earth_might
	name = "Earth's Might"
	desc = "While holding an Earth Pillar, Geocrush will deal additional damage, but damage the pillar in the process."

/datum/mutation_upgrade/spur/earth_might/get_desc_for_alert(new_amount)
	if(!new_amount)
		return
	return "While holding an Earth Pillar, Geocrush will deal [(EARTH_MIGHT_ADDITIONAL_DAMAGE - 1) * 100]% more damage, but it will take [EARTH_MIGHT_PILLAR_DAMAGE * 100]% of its maximum health as damage."

/datum/mutation_upgrade/spur/earth_might/on_mutation_enabled()
	. = ..()
	for(var/datum/action/ability/activable/xeno/geocrush/geocrush_action in xenomorph_owner.actions)
		geocrush_action.spur_mutation = TRUE

/datum/mutation_upgrade/spur/earth_might/on_mutation_disabled()
	. = ..()
	for(var/datum/action/ability/activable/xeno/geocrush/geocrush_action in xenomorph_owner.actions)
		geocrush_action.spur_mutation = FALSE


// ***************************************
// *********** VEIL: Guided Claim
// ***************************************
#define GUIDED_CLAIM_ADDITIONAL_RANGE 3

/datum/mutation_upgrade/veil/guided_claim
	name = "Guided Claim"
	desc = "Seize's range is increased."

/datum/mutation_upgrade/veil/guided_claim/get_desc_for_alert(new_amount)
	if(!new_amount)
		return
	return "Seize's range is increased by [GUIDED_CLAIM_ADDITIONAL_RANGE] tiles."

/datum/mutation_upgrade/veil/guided_claim/on_mutation_enabled()
	. = ..()
	for(var/datum/action/ability/activable/xeno/behemoth_seize/seize_action in xenomorph_owner.actions)
		seize_action.action_range += GUIDED_CLAIM_ADDITIONAL_RANGE

/datum/mutation_upgrade/veil/guided_claim/on_mutation_disabled()
	. = ..()
	for(var/datum/action/ability/activable/xeno/behemoth_seize/seize_action in xenomorph_owner.actions)
		seize_action.action_range -= GUIDED_CLAIM_ADDITIONAL_RANGE
