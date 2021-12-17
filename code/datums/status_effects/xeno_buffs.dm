/datum/status_effect/resin_jelly_coating
	id = "resin jelly"
	duration = 15 SECONDS
	tick_interval = 30
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/resin_jelly_coating/on_apply()
	if(!isxeno(owner))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	X.fire_resist_modifier -= 20
	X.add_filter("resin_jelly_outline", 2, outline_filter(1, COLOR_TAN_ORANGE))
	return TRUE

/datum/status_effect/resin_jelly_coating/on_remove()
	var/mob/living/carbon/xenomorph/X = owner
	X.fire_resist_modifier += 20
	X.remove_filter("resin_jelly_outline")
	owner.balloon_alert(owner, "We are vulnerable again")
	return ..()

/datum/status_effect/resin_jelly_coating/tick()
	owner.heal_limb_damage(0, 5)
	return ..()

/obj/screen/alert/status_effect/xeno_rejuvenate
	name = "Rejuvenation"
	desc = "Your health is being restored."
	icon_state = "xeno_rejuvenate"

/datum/status_effect/xeno_rejuvenate
	id = "xeno_rejuvenate"
	tick_interval = 2 SECONDS
	alert_type = /obj/screen/alert/status_effect/xeno_rejuvenate
	///Amount of damage taken before reduction kicks in
	var/tick_damage_limit
	///Amount of damage taken this tick
	var/tick_damage

/datum/status_effect/xeno_rejuvenate/on_creation(mob/living/new_owner, set_duration, tick_damage_limit)
	owner = new_owner
	duration = set_duration
	src.tick_damage_limit = tick_damage_limit
	RegisterSignal(owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), .proc/handle_damage_taken)
	owner.add_movespeed_modifier(MOVESPEED_ID_GORGER_REJUVENATE, TRUE, 0, NONE, TRUE, GORGER_REJUVENATE_SLOWDOWN)
	owner.add_filter("[id]m", 0, outline_filter(2, "#455d5762"))
	return ..()

/datum/status_effect/xeno_rejuvenate/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	owner.remove_movespeed_modifier(MOVESPEED_ID_GORGER_REJUVENATE)
	owner.remove_filter("[id]m")

/datum/status_effect/xeno_rejuvenate/tick()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.plasma_stored < GORGER_REJUVENATE_COST)
		to_chat(owner_xeno, span_notice("Not enough substance to sustain ourselves..."))
		owner_xeno.remove_status_effect(STATUS_EFFECT_XENO_REJUVENATE)
		return

	owner_xeno.plasma_stored -= GORGER_REJUVENATE_COST
	new /obj/effect/temp_visual/telekinesis(get_turf(owner_xeno))
	to_chat(owner_xeno, span_notice("We feel our wounds close up."))

	var/amount = owner_xeno.maxHealth * GORGER_REJUVENATE_HEAL
	HEAL_XENO_DAMAGE(owner_xeno, amount)
	tick_damage = 0

///Handles damage received when the status effect is active
/datum/status_effect/xeno_rejuvenate/proc/handle_damage_taken(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0)
		return

	tick_damage += amount
	if(tick_damage < tick_damage_limit)
		return

	amount_mod += min(amount * 0.75, 40)

#define PSYCHIC_LINK_COLOR "#2a888360"
#define TARGET_ID "[id][owner.ckey]"
#define CALC_DAMAGE_REDUCTION(amount, amount_mod) \
	if(amount <= 0) { \
		return; \
	}; \
	var/remaining_health = owner.health - minimum_health; \
	amount = min(amount * redirect_mod, remaining_health); \
	amount_mod += amount

/datum/status_effect/xeno_psychic_link
	id = "xeno_psychic_link"
	tick_interval = 2 SECONDS
	///Xenomorph the owner is linked to
	var/mob/living/carbon/xenomorph/target_mob
	///How far apart the linked mobs can be
	var/link_range
	///Percentage of damage to be redirected
	var/redirect_mod
	///Minimum health threshold before the effect is deactivated
	var/minimum_health

