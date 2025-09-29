// ***************************************
// *********** Resin Jelly
// ***************************************
/datum/status_effect/resin_jelly_coating
	id = "resin jelly"
	duration = 15 SECONDS
	tick_interval = 30
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/resin_jelly_coating/on_creation(mob/living/new_owner, set_duration)
	if(set_duration)
		duration = set_duration
	return ..()

/datum/status_effect/resin_jelly_coating/on_apply()
	if(!isxeno(owner))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	ADD_TRAIT(X, TRAIT_NON_FLAMMABLE, id)
	X.soft_armor = X.soft_armor.modifyRating(fire = 100)
	X.hard_armor = X.hard_armor.modifyRating(fire = 100)
	X.add_filter("resin_jelly_outline", 2, outline_filter(1, COLOR_TAN_ORANGE))

	var/datum/status_effect/stacking/melting/debuff = X.has_status_effect(STATUS_EFFECT_MELTING)
	if(debuff)
		qdel(debuff)

	return TRUE

/datum/status_effect/resin_jelly_coating/on_remove()
	var/mob/living/carbon/xenomorph/X = owner
	REMOVE_TRAIT(X, TRAIT_NON_FLAMMABLE, id)
	X.soft_armor = X.soft_armor.modifyRating(fire = -100)
	X.hard_armor = X.hard_armor.modifyRating(fire = -100)
	X.remove_filter("resin_jelly_outline")
	owner.balloon_alert(owner, "you're vulnerable again")
	return ..()

/datum/status_effect/resin_jelly_coating/tick(delta_time)
	owner.heal_limb_damage(0, 5)
	return ..()

// ***************************************
// *********** Essence Link
// ***************************************
/obj/effect/ebeam/essence_link
	name = "essence link beam"

/datum/status_effect/stacking/essence_link
	id = "xeno_essence_link"
	tick_interval = 2 SECONDS
	stacks = 0
	stack_decay = -1 //Not meant to decay.
	max_stacks = 3
	consumed_on_threshold = FALSE
	consumed_on_fadeout = FALSE
	alert_type = null
	/// The owner of the link.
	var/mob/living/carbon/xenomorph/link_owner
	/// Whom the owner is linked to.
	var/mob/living/carbon/xenomorph/link_target
	/// References the Essence Link action and its vars.
	var/datum/action/ability/activable/xeno/essence_link/essence_link_action
	/// If the target xeno was within range.
	var/was_within_range = TRUE
	/// Cooldown for passive attunement increase.
	COOLDOWN_DECLARE(attunement_increase)
	/// Delay between plasma warnings. Plasma warnings are issued if there's not enough plasma for the passive regeneration.
	var/plasma_warning_cooldown = 20 SECONDS
	/// Cooldown for the plasma warning.
	COOLDOWN_DECLARE(plasma_warning)
	/// The beam used to represent the link between linked xenos.
	var/datum/beam/current_beam
	/// The percentage of lifesteal given to link_owner based on damage dealt from link_target.
	var/lifesteal_percentage
	/// The additive amount to increase melee damage modifier to the survivor if the link ends due to death.
	var/revenge_modifier

/datum/status_effect/stacking/essence_link/on_creation(mob/living/new_owner, stacks_to_apply, mob/living/carbon/link_target, expected_lifesteal_percentage, expected_revenge_modifier)
	link_owner = new_owner
	src.link_target = link_target
	essence_link_action = link_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	ADD_TRAIT(link_owner, TRAIT_ESSENCE_LINKED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(link_target, TRAIT_ESSENCE_LINKED, TRAIT_STATUS_EFFECT(id))
	RegisterSignals(link_owner, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), PROC_REF(end_link))
	RegisterSignals(link_target, list(COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), PROC_REF(end_link))
	RegisterSignal(link_owner, COMSIG_MOB_DEATH, PROC_REF(end_link_from_death))
	RegisterSignal(link_target, COMSIG_MOB_DEATH, PROC_REF(end_link_from_death))
	toggle_link(TRUE)
	set_lifesteal(expected_lifesteal_percentage)
	revenge_modifier = expected_revenge_modifier
	to_chat(link_owner, span_xenonotice("We have established an Essence Link with [link_target]. Stay within [DRONE_ESSENCE_LINK_RANGE] tiles to maintain it."))
	to_chat(link_target, span_xenonotice("[link_owner] has established an Essence Link with us. Stay within [DRONE_ESSENCE_LINK_RANGE] tiles to maintain it."))
	return ..()

/datum/status_effect/stacking/essence_link/add_stacks(stacks_added)
	. = ..()
	essence_link_action.update_button_icon()
	link_owner.balloon_alert(link_owner, "attunement: [stacks]/[max_stacks]")
	COOLDOWN_START(src, attunement_increase, essence_link_action.attunement_cooldown)
	update_beam()

