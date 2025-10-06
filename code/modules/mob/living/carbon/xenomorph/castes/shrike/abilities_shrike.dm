#define CALLING_BURROWED_DURATION 15 SECONDS

// ***************************************
// *********** Call of the Burrowed
// ***************************************
/datum/action/ability/xeno_action/call_of_the_burrowed
	name = "Call of the Burrowed"
	desc = "Attempts to summon all currently burrowed larva."
	action_icon_state = "larva_growth"
	action_icon = 'icons/Xeno/actions/leader.dmi'
	ability_cost = 400
	cooldown_duration = 2 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED,
	)
	use_state_flags = ABILITY_USE_LYING


/datum/action/ability/xeno_action/call_of_the_burrowed/action_activate()
	if(!isnormalhive(xeno_owner.hive))
		to_chat(xeno_owner, span_warning("Burrowed larva? What a strange concept... It's not for our hive."))
		return FALSE
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	if(!stored_larva)
		to_chat(xeno_owner, span_warning("Our hive currently has no burrowed to call forth!"))
		return FALSE

	playsound(xeno_owner,'sound/magic/invoke_general.ogg', 75, TRUE)
	new /obj/effect/temp_visual/telekinesis(get_turf(xeno_owner))
	xeno_owner.visible_message(span_xenowarning("A strange buzzing hum starts to emanate from \the [xeno_owner]!"), \
	span_xenodanger("We call forth the larvas to rise from their slumber!"))

	if(stored_larva)
		RegisterSignals(xeno_owner.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), PROC_REF(is_burrowed_larva_host))
		xeno_owner.hive.give_larva_to_next_in_queue()
		notify_ghosts("\The <b>[xeno_owner]</b> is calling for the burrowed larvas to wake up!", enter_link = "join_larva=1", enter_text = "Join as Larva", source = xeno_owner, action = NOTIFY_JOIN_AS_LARVA, flashwindow = TRUE)
		addtimer(CALLBACK(src, PROC_REF(calling_larvas_end), xeno_owner), CALLING_BURROWED_DURATION)

	succeed_activate()
	add_cooldown()


/datum/action/ability/xeno_action/call_of_the_burrowed/proc/calling_larvas_end(mob/living/carbon/xenomorph/xeno_owner)
	UnregisterSignal(xeno_owner.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))


/datum/action/ability/xeno_action/call_of_the_burrowed/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos) //Should only register while a viable candidate.
	SIGNAL_HANDLER
	if(!owner.incapacitated())
		mothers += owner //Adding them to the list.

/datum/action/ability/xeno_action/call_of_the_burrowed/free
	ability_cost = 0

// ***************************************
// *********** Psychic Fling
// ***************************************
/datum/action/ability/activable/xeno/psychic_fling
	name = "Psychic Fling"
	action_icon_state = "fling"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	desc = "Sends an enemy or an item flying. A close ranged ability."
	cooldown_duration = 12 SECONDS
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_FLING,
	)
	target_flags = ABILITY_MOB_TARGET
	/// How long in deciseconds should humans be stunned? If they are to be stunned, they will also drop held items.
	var/stun_duration = 2 SECONDS
	/// Should humans take damage immediately? If so, what is the multiplier of the owner's melee damage for determining how much damage to deal?
	var/damage_multiplier = 0
	/// If humans were to collide with something, how long in deciseconds should they be paralyzed for collusion?
	var/collusion_paralyze_duration = 0
	/// If humans were to collide with something, what is the multiplier of the owner's melee damage for determining how much damage to deal?
	var/collusion_damage_multiplier = 0
	/// Should the collusion duration/multiplier only register for xenomorphs; also allows targetting of other xenos. This means that only flung xenomorphs can deal its effects to collided things.
	var/collusion_xenos_only = FALSE

/datum/action/ability/activable/xeno/psychic_fling/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough mental strength to fling something again."))
	return ..()

