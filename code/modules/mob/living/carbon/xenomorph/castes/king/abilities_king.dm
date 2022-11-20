// ***************************************
// *********** Nightfall
// ***************************************

/datum/action/xeno_action/activable/nightfall
	name = "Nightfall"
	action_icon_state = "nightfall"
	ability_name = "Nightfall"
	mechanics_text = "Shut down all electrical lights nearby for 10 seconds."
	cooldown_timer = 45 SECONDS
	plasma_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_NIGHTFALL,
	)
	/// How far nightfall will have an effect
	var/range = 12
	/// How long till the lights go on again
	var/duration = 10 SECONDS

/datum/action/xeno_action/activable/nightfall/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough mental strength to shut down lights again."))
	return ..()

/datum/action/xeno_action/activable/nightfall/use_ability()
	playsound(owner, 'sound/magic/nightfall.ogg', 50, 1)
	succeed_activate()
	add_cooldown()
	for(var/atom/light AS in GLOB.nightfall_toggleable_lights)
		if(isnull(light.loc) || (owner.loc.z != light.loc.z) || (get_dist(owner, light) >= range))
			continue
		light.turn_light(null, FALSE, duration, TRUE, TRUE, TRUE)


// ***************************************
// *********** Petrify
// ***************************************
#define PETRIFY_RANGE 5
#define PETRIFY_DURATION 7 SECONDS
#define PETRIFY_WINDUP_TIME 3 SECONDS
/datum/action/xeno_action/petrify
	name = "Petrify"
	action_icon_state = "stomp"
	mechanics_text = "After a windup, petrifies all humans looking at you. While petrified humans are immune to damage, but also can't attack."
	ability_name = "petrify"
	plasma_cost = 100
	cooldown_timer = 30 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PETRIFY,
	)

/datum/action/xeno_action/petrify/can_use_action(silent, override_flags)
	. = ..()
	if(LAZYACCESS(owner.do_actions, src))
		owner.balloon_alert(owner, "already busy")
		return FALSE

/datum/action/xeno_action/petrify/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	var/obj/effect/overlay/eye/eye = new // tivi todo
	owner.vis_contents -= eye
	if(!do_after(owner, PETRIFY_WINDUP_TIME, FALSE, owner, BUSY_ICON_DANGER))
		owner.vis_contents -= eye
		return
	owner.vis_contents -= eye

	var/list/mob/living/carbon/human/humans = list()
	for(var/mob/living/carbon/human/human in view(PETRIFY_RANGE, X))
		humans += human
		human.notransform = TRUE
		human.status_flags |= GODMODE
		human.add_atom_colour(COLOR_GRAY, TEMPORARY_COLOUR_PRIORITY)
		human.log_message("has been petrified by [owner] for [PETRIFY_DURATION] ticks", LOG_ATTACK, color="pink")
		human.balloon_alert(human, "petrified") // tivi todo remove
	addtimer(CALLBACK(src, .proc/end_visuals), 5, TIMER_CLIENT_TIME)
	if(!length(humans))
		return
	addtimer(CALLBACK(src, .proc/end_effects, humans), PETRIFY_DURATION)
	add_cooldown()
	succeed_activate()

///ends all combat-relazted effects
/datum/action/xeno_action/petrify/proc/end_effects(list/humans)
	for(var/mob/living/carbon/human/human AS in humans)
		human.notransform = FALSE
		human.status_flags &= ~GODMODE
		human.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_GRAY)

///cleans up visual effects
/datum/action/xeno_action/petrify/proc/end_visuals()

// ***************************************
// *********** Off-Guard
// ***************************************
/datum/action/xeno_action/activable/off_guard
	name = "Off-guard"
	action_icon_state = "stomp"
	mechanics_text = "After a windup, petrifies all humans looking at you. While petrified humans are immune to damage, but also can't attack."
	ability_name = "off guard"
	plasma_cost = 100
	cooldown_timer = 20 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_OFFGUARD,
	)


/datum/action/xeno_action/activable/off_guard/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!ishuman(A))
		if(!silent)
			A.balloon_alert(owner, "not human")
		return FALSE

/datum/action/xeno_action/activable/off_guard/use_ability(atom/target)
	var/mob/living/carbon/human/human_target = target
	human_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 20)
	human_target.log_message("has been off-guarded by [owner]", LOG_ATTACK, color="pink")
	human_target.balloon_alert_to_viewers("confused")

	add_cooldown()
	succeed_activate()


