/datum/status_effect/mindmeld
	id = "mindmeld"
	duration = -1
	tick_interval = 2 SECONDS
	alert_type = null
	/// Used to track who is the owner of this buff.
	var/mob/living/carbon/link_target
	/// Used to track who is giving this buff to the owner.
	var/mob/living/carbon/link_partner
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// If the target xeno was within range.
	var/was_within_range = TRUE
	///Range the linkees must be to each other to benefit
	var/max_range = 6
	///Projectile accuracy buff
	var/accuracy_mod = 0
	///Max health buff
	var/health_mod = 0
	///Movement speed buff
	var/speed_mod = 0
	///% chance to ignore stuns
	var/stun_resistance = 0

/datum/status_effect/mindmeld/on_creation(mob/living/new_owner, mob/living/carbon/partner, new_max_range, new_accuracy_mod, new_health_mod, new_speed_mod,  new_stun_resistance)
	link_target = new_owner
	link_partner = partner
	ADD_TRAIT(link_target, TRAIT_MINDMELDED, TRAIT_STATUS_EFFECT(id))
	max_range = new_max_range
	accuracy_mod = new_accuracy_mod
	health_mod = new_health_mod
	speed_mod = new_speed_mod
	if(new_stun_resistance)
		stun_resistance = new_stun_resistance
		RegisterSignals(link_target, list(
			COMSIG_LIVING_STATUS_STUN,
			COMSIG_LIVING_STATUS_KNOCKDOWN,
			COMSIG_LIVING_STATUS_PARALYZE,
			COMSIG_LIVING_STATUS_UNCONSCIOUS,
			COMSIG_LIVING_STATUS_CONFUSED,
			COMSIG_LIVING_STATUS_STAGGER,
		), PROC_REF(handle_stun))
	INVOKE_ASYNC(link_target, TYPE_PROC_REF(/mob, emote), "roar2")
	toggle_buff(TRUE)
	return ..()

/datum/status_effect/mindmeld/on_remove()
	link_target.balloon_alert(link_target, "mindmeld inactive")
	UnregisterSignal(link_target, COMSIG_MOB_DEATH)
	toggle_buff(FALSE)
	return ..()

/datum/status_effect/mindmeld/tick()
	var/within_range = get_dist(link_target, link_partner) <= max_range
	if(within_range != was_within_range)
		was_within_range = within_range
		toggle_buff(was_within_range)

/// Toggles the buff on or off.
/datum/status_effect/mindmeld/proc/toggle_buff(toggle)
	if(!toggle)
		link_target.adjust_mob_accuracy(-accuracy_mod)
		link_target.maxHealth -= health_mod
		link_target.remove_movespeed_modifier(MOVESPEED_ID_MINDMELD)
		toggle_particles(FALSE)
		return
	link_target.adjust_mob_accuracy(accuracy_mod)
	link_target.maxHealth += health_mod
	link_target.add_movespeed_modifier(MOVESPEED_ID_MINDMELD, TRUE, 0, NONE, FALSE, speed_mod) //todo replace the id with anew one
	toggle_particles(TRUE)

/// Toggles particles on or off, adjusting their positioning to fit the buff's owner.
/datum/status_effect/mindmeld/proc/toggle_particles(toggle)
	if(toggle)
		link_target.add_filter("[id]", 3, outline_filter(1, LIGHT_COLOR_BLUE))
	else
		link_target.remove_filter("[id]")

/// Removes the status effect on death.
/datum/status_effect/mindmeld/proc/handle_stun(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	if(amount >= 3)
		return
	if(prob(stun_resistance))
		return COMPONENT_NO_STUN

// ***************************************
// *********** Reknit form
// ***************************************
/datum/status_effect/reknit_form
	id = "reknit_form"
	tick_interval = 0.5 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/reknit_form

/datum/status_effect/reknit_form/on_creation(mob/living/new_owner, set_duration)
	owner = new_owner
	duration = set_duration
	owner.add_filter("[id]", 0, outline_filter(2, LIGHT_COLOR_EMISSIVE_GREEN))
	return ..()

/datum/status_effect/reknit_form/on_remove()
	. = ..()
	owner.remove_filter("[id]")

/datum/status_effect/reknit_form/tick()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.reagent_shock_modifier -= PAIN_REDUCTION_VERY_HEAVY //oof ow ouch
		for(var/datum/limb/limb_to_fix AS in human_owner.limbs)
			if(limb_to_fix.limb_status & (LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED))
				if((prob(50) || limb_to_fix.brute_dam > limb_to_fix.min_broken_damage))
					continue
				limb_to_fix.remove_limb_flags(LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED)
				limb_to_fix.add_limb_flags(LIMB_REPAIRED)
				break

	owner.adjustCloneLoss(-3)
	owner.adjustOxyLoss(-5)
	owner.heal_overall_damage(5, 5)
	owner.adjustToxLoss(-3)

/atom/movable/screen/alert/status_effect/reknit_form
	name = "Reknit form"
	desc = "Your health is being restored."
	icon_state = "xeno_rejuvenate"