/datum/action/ability/activable/xeno/psychic_fling/can_use_ability(atom/movable/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!isitem(target) && !ishuman(target) && !isdroid(target) && !isxeno(target)) // Only items, humans, droids, and xenomorphs.
		return FALSE
	if(isxeno(target) && (target != xeno_owner) && !collusion_xenos_only)
		return FALSE
	if(target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return FALSE
	var/max_dist = 3 //the distance only goes to 3 now, since this is more of a utility then an attack.
	if(!line_of_sight(owner, target, max_dist))
		if(!silent)
			to_chat(owner, span_warning("We must get closer to fling, our mind cannot reach this far."))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(isnestedhost(victim))
			return FALSE
		if(!CHECK_BITFIELD(use_state_flags|override_flags, ABILITY_IGNORE_DEAD_TARGET) && victim.stat == DEAD)
			return FALSE

/datum/action/ability/activable/xeno/psychic_fling/use_ability(atom/target)
	var/atom/movable/movable_target = target
	GLOB.round_statistics.psychic_flings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_flings")

	xeno_owner.visible_message(span_xenowarning("A strange and violent psychic aura is suddenly emitted from \the [xeno_owner]!"), \
		span_xenowarning("We violently fling [movable_target] with the power of our mind!"))
	movable_target.visible_message(span_xenowarning("[movable_target] is violently flung away by an unseen force!"), \
		span_xenowarning("You are violently flung to the side by an unseen force!"))
	playsound(xeno_owner, 'sound/effects/magic.ogg', 75, 1)
	playsound(movable_target, 'sound/weapons/alien_claw_block.ogg', 75, 1)

	if(ishuman(movable_target))
		// Held facehuggers get killed for balance reasons; preventing a near-immediate facehug after a stun.
		for(var/obj/item/clothing/mask/facehugger/hugger in xeno_owner.get_held_items())
			hugger.kill_hugger()
			xeno_owner.dropItemToGround(hugger)
		var/mob/living/carbon/human/human_target = movable_target
		if(stun_duration)
			human_target.Stun(stun_duration)
			human_target.drop_all_held_items()
		if(damage_multiplier)
			human_target.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier * damage_multiplier, BRUTE, blocked = MELEE, updating_health = TRUE, attacker = owner)
		shake_camera(human_target, 2, 1)
		RegisterSignal(human_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_post_throw))
		if(!collusion_xenos_only && (collusion_paralyze_duration || collusion_damage_multiplier))
			RegisterSignal(human_target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
		else
			human_target.add_pass_flags(PASS_MOB, THROW_TRAIT)
	if(isxeno(movable_target))
		var/mob/living/carbon/xenomorph/xenomorph_target = movable_target
		RegisterSignal(xenomorph_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_post_throw))
		if(collusion_paralyze_duration || collusion_damage_multiplier)
			RegisterSignal(xenomorph_target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
		else
			xenomorph_target.add_pass_flags(PASS_MOB, THROW_TRAIT)
	var/facing = xeno_owner == movable_target ? xeno_owner.dir : get_dir(xeno_owner, movable_target)
	var/fling_distance = (isitem(movable_target)) ? 4 : 3 // Objects get flung further away.
	var/turf/T = movable_target.loc
	var/turf/temp
	for(var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if(!temp)
			break
		T = temp
	movable_target.throw_at(T, fling_distance, 1, xeno_owner, TRUE)

	add_cooldown()
	succeed_activate()

/// Called when the throw has ended.
/datum/action/ability/activable/xeno/psychic_fling/proc/on_post_throw(datum/source)
	SIGNAL_HANDLER
	var/mob/living/living_source = source
	UnregisterSignal(living_source, COMSIG_MOVABLE_POST_THROW)
	if(collusion_paralyze_duration || collusion_damage_multiplier)
		UnregisterSignal(living_source, COMSIG_MOVABLE_IMPACT)
		return
	living_source.remove_pass_flags(PASS_MOB, THROW_TRAIT)

/// Called when the source has hit something.
/datum/action/ability/activable/xeno/psychic_fling/proc/on_throw_impact(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	var/mob/living/living_source = source
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier * collusion_damage_multiplier
	var/valid_impact = FALSE
	if(isliving(hit_atom))
		valid_impact = TRUE
		var/mob/living/living_hit = hit_atom
		if(!xeno_owner.issamexenohive(living_hit))
			INVOKE_ASYNC(living_hit, TYPE_PROC_REF(/mob, emote), isxeno(living_hit) ? "hiss1" : "scream")
			if(damage)
				living_hit.apply_damage(damage, BRUTE, blocked = MELEE, updating_health = TRUE, attacker = owner)
			if(collusion_paralyze_duration)
				living_hit.Paralyze(collusion_paralyze_duration)
	if(isobj(hit_atom))
		valid_impact = TRUE
		var/obj/hit_object = hit_atom
		if(!istype(hit_object, /obj/structure/xeno) && damage)
			hit_object.take_damage(damage, BRUTE, MELEE)
	if(iswallturf(hit_atom))
		valid_impact = TRUE
		var/turf/closed/wall/hit_wall = hit_atom
		if(!(hit_wall.resistance_flags & INDESTRUCTIBLE) && damage)
			hit_wall.take_damage(damage, BRUTE, MELEE)
	if(!valid_impact)
		return
	if(!xeno_owner.issamexenohive(living_source))
		INVOKE_ASYNC(living_source, TYPE_PROC_REF(/mob, emote), isxeno(living_source) ? "hiss1" : "scream")
		if(damage)
			living_source.apply_damage(damage, BRUTE, blocked = MELEE, updating_health = TRUE, attacker = owner)
		if(collusion_paralyze_duration)
			living_source.Paralyze(collusion_paralyze_duration)

// ***************************************
// *********** Unrelenting Force
// ***************************************
/datum/action/ability/activable/xeno/unrelenting_force
	name = "Unrelenting Force"
	action_icon_state = "screech"
	action_icon = 'icons/Xeno/actions/queen.dmi'
	desc = "Unleashes our raw psychic power, pushing aside anyone who stands in our path."
	cooldown_duration = 50 SECONDS
	ability_cost = 300
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_UNRELENTING_FORCE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_UNRELENTING_FORCE_SELECT,
	)
	/// The amount of distance that to throw things.
	var/throwing_distance = 6
	/// Should this ability reflect projectiles as well? If so, what amount should the cooldown duration be mulitplied by if 100+ projectle damage was reflected?
	var/projectile_cooldown_mulitplier = 0
	/// Should things be thrown toward the owner first before getting thrown away?
	var/rebound_throwing = FALSE
	/// What direction was the owner facing at the start of the ability? Kept around to reuse for rebound signals.
	var/starting_direction

/datum/action/ability/activable/xeno/unrelenting_force/on_cooldown_finish()
	to_chat(owner, span_notice("Our mind is ready to unleash another blast of force."))
	return ..()

/datum/action/ability/activable/xeno/unrelenting_force/use_ability(atom/target)
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, update_icons)), 1 SECONDS)
	xeno_owner.icon_state = "[xeno_owner.xeno_caste.caste_name][(xeno_owner.xeno_flags & XENO_ROUNY) ? " rouny" : ""] Screeching"
	if(target) // Keybind use doesn't have a target
		xeno_owner.face_atom(target)
	starting_direction = xeno_owner.dir

	var/turf/lower_left
	var/turf/upper_right
	switch(starting_direction)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y + 3, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y - 3, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 3, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 3, xeno_owner.y + 1, xeno_owner.z)

	var/list/things_to_throw = list()
	var/list/atom/movable/projectile/things_to_deflect = list()
	for(var/turf/affected_tile in block(lower_left, upper_right)) //everything in the 3x3 block is found.
		affected_tile.Shake(duration = 0.5 SECONDS)
		for(var/atom/movable/affected AS in affected_tile)
			if(isfire(affected))
				var/obj/fire/fire = affected
				fire.reduce_fire(10)
				continue
			if(projectile_cooldown_mulitplier && istype(affected, /atom/movable/projectile))
				things_to_deflect += affected
				continue
			if(!ishuman(affected) && !istype(affected, /obj/item) && !isdroid(affected))
				affected.Shake(duration = 0.5 SECONDS)
				continue
			if(affected.move_resist >= MOVE_FORCE_OVERPOWERING)
				continue
			if(ishuman(affected))
				var/mob/living/carbon/human/H = affected
				if(H.stat == DEAD)
					continue
				H.apply_effects(paralyze = 2 SECONDS)
				shake_camera(H, 2, 1)
			things_to_throw += affected

	for(var/atom/movable/affected AS in things_to_throw)
		var/throwlocation = affected.loc
		for(var/x in 1 to throwing_distance)
			throwlocation = get_step(throwlocation, rebound_throwing ? REVERSE_DIR(starting_direction) : starting_direction)
		if(rebound_throwing)
			RegisterSignal(affected, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_throw_end))
		affected.throw_at(throwlocation, throwing_distance, 1, xeno_owner, TRUE)

	var/damage_deflected = 0
	for(var/atom/movable/projectile/affected_projectile AS in things_to_deflect)
		if(starting_direction == affected_projectile.dir)
			continue
		var/perpendicular_angle = Get_Angle(get_turf(xeno_owner), get_step(xeno_owner, starting_direction))
		var/bounced_angle = perpendicular_angle + (perpendicular_angle - affected_projectile.dir_angle - (starting_direction == REVERSE_DIR(affected_projectile.dir) ? 180 : 90))
		if(bounced_angle < 0)
			bounced_angle += 360
		else if(bounced_angle > 360)
			bounced_angle -= 360
		affected_projectile.distance_travelled = 0
		affected_projectile.iff_signal = null
		affected_projectile.fire_at(shooter = xeno_owner, source = get_step(xeno_owner, starting_direction), angle = bounced_angle, recursivity = TRUE)
		damage_deflected += affected_projectile.damage

	owner.visible_message(span_xenowarning("[owner] sends out a huge blast of psychic energy!"), \
	span_xenowarning("We send out a huge blast of psychic energy!"))

	playsound(owner,'sound/effects/bamf.ogg', 75, TRUE)
	playsound(owner, SFX_ALIEN_ROAR, 50)

	// Held facehuggers get killed for balance reasons.
	for(var/obj/item/clothing/mask/facehugger/hugger in owner.get_held_items())
		hugger.kill_hugger()
		owner.dropItemToGround(hugger)

	add_cooldown(cooldown_duration * (damage_deflected >= 50 ? projectile_cooldown_mulitplier : 1))
	succeed_activate()

