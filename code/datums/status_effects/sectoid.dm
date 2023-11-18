/datum/status_effect/mindmeld
	id = "drone enhancement"
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
	link_target.balloon_alert(link_target, "Enhancement inactive")
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
		link_target.remove_movespeed_modifier(MOVESPEED_ID_ENHANCEMENT)
		toggle_particles(FALSE)
		return
	link_target.adjust_mob_accuracy(accuracy_mod)
	link_target.maxHealth += health_mod
	link_target.add_movespeed_modifier(MOVESPEED_ID_ENHANCEMENT, TRUE, 0, NONE, FALSE, speed_mod) //todo replace the id with anew one
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
/datum/status_effect/mindmeld/proc/handle_stun(/mob/living/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	if(amount >= 3)
		return
	if(prob(stun_resistance))
		return COMPONENT_NO_STUN