/datum/status_effect/xeno_psychic_link/on_creation(mob/living/new_owner, set_duration, mob/living/carbon/target_mob, link_range, redirect_mod, minimum_health)
	owner = new_owner
	duration = set_duration
	src.target_mob = target_mob
	src.link_range = link_range
	src.redirect_mod = redirect_mod
	src.minimum_health = minimum_health
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/handle_dist)
	RegisterSignal(target_mob, COMSIG_MOVABLE_MOVED, .proc/handle_dist)
	RegisterSignal(owner, COMSIG_MOB_DEATH, .proc/handle_mob_dead)
	RegisterSignal(target_mob, COMSIG_MOB_DEATH, .proc/handle_mob_dead)
	RegisterSignal(target_mob, COMSIG_XENOMORPH_BURN_DAMAGE, .proc/handle_burn_damage)
	RegisterSignal(target_mob, COMSIG_XENOMORPH_BRUTE_DAMAGE, .proc/handle_brute_damage)
	owner.add_filter("[id]m", 2, outline_filter(2, PSYCHIC_LINK_COLOR))
	target_mob.add_filter(TARGET_ID, 2, outline_filter(2, PSYCHIC_LINK_COLOR))
	var/link_message = "[owner] has linked to you and is redirecting some of your injuries. If they get too hurt, the link may be broken. "
	if(link_range > 0)
		link_message += "Keep within [link_range] tiles to maintain it."
	to_chat(target_mob, span_xenonotice(link_message))
	return ..()

/datum/status_effect/xeno_psychic_link/on_remove()
	. = ..()
	UnregisterSignal(target_mob, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	owner.remove_filter("[id]m")
	target_mob.remove_filter(TARGET_ID)
	to_chat(target_mob, span_xenonotice("[owner] has unlinked from you."))

///Handles the link breaking due to dying
/datum/status_effect/xeno_psychic_link/proc/handle_mob_dead(datum/source)
	SIGNAL_HANDLER
	owner.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

///Handles the link breaking due to distance
/datum/status_effect/xeno_psychic_link/proc/handle_dist(datum/source)
	SIGNAL_HANDLER
	if(get_dist(owner, target_mob) > link_range)
		to_chat(target_mob, span_xenowarning("You are too far away from [owner]."))
		to_chat(owner, span_xenowarning("[target_mob] is too far away."))
		owner.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

///Transfers mitigated burn damage
/datum/status_effect/xeno_psychic_link/proc/handle_burn_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	CALC_DAMAGE_REDUCTION(amount, amount_mod)
	owner.adjustFireLoss(amount)
	if(owner.health <= minimum_health)
		owner.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

///Transfers mitigated brute damage
/datum/status_effect/xeno_psychic_link/proc/handle_brute_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	CALC_DAMAGE_REDUCTION(amount, amount_mod)
	owner.adjustBruteLoss(amount)
	if(owner.health <= minimum_health)
		owner.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

#undef PSYCHIC_LINK_COLOR
#undef TARGET_ID
#undef CALC_DAMAGE_REDUCTION

///Calculates the effectiveness of parts of the status based on plasma of owner
#define CALC_PLASMA_MOD(xeno) \
	(clamp(1 - xeno.plasma_stored / owner_xeno.xeno_caste.plasma_max, 0.2, 0.8) + 0.2)
#define HIGN_THRESHOLD 0.6
#define KNOCKDOWN_DURATION 1 SECONDS

/obj/screen/alert/status_effect/xeno_carnage
	name = "Carnage"
	desc = "Your attacks restore health."
	icon_state = "xeno_carnage"

/datum/status_effect/xeno_carnage
	id = "xeno_carnage"
	alert_type = /obj/screen/alert/status_effect/xeno_carnage
	///Effects modifier based on plasma amount on status application
	var/plasma_mod
	///Plasma gain on attack
	var/plasma_gain_on_hit
	///Health or overhealing received on attack
	var/healing_on_hit

/datum/status_effect/xeno_carnage/on_creation(mob/living/new_owner, set_duration, plasma_gain, healing, movement_speed_max)
	owner = new_owner
	duration = set_duration

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	plasma_mod = CALC_PLASMA_MOD(owner_xeno)

	plasma_gain_on_hit = plasma_gain * plasma_mod
	healing_on_hit = healing * plasma_mod
	owner_xeno.add_movespeed_modifier(MOVESPEED_ID_GORGER_CARNAGE, TRUE, 0, NONE, TRUE, movement_speed_max * plasma_mod)

	to_chat(owner, span_notice("We give into our thirst!"))
	owner_xeno.emote("roar")
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)

	owner.add_filter(id, 5, rays_filter(size = 25, color = "#c50021", offset = 200, density = 50, y = 7))
	if(plasma_mod >= HIGN_THRESHOLD)
		owner.add_filter("[id]m", 4, color_matrix_filter(list(1 + plasma_mod,0,0,0, -(0.5 + plasma_mod * 1),1,0,0, plasma_mod * 0.8,0,1,0, 0,0,0,1, 0,0,0,0)))

	return ..()