/// Throws things back the other way.
/datum/action/ability/activable/xeno/unrelenting_force/proc/on_throw_end(datum/source)
	SIGNAL_HANDLER
	var/atom/movable/movable_source = source
	UnregisterSignal(movable_source, list(COMSIG_MOVABLE_POST_THROW))
	var/throw_location = movable_source.loc
	for(var/x in 1 to throwing_distance)
		throw_location = get_step(throw_location, starting_direction)
	movable_source.throw_at(throw_location, throwing_distance, 1, xeno_owner, TRUE)

// ***************************************
// *********** Psychic Cure
// ***************************************
/datum/action/ability/activable/xeno/psychic_cure
	name = "Psychic Cure"
	action_icon_state = "heal_xeno"
	action_icon = 'icons/Xeno/actions/drone.dmi'
	desc = "Heal and remove debuffs from a target."
	cooldown_duration = 1 MINUTES
	ability_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_CURE,
	)
	target_flags = ABILITY_MOB_TARGET
	/// How far can the ability be used?
	var/heal_range = SHRIKE_HEAL_RANGE
	/// If the ability was used on themselves, what is the amount to multiply healing power by?
	var/self_heal_multiplier = 1
	/// The percentage of restored health that will be re-applied to the owner. 1 = 100%, 0.01 = 1%.
	var/rebound_percentage = 0
	/// The amount of deciseconds that the Resin Jelly Coating status effect will be applied.
	var/resin_jelly_duration = 0
	/// The amount of deciseconds that various status effects are delayed: Stun, Knockdown, and Stagger. Slowdown immunity is given, but not delayed.
	var/delayed_status_duration = 0
	/// List of all delayed status effects to be reapplied at the end.
	var/list/delayed_status_list = list()
	/// The xenomorph who is having their status effects being delayed.
	var/mob/living/carbon/xenomorph/delayed_status_patient
	/// Timer that will give back any delayed status effect.
	var/delayed_status_timer

