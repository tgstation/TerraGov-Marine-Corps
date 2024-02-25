
/datum/action/ability/activable/sectoid
	action_icon = 'icons/mob/psionic_icons.dmi'

// ***************************************
// *********** Mindmeld
// ***************************************
/datum/action/ability/activable/sectoid/mindmeld
	name = "Mindmeld"
	action_icon_state = "mindmeld"
	desc = "Merge minds with the target, empowering both."
	cooldown_duration = 60 SECONDS
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_MINDMELD,
	)
	var/mob/living/carbon/melded_mob
	///Range the linkees must be to each other to benefit
	var/max_range = 6
	///Projectile accuracy buff
	var/accuracy_mod = 25
	///Max health buff
	var/health_mod = 50
	///Movement speed buff
	var/speed_mod = -0.4
	///% chance to ignore stuns
	var/stun_resistance = 0

/datum/action/ability/activable/sectoid/mindmeld/remove_action(mob/living/carbon/carbon_owner)
	end_ability()
	return ..()

/datum/action/ability/activable/sectoid/mindmeld/can_use_action()
	var/mob/living/carbon/carbon_owner = owner
	if(melded_mob)
		return FALSE
	if(HAS_TRAIT(carbon_owner, TRAIT_MINDMELDED))
		return FALSE
	return ..()

/datum/action/ability/activable/sectoid/mindmeld/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	var/mob/living/carbon/carbon_target = A
	if(owner.faction != carbon_target.faction)
		if(!silent)
			A.balloon_alert(owner, "hostile!")
		return FALSE
	if(HAS_TRAIT(carbon_target, TRAIT_MINDMELDED))
		if(!silent)
			A.balloon_alert(owner, "already melded!")
		return FALSE
	if((A.z != owner.z) || !line_of_sight(owner, A, max_range))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/sectoid/mindmeld/use_ability(atom/target)
	var/mob/living/carbon/carbon_owner = owner
	melded_mob = target
	melded_mob.balloon_alert_to_viewers("mindmelded")
	owner.balloon_alert_to_viewers("mindmelded")
	playsound(melded_mob, 'sound/effects/off_guard_ability.ogg', 50)

	melded_mob.apply_status_effect(STATUS_EFFECT_MINDMEND, carbon_owner, max_range, accuracy_mod, health_mod, speed_mod, stun_resistance)
	carbon_owner.apply_status_effect(STATUS_EFFECT_MINDMEND, carbon_owner, max_range, accuracy_mod, health_mod, speed_mod, stun_resistance)
	RegisterSignal(melded_mob, COMSIG_MOB_DEATH, PROC_REF(end_ability))
	RegisterSignal(carbon_owner, COMSIG_MOB_DEATH, PROC_REF(end_ability))

	succeed_activate()
	add_cooldown()

/// Ends the ability if the Enhancement buff is removed.
/datum/action/ability/activable/sectoid/mindmeld/proc/end_ability()
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_owner = owner
	add_cooldown()
	carbon_owner.remove_status_effect(STATUS_EFFECT_MINDMEND)
	if(!melded_mob)
		return
	melded_mob.remove_status_effect(STATUS_EFFECT_MINDMEND)
	melded_mob = null

/datum/action/ability/activable/sectoid/mindmeld/greater
	name = "Greater Mindmeld"
	desc = "Merge minds with the target, greatly empowering both."
	max_range = 12
	accuracy_mod = 40
	health_mod = 70
	speed_mod = -0.5
	stun_resistance = 50

#define MINDFRAY_RANGE 8
/datum/action/ability/activable/sectoid/mindfray
	name = "Mindfray"
	action_icon_state = "mindfray"
	desc = "Muddles the mind of an enemy, making it harder for them to focus their aim for a while."
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_MINDFRAY,
	)
	///damage of this ability
	var/damage = 20

/datum/action/ability/activable/sectoid/mindfray/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	if(!line_of_sight(owner, A, 9))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > MINDFRAY_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	var/mob/living/carbon/carbon_target = A
	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/sectoid/mindfray/use_ability(atom/target)
	var/mob/living/carbon/carbon_target = target
	carbon_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 10 SECONDS)
	carbon_target.apply_status_effect(STATUS_EFFECT_CONFUSED, 40)
	carbon_target.apply_damage(damage, BURN, updating_health = TRUE)
	carbon_target.log_message("has been mindfrayed by [owner]", LOG_ATTACK, color="pink")
	carbon_target.balloon_alert_to_viewers("confused")
	playsound(carbon_target, 'sound/effects/off_guard_ability.ogg', 50)

	add_cooldown()
	succeed_activate()
	update_button_icon()

// ***************************************
// *********** Stasis
// ***************************************