/datum/status_effect/stacking/essence_link/on_remove()
	to_chat(link_owner, span_xenonotice("The Essence Link between us and [link_target] has been cancelled."))
	to_chat(link_target, span_xenonotice("The Essence Link between us and [link_owner] has been cancelled."))
	toggle_link(FALSE)
	essence_link_action.end_ability()
	UnregisterSignal(link_owner, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))
	UnregisterSignal(link_target, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))
	set_lifesteal(0)
	REMOVE_TRAIT(link_owner, TRAIT_ESSENCE_LINKED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(link_target, TRAIT_ESSENCE_LINKED, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/stacking/essence_link/tick(delta_time)
	var/within_range = get_dist(link_owner, link_target) <= DRONE_ESSENCE_LINK_RANGE
	if(within_range != was_within_range) // Toggles the link depending on whether the linked xenos are still in range or not.
		was_within_range = within_range
		toggle_link(was_within_range)
		link_owner.balloon_alert(link_owner, was_within_range ? ("link reestablished") : ("link faltering!"))
		link_target.balloon_alert(link_target, was_within_range ? ("link reestablished") : ("link faltering!"))

	if(stacks < max_stacks && COOLDOWN_FINISHED(src, attunement_increase))
		add_stacks(1)

	var/remaining_health = link_target.maxHealth - (link_target.getBruteLoss() + link_target.getFireLoss())
	if(stacks < 1 || !was_within_range || remaining_health >= link_target.maxHealth)
		return
	var/heal_amount = link_target.maxHealth * (DRONE_ESSENCE_LINK_REGEN * stacks)
	var/ability_cost = heal_amount * 2
	if(link_owner.plasma_stored < ability_cost)
		if(!COOLDOWN_FINISHED(src, plasma_warning))
			return
		link_owner.balloon_alert(link_owner, "no plasma for link!")
		link_target.balloon_alert(link_target, "no plasma for link!")
		COOLDOWN_START(src, plasma_warning, plasma_warning_cooldown)
		return
	var/leftover_healing = heal_amount
	HEAL_XENO_DAMAGE(link_target, leftover_healing, TRUE)
	link_owner.use_plasma(ability_cost)
	GLOB.round_statistics.drone_essence_link += (heal_amount - leftover_healing)

/// Shares the Resin Jelly buff with the linked xeno.
/datum/status_effect/stacking/essence_link/proc/share_jelly(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/buff_owner
	var/mob/living/carbon/xenomorph/buff_target

	if(stacks < 1)
		return

	if(source == link_target)
		buff_owner = link_target
		buff_target = link_owner
	else
		buff_owner = link_owner
		buff_target = link_target

	buff_owner.balloon_alert(buff_owner, "buff shared")
	buff_target.balloon_alert(buff_target, "buff shared")
	buff_target.visible_message(span_notice("[buff_target]'s chitin begins to gleam with an unseemly glow..."), \
		span_xenonotice("Through the Essence Link, [buff_owner] has shared their resin jelly with us."))
	INVOKE_ASYNC(buff_target, TYPE_PROC_REF(/mob/living/carbon/xenomorph, emote), "roar")
	buff_target.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)

/// Shares heals with the linked xeno.
/datum/status_effect/stacking/essence_link/proc/share_heal(datum/source, amount, amount_mod, passive)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/heal_target

	// Besides the stacks check, also prevents actual damage, decimals of 0, and passive healing.
	if(stacks < 1 || amount > -1 || passive)
		return

	if(source == link_target)
		heal_target = link_owner
	else
		heal_target = link_target

	new /obj/effect/temp_visual/healing(get_turf(heal_target))
	var/heal_amount = clamp(abs(amount) * (DRONE_ESSENCE_LINK_SHARED_HEAL * stacks), 0, heal_target.maxHealth)
	var/leftover_healing = heal_amount
	HEAL_XENO_DAMAGE(heal_target, leftover_healing, TRUE)
	var/sunder_change = heal_target.adjust_sunder(-heal_amount / 10)

	GLOB.round_statistics.drone_essence_link += (heal_amount - leftover_healing)
	GLOB.round_statistics.drone_essence_link_sunder += -sunder_change
	heal_target.balloon_alert(heal_target, "shared heal: +[heal_amount]")

/// Toggles the link signals on or off.
/datum/status_effect/stacking/essence_link/proc/toggle_link(toggle)
	if(!toggle)
		UnregisterSignal(link_owner, list(COMSIG_XENOMORPH_RESIN_JELLY_APPLIED, COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
		UnregisterSignal(link_target, list(COMSIG_XENOMORPH_RESIN_JELLY_APPLIED, COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
		toggle_beam(FALSE)
		return
	RegisterSignal(link_owner, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED, PROC_REF(share_jelly))
	RegisterSignal(link_target, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED, PROC_REF(share_jelly))
	RegisterSignals(link_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(share_heal))
	RegisterSignals(link_target, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(share_heal))
	toggle_beam(TRUE)

/// Toggles the effect beam on or off.
/datum/status_effect/stacking/essence_link/proc/toggle_beam(toggle)
	if(!toggle)
		QDEL_NULL(current_beam)
		return
	current_beam = link_owner.beam(link_target, icon_state= "medbeam", beam_type = /obj/effect/ebeam/essence_link)
	update_beam()

/// Updates the link's appearance.
/datum/status_effect/stacking/essence_link/proc/update_beam()
	current_beam?.visuals.alpha = round(255 / (max_stacks+1 - stacks))

/// Ends the link prematurely via evolution/devolution.
/datum/status_effect/stacking/essence_link/proc/end_link(datum/source)
	SIGNAL_HANDLER
	essence_link_action.end_ability()

/// Ends the link prematurely via death.
/datum/status_effect/stacking/essence_link/proc/end_link_from_death(datum/source, gibbed)
	SIGNAL_HANDLER
	if(!revenge_modifier)
		essence_link_action.end_ability()
		return

	// Need to offload these effects elsewhere since this status effect is being deleted.
	if(source == link_owner)
		link_target.apply_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK_REVENGE, revenge_modifier)
	if(source == link_target)
		link_owner.apply_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK_REVENGE, revenge_modifier)
	essence_link_action.end_ability()

/// Sets the percentage (0 - 1) of damage dealt to be healed and (un)registers signals as necessary.
/datum/status_effect/stacking/essence_link/proc/set_lifesteal(desired_lifesteal_percentage)
	if(lifesteal_percentage && !desired_lifesteal_percentage)
		UnregisterSignal(link_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	if(!lifesteal_percentage && desired_lifesteal_percentage)
		RegisterSignal(link_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(handle_lifesteal))
	lifesteal_percentage = desired_lifesteal_percentage

/// Heals the link_owner a percentage of the damage dealt by the link_target if they're within range.
/datum/status_effect/stacking/essence_link/proc/handle_lifesteal(datum/source, mob/living/attacked_target, damage_dealt, list/damage_modifiers)
	SIGNAL_HANDLER
	if(!was_within_range || !lifesteal_percentage)
		return
	var/damage_to_heal = damage_dealt * lifesteal_percentage
	HEAL_XENO_DAMAGE(link_owner, damage_to_heal, FALSE)
	GLOB.round_statistics.drone_essence_link += (damage_dealt * lifesteal_percentage) - damage_to_heal // Amount actually healed.

// ***************************************
// *********** Salve Regeneration
// ***************************************
/datum/status_effect/salve_regen
	id = "salve regen"
	duration = 15 SECONDS
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The owner of this buff.
	var/mob/living/carbon/xenomorph/buff_owner

/datum/status_effect/salve_regen/on_apply()
	buff_owner = owner
	if(!isxeno(buff_owner))
		return FALSE
	buff_owner.balloon_alert(buff_owner, "salve regenerationg starting")
	return TRUE

/datum/status_effect/salve_regen/on_remove()
	buff_owner.balloon_alert(buff_owner, "salve regeneration ended")
	return ..()

/datum/status_effect/salve_regen/tick(delta_time)
	new /obj/effect/temp_visual/healing(get_turf(buff_owner))
	var/heal_amount = buff_owner.maxHealth * 0.01
	var/leftover_healing = heal_amount
	HEAL_XENO_DAMAGE(buff_owner, leftover_healing, TRUE)
	var/sunder_change = buff_owner.adjust_sunder(-1)
	GLOB.round_statistics.drone_essence_link += (heal_amount - leftover_healing) // While it is true that this comes from Acidic Salve, it is only applied to Essence Link users.
	GLOB.round_statistics.drone_essence_link_sunder += -sunder_change
	return ..()

// ***************************************
// *********** Enhancement
// ***************************************
/particles/drone_enhancement
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "fire"
	color = "#9828CC"
	width = 100
	height = 100
	count = 1000
	spawning = 3
	lifespan = 9
	fade = 12
	grow = 0.04
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 16, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.15), list(0, 0.15))
	gravity = list(0, 0.8)
	scale = generator(GEN_VECTOR, list(0.1, 0.1), list(0.6,0.6), NORMAL_RAND)
	rotation = 0
	spin = generator(GEN_NUM, 10, 20)

/datum/status_effect/drone_enhancement
	id = "drone enhancement"
	duration = -1
	tick_interval = 2 SECONDS
	alert_type = null
	/// Used to track who is giving this buff to the owner.
	var/mob/living/carbon/xenomorph/buffing_xeno
	/// Used to track who is the owner of this buff.
	var/mob/living/carbon/xenomorph/buffed_xeno
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// References the Essence Link action and its vars.
	var/datum/action/ability/activable/xeno/essence_link/essence_link_action
	/// References the Enhancement action and its vars.
	var/datum/action/ability/xeno_action/enhancement/enhancement_action
	/// If the target xeno was within range.
	var/was_within_range = TRUE
	/// The plasma cost per tick of this ability.
	var/ability_cost

/datum/status_effect/drone_enhancement/on_creation(mob/living/new_owner, mob/living/carbon/new_target)
	buffed_xeno = new_owner
	buffing_xeno = new_target
	essence_link_action = buffing_xeno.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	enhancement_action = buffing_xeno.actions_by_path[/datum/action/ability/xeno_action/enhancement]
	ability_cost = round(buffing_xeno.xeno_caste.plasma_max * 0.1)
	RegisterSignal(buffed_xeno, COMSIG_MOB_DEATH, PROC_REF(handle_death))
	RegisterSignal(buffing_xeno, COMSIG_MOB_DEATH, PROC_REF(handle_death))
	INVOKE_ASYNC(buffed_xeno, TYPE_PROC_REF(/mob/living/carbon/xenomorph, emote), "roar2")
	toggle_buff(TRUE)
	return ..()

/datum/status_effect/drone_enhancement/on_remove()
	buffed_xeno.balloon_alert(buffed_xeno, "enhancement inactive")
	buffing_xeno.balloon_alert(buffing_xeno, "enhancement inactive")
	UnregisterSignal(buffed_xeno, COMSIG_MOB_DEATH)
	UnregisterSignal(buffing_xeno, COMSIG_MOB_DEATH)
	toggle_buff(FALSE)
	return ..()

/datum/status_effect/drone_enhancement/tick(delta_time)
	var/within_range = get_dist(buffed_xeno, buffing_xeno) <= DRONE_ESSENCE_LINK_RANGE
	if(within_range != was_within_range)
		was_within_range = within_range
		toggle_buff(was_within_range)

	if(buffing_xeno.plasma_stored < ability_cost)
		enhancement_action.end_ability()
		return
	buffing_xeno.use_plasma(ability_cost)

/// Toggles the buff on or off.
/datum/status_effect/drone_enhancement/proc/toggle_buff(toggle)
	if(!toggle)
		buffed_xeno.xeno_melee_damage_modifier = initial(buffed_xeno.xeno_melee_damage_modifier)
		buffed_xeno.remove_movespeed_modifier(MOVESPEED_ID_ENHANCEMENT)
		toggle_particles(FALSE)
		return
	buffed_xeno.xeno_melee_damage_modifier = enhancement_action.damage_multiplier
	buffed_xeno.add_movespeed_modifier(MOVESPEED_ID_ENHANCEMENT, TRUE, 0, NONE, FALSE, enhancement_action.speed_addition)
	toggle_particles(TRUE)

/// Toggles particles on or off, adjusting their positioning to fit the buff's owner.
/datum/status_effect/drone_enhancement/proc/toggle_particles(toggle)
	var/particle_x = abs(buffed_xeno.pixel_x)
	if(!toggle)
		QDEL_NULL(particle_holder)
		return
	particle_holder = new(buffed_xeno, /particles/drone_enhancement)
	particle_holder.pixel_x = particle_x
	particle_holder.pixel_y = -3

/// Removes the status effect on death.
/datum/status_effect/drone_enhancement/proc/handle_death()
	SIGNAL_HANDLER
	enhancement_action.end_ability()

// ***************************************
// *********** Psychic Link
// ***************************************
#define PSYCHIC_LINK_COLOR "#2a888360"
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
	///If the target xeno was within range
	var/was_within_range = FALSE
	/// The beam used to represent the link between linked xenos.
	var/datum/beam/psylink_beam

/datum/status_effect/xeno_psychic_link/on_creation(mob/living/new_owner, set_duration, mob/living/carbon/target_mob, link_range, redirect_mod, minimum_health, scaling = FALSE)
	owner = new_owner
	duration = set_duration
	src.target_mob = target_mob
	src.link_range = link_range
	src.redirect_mod = redirect_mod
	src.minimum_health = minimum_health
	ADD_TRAIT(target_mob, TRAIT_PSY_LINKED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_PSY_LINKED, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(handle_mob_dead))
	RegisterSignal(target_mob, COMSIG_MOB_DEATH, PROC_REF(handle_mob_dead))
	var/link_message = "[owner] has linked to you and is redirecting some of your injuries. If they get too hurt, the link may be broken."
	if(link_range > 0)
		link_message += " Keep within [link_range] tiles to maintain it."
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(handle_dist))
		RegisterSignal(target_mob, COMSIG_MOVABLE_MOVED, PROC_REF(handle_dist))
		handle_dist()
	else
		link_toggle(TRUE)
	to_chat(target_mob, span_xenonotice(link_message))
	return ..()

/datum/status_effect/xeno_psychic_link/on_remove()
	. = ..()
	UnregisterSignal(target_mob, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	REMOVE_TRAIT(target_mob, TRAIT_PSY_LINKED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_PSY_LINKED, TRAIT_STATUS_EFFECT(id))
	owner.remove_filter(id)
	target_mob.remove_filter(id)
	QDEL_NULL(psylink_beam)
	to_chat(target_mob, span_xenonotice("[owner] has unlinked from you."))
	SEND_SIGNAL(src, COMSIG_XENO_PSYCHIC_LINK_REMOVED)

///Handles the link breaking due to dying
/datum/status_effect/xeno_psychic_link/proc/handle_mob_dead(datum/source)
	SIGNAL_HANDLER
	owner.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

///Handles the link breaking due to distance
/datum/status_effect/xeno_psychic_link/proc/handle_dist(datum/source)
	SIGNAL_HANDLER
	var/within_range = get_dist(owner, target_mob) <= link_range
	if(within_range == was_within_range)
		return
	was_within_range = within_range
	link_toggle(was_within_range)
	to_chat(owner, was_within_range ? span_xenowarning("[target_mob] is within range again.") : span_xenowarning("[target_mob] is too far away."))

///Handles the link toggling on and off
/datum/status_effect/xeno_psychic_link/proc/link_toggle(toggle_on)
	if(toggle_on)
		RegisterSignal(target_mob, COMSIG_XENOMORPH_BURN_DAMAGE, PROC_REF(handle_burn_damage))
		RegisterSignal(target_mob, COMSIG_XENOMORPH_BRUTE_DAMAGE, PROC_REF(handle_brute_damage))
		owner.add_filter(id, 2, outline_filter(2, PSYCHIC_LINK_COLOR))
		target_mob.add_filter(id, 2, outline_filter(2, PSYCHIC_LINK_COLOR))
		psylink_beam = owner.beam(target_mob, icon_state= "medbeam", beam_type = /obj/effect/ebeam/essence_link)
		psylink_beam.visuals.alpha = 127
		return
	UnregisterSignal(target_mob, COMSIG_XENOMORPH_BURN_DAMAGE)
	UnregisterSignal(target_mob, COMSIG_XENOMORPH_BRUTE_DAMAGE)
	owner.remove_filter(id)
	target_mob.remove_filter(id)
	QDEL_NULL(psylink_beam)

///Transfers mitigated burn damage
/datum/status_effect/xeno_psychic_link/proc/handle_burn_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	CALC_DAMAGE_REDUCTION(amount, amount_mod)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.adjustFireLoss(amount)
	if(owner.health <= minimum_health)
		owner.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

///Transfers mitigated brute damage
/datum/status_effect/xeno_psychic_link/proc/handle_brute_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	CALC_DAMAGE_REDUCTION(amount, amount_mod)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.adjustBruteLoss(amount)
	if(owner.health <= minimum_health)
		owner.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

#undef PSYCHIC_LINK_COLOR
#undef CALC_DAMAGE_REDUCTION

///Calculates the effectiveness of parts of the status based on plasma of owner
#define CALC_PLASMA_MOD(xeno) \
	(clamp(1 - xeno.plasma_stored / owner_xeno.xeno_caste.plasma_max, 0.2, 0.8) + 0.2)
#define HIGN_THRESHOLD 0.6
#define KNOCKDOWN_DURATION 1 SECONDS

// ***************************************
// *********** Carnage
// ***************************************
/atom/movable/screen/alert/status_effect/xeno_carnage
	name = "Carnage"
	desc = "Your attacks restore health."
	icon_state = "xeno_carnage"

/datum/status_effect/xeno_carnage
	id = "xeno_carnage"
	alert_type = /atom/movable/screen/alert/status_effect/xeno_carnage
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
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(carnage_slash))

	owner.add_filter(id, 5, rays_filter(size = 25, color = "#c50021", offset = 200, density = 50, y = 7))
	if(plasma_mod >= HIGN_THRESHOLD)
		owner.add_filter("[id]m", 4, color_matrix_filter(list(1 + plasma_mod,0,0,0, -(0.5 + plasma_mod * 1),1,0,0, plasma_mod * 0.8,0,1,0, 0,0,0,1, 0,0,0,0)))

	return ..()

/datum/status_effect/xeno_carnage/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(MOVESPEED_ID_GORGER_CARNAGE)
	to_chat(owner, span_notice("Our bloodlust subsides..."))
	UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(carnage_slash))
	owner.remove_filter(list(id, "[id]m"))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, src)