/datum/action/ability/activable/xeno/psychic_cure/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough mental strength to cure sisters again."))
	return ..()

/datum/action/ability/activable/xeno/psychic_cure/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!check_distance(target, silent))
		return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, ABILITY_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			to_chat(owner, span_warning("It's too late. This sister won't be coming back."))
		return FALSE

/datum/action/ability/activable/xeno/psychic_cure/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > heal_range)
		if(!silent)
			to_chat(owner, span_warning("Too far for our reach... We need to be [dist - heal_range] steps closer!"))
		return FALSE
	else if(!line_of_sight(owner, target))
		if(!silent)
			to_chat(owner, span_warning("We can't focus properly without a clear line of sight!"))
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/psychic_cure/use_ability(atom/target)
	if(owner.do_actions)
		return FALSE
	if(!do_after(owner, 1 SECONDS, IGNORE_TARGET_LOC_CHANGE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE
	if(!can_use_ability(target, TRUE))
		return FALSE

	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.heals++
	GLOB.round_statistics.psychic_cures++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_cures")
	owner.visible_message(span_xenowarning("A strange psychic aura is suddenly emitted from \the [owner]!"), \
	span_xenowarning("We cure [target] with the power of our mind!"))
	target.visible_message(span_xenowarning("[target] suddenly shimmers in a chill light."), \
	span_xenowarning("We feel a sudden soothing chill."))

	playsound(target,'sound/effects/magic.ogg', 75, 1)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/mob/living/carbon/xenomorph/patient = target
	var/healing_results = patient.heal_wounds(xeno_owner == patient ? SHRIKE_CURE_HEAL_MULTIPLIER * self_heal_multiplier : SHRIKE_CURE_HEAL_MULTIPLIER)
	patient.adjust_sunder(xeno_owner == patient ?  -SHRIKE_CURE_HEAL_MULTIPLIER * self_heal_multiplier : -SHRIKE_CURE_HEAL_MULTIPLIER)
	if(patient.health > 0) //If they are not in crit after the heal, let's remove evil debuffs.
		patient.SetUnconscious(0)
		patient.SetStun(0)
		patient.SetParalyzed(0)
		patient.set_stagger(0)
		patient.set_slowdown(0)
	patient.updatehealth()

	var/amount_healed = healing_results[2] - healing_results[1]
	if(rebound_percentage && amount_healed)
		var/amount_to_heal = amount_healed * rebound_percentage
		HEAL_XENO_DAMAGE(xeno_owner, amount_to_heal, FALSE)
	if(resin_jelly_duration)
		xeno_owner.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING, resin_jelly_duration)
		xeno_owner.emote("roar")
		if(xeno_owner != patient)
			patient.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING, resin_jelly_duration)
			patient.emote("roar")

	if(delayed_status_patient)
		end_delayed_status_effects()
	if(delayed_status_duration)
		start_delayed_status_effects(patient)
	log_combat(owner, patient, "psychically cured")

	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/psychic_cure/proc/start_delayed_status_effects(mob/living/carbon/xenomorph/patient)
	delayed_status_timer = addtimer(CALLBACK(src, PROC_REF(end_delayed_status_effects)), delayed_status_duration, TIMER_UNIQUE|TIMER_STOPPABLE)
	delayed_status_patient = patient
	ADD_TRAIT(delayed_status_patient, TRAIT_SLOWDOWNIMMUNE, SHRIKE_ABILITY_TRAIT)
	RegisterSignal(patient, COMSIG_LIVING_STATUS_STUN, PROC_REF(on_stun))
	RegisterSignal(patient, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_knockdown))
	RegisterSignal(patient, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_stagger))
	delayed_status_patient.add_filter("psychic_cure_delayed", 2, outline_filter(2, COLOR_BLUE))

