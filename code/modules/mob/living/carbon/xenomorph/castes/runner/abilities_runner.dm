// ***************************************
// *********** Runner's Pounce
// ***************************************
#define RUNNER_POUNCE_RANGE 6 // in tiles
#define RUNNER_SAVAGE_DAMAGE_MINIMUM 15
#define RUNNER_SAVAGE_COOLDOWN 30 SECONDS

/datum/action/ability/activable/xeno/pounce/runner
	desc = "Leap at your target, tackling and disarming them. Alternate use toggles Savage off or on."
	action_icon_state = "pounce_savage_on"
	ability_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RUNNER_POUNCE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TOGGLE_SAVAGE,
	)
	pounce_range = RUNNER_POUNCE_RANGE
	/// Whether Savage is active or not.
	var/savage_activated = TRUE
	/// Savage's cooldown.
	COOLDOWN_DECLARE(savage_cooldown)

/datum/action/ability/activable/xeno/pounce/runner/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/savage_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	savage_maptext.pixel_x = 12
	savage_maptext.pixel_y = -5
	visual_references[VREF_MUTABLE_SAVAGE_COOLDOWN] = savage_maptext

/datum/action/ability/activable/xeno/pounce/runner/alternate_action_activate()
	savage_activated = !savage_activated
	owner.balloon_alert(owner, "Savage [savage_activated ? "activated" : "deactivated"]")
	action_icon_state = "pounce_savage_[savage_activated? "on" : "off"]"
	update_button_icon()

/datum/action/ability/activable/xeno/pounce/runner/mob_hit(datum/source, mob/living/living_target)
	. = ..()
	if(!savage_activated)
		return
	if(!COOLDOWN_CHECK(src, savage_cooldown))
		owner.balloon_alert(owner, "Savage on cooldown ([COOLDOWN_TIMELEFT(src, savage_cooldown) * 0.1]s)")
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/savage_damage = max(RUNNER_SAVAGE_DAMAGE_MINIMUM, xeno_owner.plasma_stored * 0.15)
	var/savage_cost = savage_damage * 2
	if(xeno_owner.plasma_stored < savage_cost)
		owner.balloon_alert(owner, "Not enough plasma to Savage ([savage_cost])")
		return
	living_target.attack_alien_harm(xeno_owner, savage_damage)
	xeno_owner.use_plasma(savage_cost)
	COOLDOWN_START(src, savage_cooldown, RUNNER_SAVAGE_COOLDOWN)
	START_PROCESSING(SSprocessing, src)
	GLOB.round_statistics.runner_savage_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_savage_attacks")

/datum/action/ability/activable/xeno/pounce/runner/process()
	if(COOLDOWN_CHECK(src, savage_cooldown))
		button.cut_overlay(visual_references[VREF_MUTABLE_SAVAGE_COOLDOWN])
		owner.balloon_alert(owner, "Savage ready")
		owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
		STOP_PROCESSING(SSprocessing, src)
		return
	button.cut_overlay(visual_references[VREF_MUTABLE_SAVAGE_COOLDOWN])
	var/mutable_appearance/cooldown = visual_references[VREF_MUTABLE_SAVAGE_COOLDOWN]
	cooldown.maptext = MAPTEXT("[round(COOLDOWN_TIMELEFT(src, savage_cooldown) * 0.1)]s")
	visual_references[VREF_MUTABLE_SAVAGE_COOLDOWN] = cooldown
	button.add_overlay(visual_references[VREF_MUTABLE_SAVAGE_COOLDOWN])


// ***************************************
// *********** Evasion
// ***************************************
#define RUNNER_EVASION_DURATION 2 //seconds
#define RUNNER_EVASION_MAX_DURATION 6 //seconds
#define RUNNER_EVASION_RUN_DELAY 0.5 SECONDS // If the time since the Runner last moved is equal to or greater than this, its Evasion ends.
#define RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD 120 // If we dodge this much damage times our streak count plus 1 while evading, refresh the cooldown of Evasion.