///Calls slash proc
/datum/status_effect/xeno_carnage/proc/carnage_slash(datum/source, mob/living/target, damage)
	SIGNAL_HANDLER
	if(!ishuman(target) || issynth(target))
		return
	UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING)
	INVOKE_ASYNC(src, PROC_REF(do_carnage_slash), source, target, damage)

///Performs on-attack logic
/datum/status_effect/xeno_carnage/proc/do_carnage_slash(datum/source, mob/living/target, damage)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/owner_heal = healing_on_hit
	HEAL_XENO_DAMAGE(owner_xeno, owner_heal, FALSE)
	owner_xeno.adjustOverheal(owner_heal * 0.5)

	if(plasma_mod >= HIGN_THRESHOLD)
		owner_xeno.AdjustImmobilized(KNOCKDOWN_DURATION)
		ADD_TRAIT(owner_xeno, TRAIT_HANDS_BLOCKED, src)
		target.AdjustKnockdown(KNOCKDOWN_DURATION)

		if(do_after(owner_xeno, KNOCKDOWN_DURATION, IGNORE_HELD_ITEM, target))
			owner_xeno.gain_plasma(plasma_gain_on_hit)
			SEND_SIGNAL(target, COMSIG_XENO_CARNAGE_HIT, owner_xeno.xeno_caste.drain_plasma_gain, owner_xeno)
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		for(var/mob/living/carbon/xenomorph/target_xeno AS in cheap_get_xenos_near(owner_xeno, 4))
			if(target_xeno == owner_xeno)
				continue
			var/heal_amount = healing_on_hit
			HEAL_XENO_DAMAGE(target_xeno, heal_amount, FALSE)
			new /obj/effect/temp_visual/telekinesis(get_turf(target_xeno))
			to_chat(target_xeno, span_notice("You feel your wounds being restored by [owner_xeno]'s pheromones."))

	owner_xeno.remove_status_effect(STATUS_EFFECT_XENO_CARNAGE)

