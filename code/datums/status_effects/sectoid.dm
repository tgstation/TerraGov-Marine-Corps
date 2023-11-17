/datum/status_effect/mindmeld
	id = "drone enhancement"
	duration = -1
	tick_interval = 0
	alert_type = null
	/// Used to track who is giving this buff to the owner.
	var/mob/living/carbon/linkee //can probs kill this unless I readd the range check
	/// Used to track who is the owner of this buff.
	var/mob/living/carbon/link_target
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// References the Enhancement action and its vars.
	var/datum/action/ability/activable/mindmeld/mindmeld_action
	/// If the target xeno was within range.
	var/was_within_range = TRUE

	var/health_bonus = 50

/datum/status_effect/mindmeld/on_creation(mob/living/new_owner, mob/living/carbon/new_target, datum/action/ability/activable/mindmeld/new_mindmeld_action)
	link_target = new_owner
	linkee = new_target
	mindmeld_action = new_mindmeld_action
	ADD_TRAIT(link_target, TRAIT_MINDMELDED, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(link_target, COMSIG_MOB_DEATH, PROC_REF(handle_death))
	INVOKE_ASYNC(link_target, TYPE_PROC_REF(/mob, emote), "roar2")
	toggle_buff(TRUE)
	return ..()

/datum/status_effect/mindmeld/on_remove()
	link_target.balloon_alert(link_target, "Enhancement inactive")
	UnregisterSignal(link_target, COMSIG_MOB_DEATH)
	toggle_buff(FALSE)
	return ..()

///datum/status_effect/mindmeld/tick()
//	var/within_range = get_dist(link_target, linkee) <= DRONE_ESSENCE_LINK_RANGE
//	if(within_range != was_within_range)
//		was_within_range = within_range
//		toggle_buff(was_within_range)

/// Toggles the buff on or off.
/datum/status_effect/mindmeld/proc/toggle_buff(toggle)
	if(!toggle)
		link_target.maxHealth -= mindmeld_action.health_mod
		link_target.remove_movespeed_modifier(MOVESPEED_ID_ENHANCEMENT)
		toggle_particles(FALSE)
		return
	link_target.maxHealth += mindmeld_action.health_mod
	link_target.add_movespeed_modifier(MOVESPEED_ID_ENHANCEMENT, TRUE, 0, NONE, FALSE, mindmeld_action.speed_addition) //todo replace the id with anew one
	toggle_particles(TRUE)

/// Toggles particles on or off, adjusting their positioning to fit the buff's owner.
/datum/status_effect/mindmeld/proc/toggle_particles(toggle)
	var/particle_x = abs(link_target.pixel_x)
	if(!toggle)
		QDEL_NULL(particle_holder)
		return
	particle_holder = new(link_target, /particles/drone_enhancement)
	particle_holder.pixel_x = particle_x
	particle_holder.pixel_y = -3

/// Removes the status effect on death.
/datum/status_effect/mindmeld/proc/handle_death()
	SIGNAL_HANDLER
	mindmeld_action.end_ability()
