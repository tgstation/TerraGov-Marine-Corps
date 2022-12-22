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
#define PETRIFY_RANGE 7
#define PETRIFY_DURATION 6 SECONDS
#define PETRIFY_WINDUP_TIME 2 SECONDS
/datum/action/xeno_action/petrify
	name = "Petrify"
	action_icon_state = "petrify"
	mechanics_text = "After a windup, petrifies all humans looking at you. While petrified humans are immune to damage, but also can't attack."
	ability_name = "petrify"
	plasma_cost = 100
	cooldown_timer = 30 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PETRIFY,
	)

/datum/action/xeno_action/petrify/action_activate()
	var/obj/effect/overlay/eye/eye = new
	owner.vis_contents += eye
	flick("eye_opening", eye)
	playsound(owner, 'sound/effects/petrify_charge.ogg', 50)
	if(!do_after(owner, PETRIFY_WINDUP_TIME, FALSE, owner, BUSY_ICON_DANGER))
		flick("eye_closing", eye)
		addtimer(CALLBACK(src, .proc/remove_eye, eye), 7, TIMER_CLIENT_TIME)
		return
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)
	var/list/mob/living/carbon/human/humans = list()
	for(var/mob/living/carbon/human/human in view(PETRIFY_RANGE, owner.loc))
		if(is_blind(human))
			continue
		humans += human
		human.notransform = TRUE
		human.status_flags |= GODMODE
		human.add_atom_colour(COLOR_GRAY, TEMPORARY_COLOUR_PRIORITY)
		ADD_TRAIT(human, TRAIT_HANDS_BLOCKED, REF(src))
		human.move_resist = MOVE_FORCE_OVERPOWERING
		human.log_message("has been petrified by [owner] for [PETRIFY_DURATION] ticks", LOG_ATTACK, color="pink")
		var/image/stone_overlay = image('icons/effects/effects.dmi', null, "petrified_overlay")
		stone_overlay.filters += filter(arglist(alpha_mask_filter(render_source="*[REF(human)]",flags=MASK_INVERSE)))
		var/mutable_appearance/mask = mutable_appearance()
		mask.appearance = human.appearance
		mask.render_target = "*[REF(human)]"
		mask.alpha = 125
		stone_overlay.overlays += mask
		human.overlays += stone_overlay
		humans[human] = stone_overlay

	if(!length(humans))
		flick("eye_closing", eye)
		addtimer(CALLBACK(src, .proc/remove_eye, eye), 7, TIMER_CLIENT_TIME)
		return
	addtimer(CALLBACK(src, .proc/remove_eye, eye), 10, TIMER_CLIENT_TIME)
	flick("eye_explode", eye)
	addtimer(CALLBACK(src, .proc/end_effects, humans), PETRIFY_DURATION)
	add_cooldown()
	succeed_activate()

///ends all combat-relazted effects
/datum/action/xeno_action/petrify/proc/end_effects(list/humans)
	for(var/mob/living/carbon/human/human AS in humans)
		human.notransform = FALSE
		human.status_flags &= ~GODMODE
		human.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_GRAY)
		REMOVE_TRAIT(human, TRAIT_HANDS_BLOCKED, REF(src))
		human.move_resist = initial(human.move_resist)
		human.overlays -= humans[human]

///callback for removing the eye from viscontents
/datum/action/xeno_action/petrify/proc/remove_eye(obj/effect/eye)
	owner.vis_contents -= eye

// ***************************************
// *********** Off-Guard
// ***************************************
#define OFF_GUARD_RANGE 8
/datum/action/xeno_action/activable/off_guard
	name = "Off-guard"
	action_icon_state = "off_guard"
	mechanics_text = "Muddles the mind of an enemy, making it harder for them to focus their aim for a while."
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
	if(!.)
		return
	if(!ishuman(A))
		if(!silent)
			A.balloon_alert(owner, "not human")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > OFF_GUARD_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	var/mob/living/carbon/human/target = A
	if(target.stat == DEAD)
		if(!silent)
			target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/xeno_action/activable/off_guard/use_ability(atom/target)
	var/mob/living/carbon/human/human_target = target
	human_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 20)
	human_target.apply_status_effect(STATUS_EFFECT_CONFUSED, 40)
	human_target.log_message("has been off-guarded by [owner]", LOG_ATTACK, color="pink")
	human_target.balloon_alert_to_viewers("confused")
	playsound(human_target, 'sound/effects/off_guard_ability.ogg', 50)

	add_cooldown()
	succeed_activate()