// ***************************************
// *********** Zero form energy beam
// ***************************************
#define ZEROFORM_BEAM_RANGE 10
#define ZEROFORM_CHARGE_TIME 2 SECONDS
/datum/action/xeno_action/zero_form_beam
	name = "Zero-Form Energy Beam"
	action_icon_state = "stomp"
	mechanics_text = "After a windup, petrifies all humans looking at you. While petrified humans are immune to damage, but also can't attack."
	ability_name = "zero form energy beam"
	plasma_cost = 50
	cooldown_timer = 10 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ZEROFORMBEAM,
	)
	///list of turfs we are hitting while shooting our beam
	var/list/turf/targets
	///ref to beam that is currently active
	var/datum/beam/beam
	///particle holder for the particle visual effects
	var/obj/effect/abstract/particle_holder/particles
	// tivi todo
	var/datum/looping_sound/sound_loop
	///ref to looping timer for the fire loop
	var/timer_ref

/datum/action/xeno_action/zero_form_beam/New(Target)
	. = ..()
	sound_loop = new

/obj/effect/ebeam/zeroform/Initialize()
	. = ..()
	alpha = 0
	animate(src, alpha = 255, time = ZEROFORM_CHARGE_TIME)

/datum/action/xeno_action/zero_form_beam/can_use_action(silent, override_flags)
	. = ..()
	if(LAZYACCESS(owner.do_actions, src))
		if(!silent)
			owner.balloon_alert(owner, "already busy")
		return FALSE

/datum/action/xeno_action/zero_form_beam/action_activate()
	if(timer_ref)
		stop_beaming()
		return

	var/turf/check_turf = get_step(owner, owner.dir)
	LAZYINITLIST(targets)
	while(check_turf && length(targets) < ZEROFORM_BEAM_RANGE)
		targets += check_turf
		check_turf = get_step(check_turf, owner.dir)
	if(!LAZYLEN(targets))
		return

	particles = new(owner, /particles/zero_form)
	beam = owner.beam(targets[length(targets)], "plasmabeam", beam_type = /obj/effect/ebeam/zeroform)
	if(!do_after(owner, ZEROFORM_CHARGE_TIME, FALSE, owner, BUSY_ICON_DANGER))
		QDEL_NULL(beam)
		QDEL_NULL(particles)
		targets = null
		return fail_activate()
	RegisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE), .proc/stop_beaming)
	execute_attack()

/// recursive proc for firing the actual beam
/datum/action/xeno_action/zero_form_beam/proc/execute_attack()
	if(!can_use_action(TRUE))
		stop_beaming()
		return
	succeed_activate()
	for(var/turf/target AS in targets)
		for(var/mob/living/carbon/human/blasted in target)
			if(blasted.stat == DEAD)
				continue
			blasted.take_overall_damage(0, 15, updating_health = TRUE)
	addtimer(CALLBACK(src, .proc/execute_attack), 3, TIMER_STOPPABLE)

///ends and cleans up beam
/datum/action/xeno_action/zero_form_beam/proc/stop_beaming()
	SIGNAL_HANDLER
	QDEL_NULL(beam)
	QDEL_NULL_IN(src, particles, (particles.particles.lifespan + particles.particles.fade))
	deltimer(timer_ref)
	timer_ref = null
	targets = null
	add_cooldown()

/particles/zero_form


// ***************************************
// *********** Psychic Summon
// ***************************************
/datum/action/xeno_action/psychic_summon
	name = "Psychic Summon"
	action_icon_state = "stomp"
	mechanics_text = "Summons all xenos in a hive to the caller's location, uses all plasma to activate."
	ability_name = "Psychic summon"
	plasma_cost = 900 //uses all an young kings plasma
	cooldown_timer = 10 MINUTES
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HIVE_SUMMON,
	)

/datum/action/xeno_action/activable/psychic_summon/on_cooldown_finish()
	to_chat(owner, span_warning("The hives power swells. We may summon our sisters again."))
	return ..()

/datum/action/xeno_action/psychic_summon/can_use_action(silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(length(X.hive.get_all_xenos()) <= 1)
		if(!silent)
			owner.balloon_alert(owner, "noone to call")
		return FALSE

/datum/action/xeno_action/psychic_summon/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	log_game("[key_name(owner)] has begun summoning hive in [AREACOORD(owner)]")
	xeno_message("King: \The [owner] has begun a psychic summon in <b>[get_area(owner)]</b>!", hivenumber = X.hivenumber)
	var/list/allxenos = X.hive.get_all_xenos()
	for(var/mob/living/carbon/xenomorph/sister AS in allxenos)
		sister.add_filter("summonoutline", 2, outline_filter(1, COLOR_VIOLET))

	if(!do_after(X, 10 SECONDS, FALSE, X, BUSY_ICON_HOSTILE))
		for(var/mob/living/carbon/xenomorph/sister AS in allxenos)
			sister.remove_filter("summonoutline")
		return fail_activate()

	for(var/mob/living/carbon/xenomorph/sister AS in allxenos)
		sister.remove_filter("summonoutline")
		sister.forceMove(get_turf(X))
	log_game("[key_name(owner)] has summoned hive ([length(allxenos)] Xenos) in [AREACOORD(owner)]")
	X.emote("roar")

	add_cooldown()
	succeed_activate()