#undef CALC_PLASMA_MOD
#undef HIGN_THRESHOLD
#undef KNOCKDOWN_DURATION

// ***************************************
// *********** Feast
// ***************************************
/atom/movable/screen/alert/status_effect/xeno_feast
	name = "Feast"
	desc = "Your health is being restored at the cost of plasma."
	icon_state = "xeno_feast"

/datum/status_effect/xeno_feast
	id = "xeno_feast"
	alert_type = /atom/movable/screen/alert/status_effect/xeno_feast
	///Amount of plasma drained per tick, removes effect if available plasma is less
	var/plasma_drain

/datum/status_effect/xeno_feast/on_creation(mob/living/new_owner, set_duration, plasma_drain)
	owner = new_owner
	duration = set_duration
	src.plasma_drain = plasma_drain
	owner.overlay_fullscreen("xeno_feast", /atom/movable/screen/fullscreen/animated/bloodlust)
	owner.add_filter("[id]2", 2, outline_filter(2, "#61132360"))
	owner.add_filter("[id]1", 1, wave_filter(0.72, 0.24, 0.4, 0.5))
	return ..()

/datum/status_effect/xeno_feast/on_remove()
	. = ..()
	owner.clear_fullscreen("xeno_feast", 0.7 SECONDS)
	owner.remove_filter(list("[id]1", "[id]2"))