/datum/action/ability/activable/xeno/psychic_cure/proc/end_delayed_status_effects()
	if(delayed_status_timer)
		deltimer(delayed_status_timer)
		delayed_status_timer = null
	REMOVE_TRAIT(delayed_status_patient, TRAIT_SLOWDOWNIMMUNE, SHRIKE_ABILITY_TRAIT)
	UnregisterSignal(delayed_status_patient, COMSIG_LIVING_STATUS_STUN)
	UnregisterSignal(delayed_status_patient, COMSIG_LIVING_STATUS_KNOCKDOWN)
	UnregisterSignal(delayed_status_patient, COMSIG_LIVING_STATUS_STAGGER)
	for(var/status_effect_name AS in delayed_status_list)
		var/duration = delayed_status_list[status_effect_name]
		delayed_status_patient.apply_effect(duration, status_effect_name)
	delayed_status_patient.remove_filter("psychic_cure_delayed")
	delayed_status_list.Cut()
	delayed_status_patient = null

/datum/action/ability/activable/xeno/psychic_cure/proc/on_stun(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	delayed_status_list[EFFECT_STUN] += amount
	return COMPONENT_NO_STUN

/datum/action/ability/activable/xeno/psychic_cure/proc/on_knockdown(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	delayed_status_list[EFFECT_KNOCKDOWN] += amount
	return COMPONENT_NO_STUN

/datum/action/ability/activable/xeno/psychic_cure/proc/on_stagger(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	delayed_status_list[EFFECT_STAGGER] += amount
	return COMPONENT_NO_STUN

// COMSIG_LIVING_STATUS_STAGGER


// ***************************************
// *********** Construct Acid Well
// ***************************************
/datum/action/ability/xeno_action/place_acidwell
	name = "Place acid well"
	action_icon_state = "place_trap"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Place an acid well that can put out fires."
	ability_cost = 400
	cooldown_duration = 2 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_ACID_WELL,
	)
	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/place_acidwell/can_use_action(silent, override_flags, selecting)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, span_warning("We can't do that here."))
		return FALSE

	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			to_chat(owner, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return FALSE

	if(!T.check_alien_construction(owner, silent, /obj/structure/xeno/acidwell))
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

/datum/action/ability/xeno_action/place_acidwell/action_activate()
	var/turf/T = get_turf(owner)
	succeed_activate()

	playsound(T, SFX_ALIEN_RESIN_BUILD, 25)
	new /obj/structure/xeno/acidwell(T, owner)

	to_chat(owner, span_xenonotice("We place an acid well; it can be filled with more acid."))
	GLOB.round_statistics.xeno_acid_wells++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_acid_wells")
	owner.record_traps_created()


// ***************************************
// *********** Psychic Vortex
// ***************************************
#define VORTEX_RANGE 4
#define VORTEX_INITIAL_CHARGE 2 SECONDS
#define VORTEX_POST_INITIAL_CHARGE 0.5 SECONDS
/datum/action/ability/activable/xeno/psychic_vortex
	name = "Pyschic vortex"
	action_icon_state = "vortex"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	desc = "Channel a sizable vortex of psychic energy, drawing in nearby enemies."
	ability_cost = 600
	cooldown_duration = 2 MINUTES
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_VORTEX,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///The particle type this ability uses
	var/channel_particle = /particles/warlock_charge

/datum/action/ability/activable/xeno/psychic_vortex/on_cooldown_finish()
	to_chat(owner, span_notice("Our mind is ready to unleash another chaotic vortex of energy."))
	return ..()

/datum/action/ability/activable/xeno/psychic_vortex/use_ability(atom/target)
	succeed_activate()
	add_cooldown()

	particle_holder = new(owner, channel_particle)
	particle_holder.pixel_x = 15
	particle_holder.pixel_y = 0

	if(target) // Keybind use doesn't have a target
		owner.face_atom(target)
	ADD_TRAIT(owner, TRAIT_IMMOBILE, VORTEX_ABILITY_TRAIT)
	if(do_after(owner, VORTEX_INITIAL_CHARGE, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER))
		vortex_pull()
	if(do_after(owner, VORTEX_POST_INITIAL_CHARGE, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER))
		vortex_push()
	if(do_after(owner, VORTEX_POST_INITIAL_CHARGE, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER))
		vortex_pull()
	QDEL_NULL(particle_holder)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, VORTEX_ABILITY_TRAIT)
	return


/**
 * Checks for any non-anchored movable atom, throwing them towards the shrike/owner using the ability.
 * While causing shake to anything in range with effects applied to humans affected.
 */
/datum/action/ability/activable/xeno/psychic_vortex/proc/vortex_pull()
	playsound(owner, 'sound/effects/seedling_chargeup.ogg', 60)
	for(var/atom/movable/movable_victim in range(VORTEX_RANGE, owner.loc))
		if(movable_victim.anchored || isxeno(movable_victim) || movable_victim.move_resist > MOVE_FORCE_STRONG)
			continue
		if(ishuman(movable_victim))
			var/mob/living/carbon/human/H = movable_victim
			if(H.stat == DEAD)
				continue
			H.apply_effects(paralyze = 0.1 SECONDS)
			H.adjust_stagger(2 SECONDS)
			shake_camera(H, 2, 1)
		else if(isitem(movable_victim))
			var/turf/targetturf = get_turf(owner)
			targetturf = locate(targetturf.x + rand(1, 4), targetturf.y + rand(1, 4), targetturf.z)
			movable_victim.throw_at(targetturf, 4, 1, owner, FALSE, FALSE)
		movable_victim.throw_at(owner, 4, 1, owner, FALSE, FALSE)

/// Randomly throws movable atoms in the radius of the vortex abilites range, different each use.
/datum/action/ability/activable/xeno/psychic_vortex/proc/vortex_push()
	for(var/atom/movable/movable_victim in range(VORTEX_RANGE, owner.loc))
		if(movable_victim.anchored || isxeno(movable_victim) || movable_victim.move_resist == INFINITY)
			continue
		if(ishuman(movable_victim))
			var/mob/living/carbon/human/human_victim = movable_victim
			if(human_victim.stat == DEAD)
				continue
		var/turf/targetturf = get_turf(owner)
		targetturf = locate(targetturf.x + rand(1, 4), targetturf.y + rand(1, 4), targetturf.z)
		movable_victim.throw_at(targetturf, 4, 1, owner, FALSE, FALSE)


#define PSYCHIC_CHOKE_DAMAGE_THRESHOLD 5

// ***************************************
// *********** Psychic Choke
// ***************************************
/datum/action/ability/activable/xeno/psychic_choke
	name = "Psychic Choke"
	action_icon_state = "fling"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	desc = "Channel at a distance to hold a human in your psychic grasp."
	cooldown_duration = 12 SECONDS
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_FLING, // Shares the same key as you can only have this ability or the other, never both at the same time.
	)
	target_flags = ABILITY_MOB_TARGET
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// How much damage by the owner or the target has been taken so far while channeling?
	var/damage_taken_so_far = 0
	/// If damage taken reaches this amount, channeling will end.
	var/damage_threshold = PSYCHIC_CHOKE_DAMAGE_THRESHOLD
	/// What is the human being choked right now?
	var/mob/living/carbon/human/choked_human