/datum/action/ability/xeno_action/evasion
	name = "Evasion"
	action_icon_state = "evasion_on"
	desc = "Take evasive action, forcing non-friendly projectiles that would hit you to miss for a short duration so long as you keep moving. Alternate use toggles Auto Evasion off or on."
	ability_cost = 75
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EVASION,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_AUTO_EVASION,
	)
	/// Whether auto evasion is on or off.
	var/auto_evasion = TRUE
	/// Whether evasion is currently active
	var/evade_active = FALSE
	/// How long our Evasion will last.
	var/evasion_duration = 0
	/// Current amount of Evasion stacks.
	var/evasion_stacks = 0

/datum/action/ability/xeno_action/evasion/on_cooldown_finish()
	. = ..()
	owner.balloon_alert(owner, "Evasion ready")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)

/datum/action/ability/xeno_action/evasion/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.on_fire)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "Can't while on fire!")
		return FALSE

/datum/action/ability/xeno_action/evasion/alternate_action_activate()
	auto_evasion = !auto_evasion
	owner.balloon_alert(owner, "Auto Evasion [auto_evasion ? "activated" : "deactivated"]")
	action_icon_state = "evasion_[auto_evasion? "on" : "off"]"
	update_button_icon()

/datum/action/ability/xeno_action/evasion/action_activate()
	succeed_activate()
	add_cooldown()
	if(evade_active)
		evasion_stacks = 0
		evasion_duration = min(evasion_duration + RUNNER_EVASION_DURATION, RUNNER_EVASION_MAX_DURATION)
		owner.balloon_alert(owner, "Extended evasion: [evasion_duration]s.")
		return
	evade_active = TRUE
	evasion_duration = RUNNER_EVASION_DURATION
	owner.balloon_alert(owner, "Begin evasion: [evasion_duration]s.")
	to_chat(owner, span_highdanger("We take evasive action, making us impossible to hit."))
	START_PROCESSING(SSprocessing, src)
	RegisterSignals(owner, list(COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_LIVING_IGNITED), PROC_REF(evasion_debuff_check))
	RegisterSignal(owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(evasion_dodge))
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, PROC_REF(evasion_flamer_hit))
	RegisterSignal(owner, COMSIG_LIVING_PRE_THROW_IMPACT, PROC_REF(evasion_throw_dodge))
	GLOB.round_statistics.runner_evasions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_evasions")

/datum/action/ability/xeno_action/evasion/process()
	var/mob/living/carbon/xenomorph/runner/runner_owner = owner
	runner_owner.hud_set_evasion(evasion_duration)
	if(evasion_duration <= 0)
		evasion_deactivate()
		return
	evasion_duration--