/datum/status_effect/xeno_feast/tick(delta_time)
	var/mob/living/carbon/xenomorph/X = owner
	if(X.plasma_stored < plasma_drain)
		to_chat(X, span_notice("Our feast has come to an end..."))
		X.remove_status_effect(STATUS_EFFECT_XENO_FEAST)
		return
	var/heal_amount = X.maxHealth * 0.08
	HEAL_XENO_DAMAGE(X, heal_amount, FALSE)
	X.adjustOverheal(heal_amount / 2)
	X.use_plasma(plasma_drain)

// ***************************************
// *********** Plasma Fruit buff
// ***************************************
/datum/status_effect/plasma_surge
	id = "plasma_surge"
	alert_type = /atom/movable/screen/alert/status_effect/plasma_surge
	///How much plasma do we instantly restore
	var/flat_amount_restored
	///How much extra plasma should we regenerate over time as a % of our base regen, 1 being twice the regen
	var/bonus_regen

/datum/status_effect/plasma_surge/on_creation(mob/living/new_owner, flat_amount_restored, bonus_regen, set_duration)
	if(!isxeno(new_owner))
		CRASH("Plasma surge was applied on a nonxeno, dont do that")
	duration = set_duration
	src.flat_amount_restored = flat_amount_restored
	src.bonus_regen = bonus_regen
	return ..()