// ***************************************
// *********** Zero form energy beam
// ***************************************
#define ZEROFORM_BEAM_RANGE 10
#define ZEROFORM_CHARGE_TIME 2 SECONDS
#define ZEROFORM_TICK_RATE 0.3 SECONDS
/datum/action/xeno_action/zero_form_beam
	name = "Zero-Form Energy Beam"
	action_icon_state = "zero_form_beam"
	mechanics_text = "After a windup, concentrates the hives energy into a forward-facing beam that pierces everything, but only hurts living beings."
	ability_name = "zero form energy beam"
	plasma_cost = 25
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
	// sound loop for the looping sound lazor beam
	var/datum/looping_sound/zero_form_beam/sound_loop
	///ref to looping timer for the fire loop
	var/timer_ref

/datum/action/xeno_action/zero_form_beam/Destroy()
	QDEL_NULL(sound_loop)
	return ..()

/datum/action/xeno_action/zero_form_beam/New(Target)
	. = ..()
	sound_loop = new

/obj/effect/ebeam/zeroform/Initialize()
	. = ..()
	alpha = 0
	animate(src, alpha = 255, time = ZEROFORM_CHARGE_TIME)

/datum/action/xeno_action/zero_form_beam/can_use_action(silent, override_flags)
	. = ..()
	if(!.)
		return
	if(SSmonitor.gamestate == SHUTTERS_CLOSED && is_ground_level(owner.z))
		if(!silent)
			owner.balloon_alert("too early")
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

	var/particles_type
	switch(owner.dir)
		if(WEST)
			particles_type = /particles/zero_form/west
		if(EAST)
			particles_type = /particles/zero_form/east
		if(NORTH)
			particles_type = /particles/zero_form/north
		if(SOUTH)
			particles_type = /particles/zero_form/south
		else
			particles_type = /particles/zero_form
	particles = new(owner, particles_type)
	beam = owner.loc.beam(targets[length(targets)], "plasmabeam", beam_type = /obj/effect/ebeam/zeroform)
	playsound(owner, 'sound/effects/king_beam_charge.ogg', 80)
	if(!do_after(owner, ZEROFORM_CHARGE_TIME, FALSE, owner, BUSY_ICON_DANGER))
		QDEL_NULL(beam)
		QDEL_NULL(particles)
		targets = null
		return fail_activate()
	sound_loop.start(owner)
	RegisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE), .proc/stop_beaming)
	var/mob/living/carbon/xenomorph/king/king_owner = owner
	if(istype(king_owner))
		king_owner.icon_state = "King Screeching"
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
			blasted.take_overall_damage(15, BURN, updating_health = TRUE)
	timer_ref = addtimer(CALLBACK(src, .proc/execute_attack), ZEROFORM_TICK_RATE, TIMER_STOPPABLE)

///ends and cleans up beam
/datum/action/xeno_action/zero_form_beam/proc/stop_beaming()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	sound_loop.stop(owner)
	QDEL_NULL(beam)
	particles.particles.spawning = 0
	QDEL_NULL_IN(src, particles, 40)
	deltimer(timer_ref)
	timer_ref = null
	targets = null
	owner.update_icons()
	add_cooldown()

/particles/zero_form
	width = 400
	height = 400
	spawning = 5

	fadein = generator(GEN_NUM, 5, 10, NORMAL_RAND)
	lifespan = generator(GEN_NUM, 10, 20, NORMAL_RAND)
	fade = generator(GEN_NUM, 5, 10, NORMAL_RAND)

	gradient = list(1, "#C3B1E1", 2, "#800080", "loop")
	color = 0.3

/particles/zero_form/west
	gravity = list(-1, 0)
	position = generator(GEN_VECTOR, list(16, 18), list(16, -18), SQUARE_RAND)

/particles/zero_form/east
	gravity = list(1, 0)
	position = generator(GEN_VECTOR, list(16, 18), list(16, -18), SQUARE_RAND)

/particles/zero_form/north
	gravity = list(0, 1)
	position = generator(GEN_VECTOR, list(-2, 16), list(34, 16), SQUARE_RAND)

/particles/zero_form/south
	gravity = list(0, -1)
	position = generator(GEN_VECTOR, list(-2, 16), list(34, 16), SQUARE_RAND)

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
	if(!.)
		return
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