/datum/status_effect/xeno_carnage/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(MOVESPEED_ID_GORGER_CARNAGE)
	to_chat(owner, span_notice("Our bloodlust subsides..."))
	UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)
	owner.remove_filter(list(id, "[id]m"))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, src)

///Calls slash proc
/datum/status_effect/xeno_carnage/proc/carnage_slash(datum/source, mob/living/target, damage)
	SIGNAL_HANDLER
	if(!ishuman(target) || issynth(target))
		return
	UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING)
	INVOKE_ASYNC(src, .proc/do_carnage_slash, source, target, damage)

///Performs on-attack logic
/datum/status_effect/xeno_carnage/proc/do_carnage_slash(datum/source, mob/living/target, damage)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/owner_heal = healing_on_hit
	HEAL_XENO_DAMAGE(owner_xeno, owner_heal)
	adjustOverheal(owner_xeno, owner_heal * 0.5)

	if(plasma_mod >= HIGN_THRESHOLD)
		owner_xeno.AdjustImmobilized(KNOCKDOWN_DURATION)
		ADD_TRAIT(owner_xeno, TRAIT_HANDS_BLOCKED, src)
		target.AdjustKnockdown(KNOCKDOWN_DURATION)

		if(do_after(owner_xeno, KNOCKDOWN_DURATION, FALSE, target, ignore_turf_checks = FALSE))
			owner_xeno.gain_plasma(plasma_gain_on_hit)

	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		for(var/mob/living/carbon/xenomorph/target_xeno AS in cheap_get_xenos_near(owner_xeno, 4))
			if(target_xeno == owner_xeno)
				continue
			var/heal_amount = healing_on_hit
			HEAL_XENO_DAMAGE(target_xeno, heal_amount)
			new /obj/effect/temp_visual/telekinesis(get_turf(target_xeno))
			to_chat(target_xeno, span_notice("You feel your wounds being restored by [owner_xeno]'s pheromones."))

	owner_xeno.remove_status_effect(STATUS_EFFECT_XENO_CARNAGE)

#undef CALC_PLASMA_MOD
#undef HIGN_THRESHOLD
#undef KNOCKDOWN_DURATION

/obj/screen/alert/status_effect/xeno_feast
	name = "Feast"
	desc = "Your health is being restored at the cost of plasma."
	icon_state = "xeno_feast"

/datum/status_effect/xeno_feast
	id = "xeno_feast"
	alert_type = /obj/screen/alert/status_effect/xeno_feast
	///Amount of plasma drained per tick, removes effect if available plasma is less
	var/plasma_drain

/datum/status_effect/xeno_feast/on_creation(mob/living/new_owner, set_duration, plasma_drain)
	owner = new_owner
	duration = set_duration
	src.plasma_drain = plasma_drain
	owner.overlay_fullscreen("xeno_feast", /obj/screen/fullscreen/bloodlust)
	owner.add_filter("[id]2", 2, outline_filter(2, "#61132360"))
	owner.add_filter("[id]1", 1, wave_filter(0.72, 0.24, 0.4, 0.5))
	return ..()

/datum/status_effect/xeno_feast/on_remove()
	. = ..()
	owner.clear_fullscreen("xeno_feast", 0.7 SECONDS)
	owner.remove_filter(list("[id]1", "[id]2"))

/datum/status_effect/xeno_feast/tick()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.plasma_stored < plasma_drain)
		to_chat(X, span_notice("Our feast has come to an end..."))
		X.remove_status_effect(STATUS_EFFECT_XENO_FEAST)
		return
	var/heal_amount = X.maxHealth*0.08
	HEAL_XENO_DAMAGE(X, heal_amount)
	adjustOverheal(X, heal_amount / 2)
	X.use_plasma(plasma_drain)