/datum/status_effect/plasma_surge/on_apply()
	. = ..()
	owner.add_filter("plasma_surge_infusion_outline", 3, outline_filter(1, COLOR_CYAN))
	var/mob/living/carbon/xenomorph/X = owner
	X.gain_plasma(flat_amount_restored)
	if(!bonus_regen)
		qdel(src)
	else
		RegisterSignal(owner, COMSIG_XENOMORPH_PLASMA_REGEN, PROC_REF(plasma_surge_regeneration))

/datum/status_effect/plasma_surge/proc/plasma_surge_regeneration(mob/living/carbon/xenomorph/xeno, plasma_mod, seconds_per_tick)
	SIGNAL_HANDLER

	var/mob/living/carbon/xenomorph/X = owner
	if(HAS_TRAIT(X,TRAIT_NOPLASMAREGEN)) //No bonus plasma if you're on a diet
		return
	var/bonus_plasma = X.xeno_caste.plasma_gain * bonus_regen * (1 + X.recovery_aura * 0.05) * seconds_per_tick * XENO_PER_SECOND_LIFE_MOD //Recovery aura multiplier; 5% bonus per full level
	X.gain_plasma(bonus_plasma)

/datum/status_effect/plasma_surge/on_remove()
	. = ..()
	owner.remove_filter("plasma_surge_infusion_outline")
	UnregisterSignal(owner, COMSIG_XENOMORPH_PLASMA_REGEN)

/atom/movable/screen/alert/status_effect/plasma_surge
	name = "Plasma Surge"
	desc = "You have accelerated plasma regeneration."
	icon_state = "drunk" //Close enough

// ***************************************
// *********** Healing Infusion
// ***************************************
/datum/status_effect/healing_infusion
	id = "healing_infusion"
	alert_type = /atom/movable/screen/alert/status_effect/healing_infusion
	//Buff ends whenever we run out of either health or sunder ticks, or time, whichever comes first
	///Health recovery ticks
	var/health_ticks_remaining
	///Sunder recovery ticks
	var/sunder_ticks_remaining
	/// Should the TRAIT_INNATE_HEALING trait be given?
	var/innate_healing = FALSE

/datum/status_effect/healing_infusion/on_creation(mob/living/new_owner, set_duration = HIVELORD_HEALING_INFUSION_DURATION, stacks_to_apply = HIVELORD_HEALING_INFUSION_TICKS, new_innate_healing)
	if(!isxeno(new_owner))
		CRASH("something applied [id] on a nonxeno, dont do that")

	duration = set_duration
	owner = new_owner
	health_ticks_remaining = stacks_to_apply //Apply stacks
	sunder_ticks_remaining = stacks_to_apply
	if(new_innate_healing)
		innate_healing = new_innate_healing
	return ..()


/datum/status_effect/healing_infusion/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_HEALING_INFUSION, TRAIT_STATUS_EFFECT(id))
	if(innate_healing)
		ADD_TRAIT(owner, TRAIT_INNATE_HEALING, TRAIT_STATUS_EFFECT(id))
	owner.add_filter("hivelord_healing_infusion_outline", 3, outline_filter(1, COLOR_VERY_PALE_LIME_GREEN)) //Set our cool aura; also confirmation we have the buff
	RegisterSignal(owner, COMSIG_XENOMORPH_HEALTH_REGEN, PROC_REF(healing_infusion_regeneration)) //Register so we apply the effect whenever the target heals
	RegisterSignal(owner, COMSIG_XENOMORPH_SUNDER_REGEN, PROC_REF(healing_infusion_sunder_regeneration)) //Register so we apply the effect whenever the target heals

/datum/status_effect/healing_infusion/on_remove()
	REMOVE_TRAIT(owner, TRAIT_HEALING_INFUSION, TRAIT_STATUS_EFFECT(id))
	if(innate_healing)
		REMOVE_TRAIT(owner, TRAIT_INNATE_HEALING, TRAIT_STATUS_EFFECT(id))
	owner.remove_filter("hivelord_healing_infusion_outline")
	UnregisterSignal(owner, list(COMSIG_XENOMORPH_HEALTH_REGEN, COMSIG_XENOMORPH_SUNDER_REGEN))

	new /obj/effect/temp_visual/telekinesis(get_turf(owner)) //Wearing off VFX
	new /obj/effect/temp_visual/healing(get_turf(owner))

	owner.balloon_alert(owner, "regeneration inactive")
	owner.playsound_local(owner, 'sound/voice/hiss5.ogg', 25)

	return ..()