#define SECTOID_STASIS_RANGE 7
/datum/action/ability/activable/sectoid/stasis
	name = "stasis"
	action_icon_state = "stasis"
	desc = "We surround a living thing with a powerful psionic field, temporarily disabling them and protecting them from all harm."
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_MOB_TARGET
	use_state_flags = ABILITY_TARGET_SELF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_STASIS,
	)
	///Duration of effect
	var/stasis_duration = 5 SECONDS
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/sectoid/stasis/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > SECTOID_STASIS_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, A, SECTOID_STASIS_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	var/mob/living/carbon/carbon_target = A
	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/sectoid/stasis/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	if(!do_after(owner, 0.5 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, target, BUSY_ICON_DANGER) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	var/mob/living/carbon/carbon_target = target
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)

	carbon_target.notransform = TRUE
	carbon_target.status_flags |= GODMODE
	ADD_TRAIT(carbon_target, TRAIT_HANDS_BLOCKED, REF(src))
	carbon_target.move_resist = MOVE_FORCE_OVERPOWERING
	carbon_target.add_atom_colour(COLOR_GRAY, TEMPORARY_COLOUR_PRIORITY)
	carbon_target.log_message("has been petrified by [owner] for [stasis_duration] ticks", LOG_ATTACK, color="pink")

	var/image/stone_overlay = image('icons/effects/64x64.dmi', null, "stasis_overlay", pixel_y = -4)
	stone_overlay.filters += filter(arglist(alpha_mask_filter(render_source="*[REF(carbon_target)]",flags=MASK_INVERSE)))

	var/mutable_appearance/mask = mutable_appearance()
	mask.appearance = carbon_target.appearance
	mask.render_target = "*[REF(carbon_target)]"
	mask.alpha = 125
	mask.pixel_y = 4
	stone_overlay.overlays += mask

	carbon_target.overlays += stone_overlay
	addtimer(CALLBACK(src, PROC_REF(end_effects), carbon_target, stone_overlay), stasis_duration)
	QDEL_NULL(particle_holder)
	add_cooldown()
	update_button_icon()
	succeed_activate()

///ends all combat-relazted effects
/datum/action/ability/activable/sectoid/stasis/proc/end_effects(mob/living/carbon/carbon_target, image/stone_overlay)
	carbon_target.notransform = FALSE
	carbon_target.status_flags &= ~GODMODE
	REMOVE_TRAIT(carbon_target, TRAIT_HANDS_BLOCKED, REF(src))
	carbon_target.move_resist = initial(carbon_target.move_resist)
	carbon_target.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_GRAY)
	carbon_target.overlays -= stone_overlay

// ***************************************
// *********** Reknit form
// ***************************************

#define SECTOID_REKNIT_RANGE 4
/datum/action/ability/activable/sectoid/reknit_form
	name = "Reknit Form"
	action_icon_state = "reknit_form"
	desc = "Flesh and bone runs like water at our will, healing horrendous damage with the power of our mind."
	cooldown_duration = 60 SECONDS
	target_flags = ABILITY_MOB_TARGET
	use_state_flags = ABILITY_TARGET_SELF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_REKNIT_FORM,
	)
	///damage of this ability
	var/reknit_duration = 3 SECONDS
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/sectoid/reknit_form/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!isliving(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > SECTOID_REKNIT_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, A, SECTOID_REKNIT_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE

/datum/action/ability/activable/sectoid/reknit_form/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	if(!do_after(owner, 0.5 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, target, BUSY_ICON_DANGER) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	var/mob/living/living_target = target
	living_target.apply_status_effect(STATUS_EFFECT_REKNIT_FORM, reknit_duration)
	QDEL_NULL(particle_holder)
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)
	add_cooldown()
	update_button_icon()
	succeed_activate()

/datum/action/ability/activable/sectoid/reknit_form/greater
	name = "Greater Reknit Form"
	action_icon_state = "greater_reknit_form"
	reknit_duration = 6 SECONDS

// ***************************************
// *********** Fuse
// ***************************************

#define SECTOID_FUSE_RANGE 6
/datum/action/ability/activable/sectoid/fuse
	name = "Fuse"
	action_icon_state = "fuse"
	desc = "We reach out with our mind to trigger an explosive device."
	cooldown_duration = 45 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_FUSE,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/sectoid/fuse/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if((A.z != owner.z) || get_dist(owner, A) > SECTOID_FUSE_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, A, SECTOID_FUSE_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE

/datum/action/ability/activable/sectoid/fuse/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	if(!do_after(owner, 0.5 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, target, BUSY_ICON_DANGER) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	QDEL_NULL(particle_holder)
	var/obj/item/explosive/grenade/grenade_target
	if(isgrenade(target))
		grenade_target = target
	else
		grenade_target = locate(/obj/item/explosive/grenade) in target.GetAllContents()
		if(!grenade_target)
			target.balloon_alert(owner, "no grenade found")
			return fail_activate()

	grenade_target.activate(owner)
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)
	add_cooldown()
	update_button_icon()
	succeed_activate()

// ***************************************
// *********** Psionic Interact
// ***************************************

/datum/action/ability/activable/psionic_interact
	name = "Telekinesis"
	action_icon_state = "telekinesis"
	action_icon = 'icons/mob/psionic_icons.dmi'
	desc = "We manipulate things from a distance."
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_MOB_TARGET
	use_state_flags = ABILITY_TARGET_SELF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_TELEKINESIS,
	)
	///Ability range
	var/range = 9
	///Power of psi interactions
	var/psi_strength = 2
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/psionic_interact/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if((A.z != owner.z) || get_dist(owner, A) > range)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, A, range))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE

/datum/action/ability/activable/psionic_interact/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	if(!do_after(owner, 0.5 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, target, BUSY_ICON_DANGER) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	QDEL_NULL(particle_holder)
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)

	var/list/outcome = target.psi_act(psi_strength, owner)
	if(!outcome)
		return fail_activate()

	add_cooldown(outcome[1])
	succeed_activate(outcome[2])
	update_button_icon()


/obj/machinery/door/psi_act(psi_power, mob/living/user)
	if(density)
		open(TRUE)
	else
		close(TRUE)
	return list(0.1 SECONDS, 5)

/obj/machinery/door/airlock/psi_act(psi_power, mob/living/user)
	if(operating)
		to_chat(user, span_warning("The airlock is already in motion."))
		return
	if(welded)
		to_chat(user, span_warning("The airlock is welded shut."))
		return
	if(locked)
		to_chat(user, span_warning("The airlock's bolts prevent it from being forced."))
		return
	if(psi_power < PSIONIC_INTERACTION_STRENGTH_STANDARD && hasPower())
		to_chat(user, span_warning("The airlock's motors resist your efforts to force it."))
		return

	return ..()

/obj/machinery/door/firedoor/psi_act(psi_power, mob/living/user)
	if(operating)
		to_chat(user, span_warning("The firelock is already in motion."))
		return
	if(blocked)
		to_chat(user, span_warning("The firelock is welded shut."))
		return

	return ..()

/obj/machinery/button/psi_act(psi_power, mob/living/user)
	pulsed()
	return list(0.1 SECONDS, 1)

/obj/item/psi_act(psi_power, mob/living/user)
	if(user.a_intent == INTENT_HELP)
		throw_at(user, 4 + psi_power, psi_power, user, TRUE)
	else
		var/target = get_turf_in_angle(Get_Angle(user, src), src, 7)
		throw_at(target, 4 + psi_power, psi_power, user, TRUE)
	return list(3 SECONDS, 10)

// ***************************************
// *********** Reanimate
// ***************************************

#define SECTOID_REANIMATE_RANGE 4
#define SECTOID_REANIMATE_CHANNEL_TIME 1.5 SECONDS
/datum/action/ability/activable/sectoid/reanimate
	name = "Reanimate"
	action_icon_state = "reanimate"
	desc = "With our psionic strength we turn the dead into our puppet, or revive a fallen ally."
	cooldown_duration = 60 SECONDS
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_REANIMATE,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///list of
	var/list/zombie_list = list()

/datum/action/ability/activable/sectoid/reanimate/give_action(mob/living/L)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(kill_zombies))

/datum/action/ability/activable/sectoid/reanimate/remove_action(mob/living/carbon/carbon_owner)
	kill_zombies()
	return ..()

/datum/action/ability/activable/sectoid/reanimate/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/human_target = A
	if(!istype(A))
		if(!silent)
			human_target.balloon_alert(owner, "Invalid target")
		return FALSE
	if(human_target.stat != DEAD)
		if(!silent)
			human_target.balloon_alert(owner, "Still alive!")
		return FALSE
	if((human_target.z != owner.z) || get_dist(owner, human_target) > SECTOID_REANIMATE_RANGE)
		if(!silent)
			human_target.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, human_target, SECTOID_REANIMATE_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE

/datum/action/ability/activable/sectoid/reanimate/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	target.beam(owner, "drain_life", time = SECTOID_REANIMATE_CHANNEL_TIME, maxdistance = 10)
	target.add_filter("psi_reanimation", 3, outline_filter(1, COLOR_STRONG_MAGENTA))

	if(!do_after(owner, SECTOID_REANIMATE_CHANNEL_TIME, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, target, BUSY_ICON_DANGER) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	var/mob/living/carbon/human/human_target = target
	if(human_target.faction == owner.faction && !(HAS_TRAIT(human_target, TRAIT_UNDEFIBBABLE)))
		human_target.revive_to_crit(TRUE)
		target.remove_filter("psi_reanimation")
	else if(ishumanbasic(human_target))
		human_target.revive_to_crit(FALSE, FALSE)
		human_target.set_species("Psi zombie")
		human_target.faction = owner.faction
		human_target.offer_mob()
		zombie_list += human_target
		RegisterSignal(human_target, COMSIG_MOB_DEATH, PROC_REF(remove_zombie))
		var/obj/item/radio/headset/mainship/radio = human_target.wear_ear
		if(istype(radio))
			radio.safety_protocol(src)
	else
		owner.balloon_alert(owner, "Unrevivable")

	QDEL_NULL(particle_holder)
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)
	add_cooldown()
	update_button_icon()
	succeed_activate()

/datum/action/ability/activable/sectoid/reanimate/proc/remove_zombie(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	zombie_list -= source

/datum/action/ability/activable/sectoid/reanimate/proc/kill_zombies(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	for(var/mob/living/carbon/human/zombie AS in zombie_list)
		zombie.gib()
	zombie_list = list()
