/datum/sex_action
	var/abstract_type = /datum/sex_action
	var/name = "Zodomize"
	/// Time to do the act, modified by up to 2.5x speed by the speed toggle
	var/do_time = 3.3 SECONDS
	/// Whether the act is continous and will be done on repeat
	var/continous = TRUE
	/// Stamina cost per action, modified by up to 2.5x cost by the force toggle
	var/stamina_cost = 0.5
	/// Whether the action requires both participants to be on the same tile
	var/check_same_tile = FALSE //changing this to false by request, just use it if it really needs to be in same tile -- vide
	/// Whether the same tile check can be bypassed by an aggro grab on the person
	var/aggro_grab_instead_same_tile = TRUE
	/// Whether the action is forbidden from being done while incapacitated (stun, handcuffed)
	var/check_incapacitated = TRUE
	/// Whether the action requires an aggressive grab on the victim
	var/require_grab = FALSE
	/// If a grab is required, this is the required state of it
	var/required_grab_state = GRAB_AGGRESSIVE
	///determines if it's heal-sex, only partnered sex can heal, masturbation wont work.
	var/heal_sex = TRUE

/datum/sex_action/proc/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	return TRUE

/datum/sex_action/proc/on_start(mob/living/carbon/user, mob/living/carbon/target)

/datum/sex_action/proc/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	return

/datum/sex_action/proc/on_finish(mob/living/carbon/user, mob/living/carbon/target)

/datum/sex_action/proc/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	return FALSE

/datum/sex_action/proc/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	return TRUE