/**
 * Called when the owner is hit by a flamethrower projectile.
 * Reduces evasion stacks based on the damage received.
*/
/datum/action/ability/xeno_action/evasion/proc/evasion_flamer_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	if(!(proj.ammo.flags_ammo_behavior & AMMO_FLAME))
		return
	evasion_stacks = max(0, evasion_stacks - proj.damage) // We lose evasion stacks equal to the burn damage.
	if(evasion_stacks)
		owner.balloon_alert(owner, "Evasion reduced, damaged")
		to_chat(owner, span_danger("The searing fire compromises our ability to dodge![RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks > 0 ? " We must dodge [RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks] more projectile damage before Evasion's cooldown refreshes." : ""]"))
	else // If we have no stacks left, disable Evasion.
		evasion_deactivate()

/**
 * Called after getting hit with an Evasion disabling debuff.
 * Checks if evasion is active, and if the debuff inflicted any stacks, disabling Evasion if so.
*/
/datum/action/ability/xeno_action/evasion/proc/evasion_debuff_check(datum/source, amount)
	SIGNAL_HANDLER
	if(!(amount > 0) || !evade_active)
		return
	evasion_deactivate()

/// Deactivates Evasion, clearing signals, vars, etc.
/datum/action/ability/xeno_action/evasion/proc/evasion_deactivate()
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(owner, list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_LIVING_IGNITED,
		COMSIG_XENO_PROJECTILE_HIT,
		COMSIG_LIVING_PRE_THROW_IMPACT,
		COMSIG_ATOM_BULLET_ACT
		))
	evade_active = FALSE
	evasion_stacks = 0
	evasion_duration = 0
	owner.balloon_alert(owner, "Evasion ended")
	owner.playsound_local(owner, 'sound/voice/hiss5.ogg', 50)
	var/mob/living/carbon/xenomorph/runner/runner_owner = owner
	runner_owner.hud_set_evasion(evasion_duration)

/// Determines whether or not a thrown projectile is dodged while the Evasion ability is active
/datum/action/ability/xeno_action/evasion/proc/evasion_throw_dodge(datum/source, atom/movable/proj)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!evade_active) //If evasion is not active we don't dodge
		return NONE
	if((xeno_owner.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return NONE
	if(isitem(proj))
		var/obj/item/I = proj
		evasion_stacks += I.throwforce //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes equal to the thrown force
	evasion_dodge_fx(proj)
	return COMPONENT_PRE_THROW_IMPACT_HIT

/// This is where the dodgy magic happens
/datum/action/ability/xeno_action/evasion/proc/evasion_dodge(datum/source, obj/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(!evade_active) //If evasion is not active we don't dodge
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if((xeno_owner.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return FALSE
	if(xeno_owner.issamexenohive(proj.firer)) //We automatically dodge allied projectiles at no cost, and no benefit to our evasion stacks
		return COMPONENT_PROJECTILE_DODGE
	if(proj.ammo.flags_ammo_behavior & AMMO_FLAME) //We can't dodge literal fire
		return FALSE
	if(proj.original_target == xeno_owner && proj.distance_travelled < 2) //Pointblank shot.
		return FALSE
	if(!(proj.ammo.flags_ammo_behavior & AMMO_SENTRY) && !xeno_owner.fire_stacks) //We ignore projectiles from automated sources/sentries for the purpose of contributions towards our cooldown refresh; also fire prevents accumulation of evasion stacks
		evasion_stacks += proj.damage //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes
	evasion_dodge_fx(proj)
	return COMPONENT_PROJECTILE_DODGE

/// Handles dodge effects and visuals for the Evasion ability.
/datum/action/ability/xeno_action/evasion/proc/evasion_dodge_fx(atom/movable/proj)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.visible_message(span_warning("[xeno_owner] effortlessly dodges the [proj.name]!"), \
	span_xenodanger("We effortlessly dodge the [proj.name]![(RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks) > 0 && evasion_stacks > 0 ? " We must dodge [RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks] more projectile damage before [src]'s cooldown refreshes." : ""]"))
	xeno_owner.add_filter("runner_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/atom, remove_filter), "runner_evasion"), 0.5 SECONDS)
	xeno_owner.do_jitter_animation(4000)
	if(evasion_stacks >= RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD && cooldown_remaining()) //We have more evasion stacks than needed to refresh our cooldown, while being on cooldown.
		clear_cooldown()
		if(auto_evasion && xeno_owner.plasma_stored >= ability_cost)
			action_activate()
	var/turf/current_turf = get_turf(xeno_owner) //location of after image SFX
	playsound(current_turf, pick('sound/effects/throw.ogg','sound/effects/alien_tail_swipe1.ogg', 'sound/effects/alien_tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/xenomorph/afterimage/after_image
	for(var/i=0 to 2) //number of after images
		after_image = new /obj/effect/temp_visual/xenomorph/afterimage(current_turf, owner) //Create the after image.
		after_image.pixel_x = pick(randfloat(xeno_owner.pixel_x * 3, xeno_owner.pixel_x * 1.5), rand(0, xeno_owner.pixel_x * -1)) //Variation on the X position


// ***************************************
// *********** Snatch
// ***************************************
/datum/action/ability/activable/xeno/snatch
	name = "Snatch"
	action_icon_state = "snatch"
	desc = "Take an item equipped by your target in your mouth, and carry it away."
	ability_cost = 75
	cooldown_duration = 60 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SNATCH,
	)
	target_flags = ABILITY_MOB_TARGET
	///If the runner have an item
	var/obj/item/stolen_item = FALSE
	///Mutable appearance of the stolen item
	var/mutable_appearance/stolen_appearance
	///A list of slot to check for items, in order of priority
	var/static/list/slots_to_steal_from = list(
		SLOT_S_STORE,
		SLOT_BACK,
		SLOT_SHOES,
	)

/datum/action/ability/activable/xeno/snatch/action_activate()
	if(!stolen_item)
		return ..()
	drop_item()

/datum/action/ability/activable/xeno/snatch/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!owner.Adjacent(A))
		if(!silent)
			owner.balloon_alert(owner, "Cannot reach")
		return FALSE
	if(!ishuman(A))
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE
	var/mob/living/carbon/human/target = A
	if(target.stat == DEAD)
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE
	if(target.status_flags & GODMODE)
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE

/datum/action/ability/activable/xeno/snatch/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(owner, 0.5 SECONDS, IGNORE_HELD_ITEM, A, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = X.health))))
		return FALSE
	var/mob/living/carbon/human/victim = A
	stolen_item = victim.get_active_held_item()
	if(!stolen_item)
		stolen_item = victim.get_inactive_held_item()
		for(var/slot in slots_to_steal_from)
			stolen_item = victim.get_item_by_slot(slot)
			if(stolen_item)
				break
	if(!stolen_item)
		victim.balloon_alert(owner, "Snatch failed, no item")
		return fail_activate()
	playsound(owner, 'sound/voice/alien_pounce2.ogg', 30)
	victim.dropItemToGround(stolen_item, TRUE)
	stolen_item.forceMove(owner)
	stolen_appearance = mutable_appearance(stolen_item.icon, stolen_item.icon_state)
	stolen_appearance.layer = ABOVE_OBJ_LAYER
	addtimer(CALLBACK(src, PROC_REF(drop_item), stolen_item), 3 SECONDS)
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(owner_turned))
	owner.add_movespeed_modifier(MOVESPEED_ID_SNATCH, TRUE, 0, NONE, TRUE, 2)
	owner_turned(null, null, owner.dir)
	succeed_activate()
	add_cooldown()

///Signal handler to update the item overlay when the owner is changing dir
/datum/action/ability/activable/xeno/snatch/proc/owner_turned(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!new_dir || new_dir == old_dir)
		return
	owner.overlays -= stolen_appearance
	var/matrix/new_transform = stolen_appearance.transform
	switch(old_dir)
		if(NORTH)
			new_transform.Translate(-15, -12)
		if(SOUTH)
			new_transform.Translate(-15, 12)
		if(EAST)
			new_transform.Translate(-35, 0)
		if(WEST)
			new_transform.Translate(5, 0)
	switch(new_dir)
		if(NORTH)
			new_transform.Translate(15, 12)
		if(SOUTH)
			new_transform.Translate(15, -12)
		if(EAST)
			new_transform.Translate(35, 0)
		if(WEST)
			new_transform.Translate(-5, 0)
	stolen_appearance.transform = new_transform
	owner.overlays += stolen_appearance

///Force the xeno owner to drop the stolen item
/datum/action/ability/activable/xeno/snatch/proc/drop_item()
	if(!stolen_item)
		return
	owner.remove_movespeed_modifier(MOVESPEED_ID_SNATCH)
	stolen_item.forceMove(get_turf(owner))
	stolen_item = null
	owner.overlays -= stolen_appearance
	playsound(owner, 'sound/voice/alien_pounce2.ogg', 30, frequency = -1)
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)