/datum/action/ability/activable/xeno/psychic_choke/can_use_ability(atom/movable/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target) || !ishuman(target))
		return FALSE
	var/dist = get_dist(xeno_owner, target)
	switch(dist)
		if(-1 to 1)
			if(!silent)
				xeno_owner.balloon_alert(target, "Too close!")
			return FALSE
		if(2 to 3)
			if(!line_of_sight(xeno_owner, target, 3))
				if(!silent)
					xeno_owner.balloon_alert(target, "Not in line of sight!")
				return FALSE
		if(4 to INFINITY)
			if(!silent)
				xeno_owner.balloon_alert(target, "Too far!")
			return FALSE
	var/mob/living/carbon/human/human_target = target
	if(human_target.stat == DEAD)
		if(!silent)
			xeno_owner.balloon_alert(target, "Already dead!")
		return FALSE

/datum/action/ability/activable/xeno/psychic_choke/use_ability(atom/target)
	if(choked_human)
		return
	choked_human = target
	xeno_owner.face_atom(choked_human)

	xeno_owner.visible_message(span_xenowarning("A strange and violent psychic aura is suddenly emitted from \the [xeno_owner]!"), \
		span_xenowarning("We choke [choked_human] with the power of our mind!"))
	choked_human.visible_message(span_xenowarning("[choked_human] is suddenly grabbed by the neck by an unseen force!"), \
		span_xenowarning("You are suddenly grabbed by an unseen force!"))
	playsound(xeno_owner, 'sound/effects/magic.ogg', 75, 1)

	choked_human.drop_all_held_items()
	choked_human.Stun(4 SECONDS)

	ADD_TRAIT(xeno_owner, TRAIT_HANDS_BLOCKED, SHRIKE_ABILITY_TRAIT)
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(on_damage_taken))
	RegisterSignal(choked_human, COMSIG_HUMAN_DAMAGE_TAKEN, PROC_REF(on_damage_taken))
	RegisterSignals(choked_human, list(COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_IGNITED), PROC_REF(end_choke))

	var/angle = Get_Angle(get_turf(xeno_owner), get_turf(choked_human))
	particle_holder = new(xeno_owner, /particles/psychic_choke)
	particle_holder.pixel_x = 16
	particle_holder.pixel_y = 0
	particle_holder.particles.velocity = list(sin(angle) * 3.5, cos(angle) * 3.5)
	particle_holder.particles.gravity = list(sin(angle) * 7, cos(angle) * 7)
	particle_holder.particles.rotation = angle
	xeno_owner.update_glow(3, 3, "#9e1f1f")

	if(!do_after(xeno_owner, 4 SECONDS, NONE, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_continue_choke))))
		end_choke()
		return
	end_choke()