///Called when the target xeno regains HP via heal_wounds in life.dm
/datum/status_effect/healing_infusion/proc/healing_infusion_regeneration(mob/living/carbon/xenomorph/patient, heal_data, seconds_per_tick)
	SIGNAL_HANDLER

	if(!health_ticks_remaining)
		qdel(src)
		return

	health_ticks_remaining-- //Decrement health ticks

	new /obj/effect/temp_visual/healing(get_turf(patient)) //Cool SFX

	var/total_heal_amount = 6 + (patient.maxHealth * 0.03) * seconds_per_tick * XENO_PER_SECOND_LIFE_MOD //Base amount 6 HP plus 3% of max
	if(patient.recovery_aura)
		total_heal_amount *= (1 + patient.recovery_aura * 0.05) //Recovery aura multiplier; 5% bonus per full level

	//Healing pool has been calculated; now to decrement it
	var/brute_amount = min(patient.bruteloss, total_heal_amount)
	if(brute_amount)
		patient.adjustBruteLoss(-brute_amount, updating_health = TRUE)
		total_heal_amount = max(0, total_heal_amount - brute_amount) //Decrement from our heal pool the amount of brute healed

	if(!total_heal_amount) //no healing left, no need to continue
		return

	var/burn_amount = min(patient.fireloss, total_heal_amount)
	if(burn_amount)
		patient.adjustFireLoss(-burn_amount, updating_health = TRUE)


///Called when the target xeno regains Sunder via heal_wounds in life.dm
/datum/status_effect/healing_infusion/proc/healing_infusion_sunder_regeneration(mob/living/carbon/xenomorph/patient, seconds_per_tick)
	SIGNAL_HANDLER

	if(!sunder_ticks_remaining)
		qdel(src)
		return

	if(!patient.loc_weeds_type) //Doesn't work if we're not on weeds
		return

	sunder_ticks_remaining-- //Decrement sunder ticks

	new /obj/effect/temp_visual/telekinesis(get_turf(patient)) //Visual confirmation

	patient.adjust_sunder(-1.5 * (1 + patient.recovery_aura * 0.05) * seconds_per_tick * XENO_PER_SECOND_LIFE_MOD) //5% bonus per rank of our recovery aura

/atom/movable/screen/alert/status_effect/healing_infusion
	name = "Healing Infusion"
	desc = "You have accelerated natural healing."
	icon_state = "healing_infusion"

// ***************************************
// *********** Drain Surge
// ***************************************
/datum/status_effect/drain_surge
	id = "drain surge"
	duration = 10 SECONDS
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// The amount of soft armor to add/remove from the owner.
	var/armor_modifier = SENTINEL_DRAIN_SURGE_ARMOR_MOD
	/// The amount of melee damage modifier to add/remove from the owner.
	var/damage_modifier = 0
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/status_effect/drain_surge/on_creation(mob/living/new_owner, new_armor_modifier, new_damage_modifier)
	if(new_armor_modifier)
		armor_modifier = new_armor_modifier
	if(new_damage_modifier)
		damage_modifier = new_damage_modifier
	return ..()

/datum/status_effect/drain_surge/on_apply()
	if(!isxeno(owner))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	X.soft_armor = X.soft_armor.modifyAllRatings(armor_modifier)
	X.xeno_melee_damage_modifier += damage_modifier
	X.visible_message(span_danger("[X]'s [armor_modifier ? "chitin" : "claws"] glows with a vicious green!"), \
	span_notice("You imbue your [armor_modifier ? "chitinous armor" : "claws"] with the toxins of your victim!"), null, 5)
	X.color = "#7FFF00"
	particle_holder = new(X, /particles/drain_surge)
	particle_holder.pixel_x = 11
	particle_holder.pixel_y = 12
	return TRUE

/datum/status_effect/drain_surge/on_remove()
	var/mob/living/carbon/xenomorph/X = owner
	X.soft_armor = X.soft_armor.modifyAllRatings(-armor_modifier)
	X.xeno_melee_damage_modifier -= damage_modifier
	X.visible_message(span_danger("[X]'s [armor_modifier ? "chitin" : "claws"] loses its green glow..."), \
	span_notice("Your [armor_modifier ? "chitinous armor" : "claws"] loses its glow."), null, 5)
	X.color = "#FFFFFF"
	QDEL_NULL(particle_holder)
	return ..()

/particles/drain_surge
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "drip"
	width = 100
	height = 100
	count = 1000
	spawning = 0.5
	lifespan = 9
	fade = 8
	fadein = 1
	grow = 0
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 9, 9, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.15), list(0, 0.15))
	gravity = list(0, -0.8)
	scale = 0.6
	rotation = 0
	spin = 0

// ***************************************
// *********** Blessings
// ***************************************
/datum/status_effect/blessing
	duration = -1
	tick_interval = 5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The owner of this buff.
	var/mob/living/carbon/xenomorph/buff_owner
	///Aura strength of the puppeteer who gave this effect
	var/strength = 1
	///weakref to the puppeteer to set strength
	var/datum/weakref/puppeteer

/datum/status_effect/blessing/tick(delta_time)
	var/mob/living/carbon/xenomorph/xeno = puppeteer?.resolve()
	if(!xeno)
		return
	strength = xeno.xeno_caste.aura_strength

/datum/status_effect/blessing/on_creation(mob/living/new_owner, mob/living/carbon/xenomorph/caster)
	owner = new_owner
	puppeteer = WEAKREF(caster)
	strength = caster.xeno_caste.aura_strength
	return ..()