/// Should the choking continue? Used for the do_after.
/datum/action/ability/activable/xeno/psychic_choke/proc/can_continue_choke()
	return can_use_action(TRUE, ABILITY_USE_BUSY) && choked_human

/// Ends the choke by reverting everything associated with choking.
/datum/action/ability/activable/xeno/psychic_choke/proc/end_choke()
	choked_human.SetStun(0)

	REMOVE_TRAIT(xeno_owner, TRAIT_HANDS_BLOCKED, SHRIKE_ABILITY_TRAIT)
	UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_TAKING_DAMAGE)
	UnregisterSignal(choked_human, COMSIG_HUMAN_DAMAGE_TAKEN)
	UnregisterSignal(choked_human, list(COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_IGNITED))

	QDEL_NULL(particle_holder)
	xeno_owner.update_glow()

	choked_human = null
	add_cooldown()
	succeed_activate()

/// Keeps track of how much damage has been taken so far by the owner and the choked human.
/datum/action/ability/activable/xeno/psychic_choke/proc/on_damage_taken(datum/source, damage_amount, mob/living/attacker)
	damage_taken_so_far += damage_amount
	if(damage_taken_so_far >= damage_threshold)
		end_choke()

/particles/psychic_choke
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "lemon"
	width = 250
	height = 250
	count = 300
	spawning = 20
	lifespan = 12
	fade = 12
	grow = -0.02
	velocity = list(0, 3)
	position = generator(GEN_CIRCLE, 15, 17, NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.1, 0.1), list(0.5, 0.5), NORMAL_RAND)
	color = "#970f0f"