/datum/status_effect/blessing/frenzy
	id = "blessing of frenzy"

/datum/status_effect/blessing/frenzy/on_apply()
	buff_owner = owner
	if(!isxeno(buff_owner))
		return FALSE
	buff_owner.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, strength * -0.2)
	return TRUE

/datum/status_effect/blessing/frenzy/on_remove()
	buff_owner.remove_movespeed_modifier(type)
	return ..()

/datum/status_effect/blessing/fury
	id = "blessing of fury"
	///the modifier we apply to the xenos melee damage modifier
	var/modifier

/datum/status_effect/blessing/fury/on_apply()
	buff_owner = owner
	if(!isxeno(buff_owner))
		return FALSE
	modifier = strength * 0.07
	buff_owner.xeno_melee_damage_modifier += modifier
	return TRUE

/datum/status_effect/blessing/fury/on_remove()
	buff_owner.xeno_melee_damage_modifier -= modifier
	return ..()

/datum/status_effect/blessing/warding
	id = "blessing of warding"
	///A holder for the exact armor modified by this status effect
	var/datum/armor/armor_modifier

/datum/status_effect/blessing/warding/on_apply()
	if(!isxeno(owner))
		return FALSE
	armor_modifier = getArmor(37.8 * strength ,8.1 * strength ,13.5 * strength ,8.1 * strength)
	owner.soft_armor = owner.soft_armor.attachArmor(armor_modifier)
	return TRUE

/datum/status_effect/blessing/warding/on_remove()
	owner.soft_armor = owner.soft_armor.detachArmor(armor_modifier)
	armor_modifier = null
	return ..()

// ***************************************
// *********** Queen Screeches
// ***************************************
/datum/status_effect/frenzy_screech
	id = "frenzy_screech"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 30 SECONDS
	// How much should melee damage modifier increase by?
	var/modifier = 0.1

/datum/status_effect/frenzy_screech/on_apply()
	if(!isxeno(owner))
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.xeno_melee_damage_modifier += modifier
	xeno_owner.add_filter("frenzy_screech_outline", 3, outline_filter(1, COLOR_VIVID_RED))
	return TRUE

/datum/status_effect/frenzy_screech/on_remove()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.xeno_melee_damage_modifier -= modifier
	xeno_owner.remove_filter("frenzy_screech_outline")
	return ..()

// ***************************************
// *********** Baton Pass
// ***************************************
/atom/movable/screen/alert/status_effect/baton_pass
	name = "Baton Pass"
	desc = "Adrenaline is pushing your muscles to the limit!"
	icon_state = "xeno_carnage"

/datum/status_effect/baton_pass
	id = "xeno_batonpass"
	alert_type = /atom/movable/screen/alert/status_effect/baton_pass
	duration = 6 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/status_effect/baton_pass/on_apply()
	if(!isxeno(owner))
		return FALSE
	var/mob/living/carbon/xenomorph/owner_xeno = owner

	particle_holder = new(owner_xeno, /particles/baton_pass)
	var/particle_x = abs(owner_xeno.pixel_x)
	particle_holder.pixel_x = particle_x
	particle_holder.pixel_y = -3

	//only slower xenos get better movespeed amplify. No gigaspeed runners
	var/movespeed_mod =((owner_xeno.xeno_caste.speed <= -1) ? -0.1 : (owner_xeno.xeno_caste.speed <= -0.8) ? -0.2 : -0.4)
	owner_xeno.add_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_BATON_PASS, TRUE, 1, NONE, TRUE, movespeed_mod)

	to_chat(owner, span_notice("We feel on top of the world! Go, go, go!"))
	owner_xeno.Shake(duration = 6 SECONDS, shake_interval = 0.08 SECONDS)
	owner_xeno.emote("roar")

	return ..()

/datum/status_effect/baton_pass/on_remove()
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.remove_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_BATON_PASS)
	to_chat(owner, span_notice("We come down from our adrenaline high."))
	QDEL_NULL(particle_holder)

/particles/baton_pass
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "up_arrow"
	color = "#77bfe9"
	width = 100
	height = 100
	count = 1000
	spawning = 3
	lifespan = 9
	fade = 12
	grow = 0.04
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 16, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.15), list(0, 0.15))
	gravity = list(0, 0.8)
	scale = generator(GEN_VECTOR, list(0.1, 0.1), list(0.6,0.6), NORMAL_RAND)
	rotation = 0
	spin = generator(GEN_NUM, 10, 20)

/datum/status_effect/essence_link_revenge
	id = "essence_link_revenge"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 7 SECONDS
	// How much should the xenomorph owner's melee_damage_modifier be increased by?
	var/damage_modifier = 0

/datum/status_effect/essence_link_revenge/on_creation(mob/living/new_owner, new_damage_modifier)
	owner = new_owner
	damage_modifier = new_damage_modifier
	return ..()

/datum/status_effect/essence_link_revenge/on_apply()
	. = ..()
	if(!isxeno(owner) || !damage_modifier)
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.xeno_melee_damage_modifier += damage_modifier
	xeno_owner.add_filter("[id]_outline", 3, outline_filter(1, COLOR_VIVID_RED))

/datum/status_effect/essence_link_revenge/on_remove()
	if(!isxeno(owner) || !damage_modifier)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.xeno_melee_damage_modifier -= damage_modifier
	xeno_owner.remove_filter("[id]_outline")
