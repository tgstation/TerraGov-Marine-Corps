// ***************************************
// *********** Runner's Pounce
// ***************************************
#define RUNNER_POUNCE_RANGE 6 // in tiles
#define RUNNER_POUNCE_SPEED 2
#define RUNNER_POUNCE_STUN_DURATION 2 SECONDS
#define RUNNER_POUNCE_STANDBY_DURATION 0.5 SECONDS
#define RUNNER_POUNCE_SHIELD_STUN_DURATION 3 SECONDS
#define RUNNER_POUNCE_BONUS_DAMAGE 25

/datum/action/xeno_action/activable/runner_pounce
	name = "Pounce (Runner)"
	ability_name = "Pounce (Runner)"
	desc = "Leap at your target, tackling and disarming them. Alternate use toggles Savage off or on."
	action_icon_state = "pounce_savage_on"
	plasma_cost = 10
	cooldown_timer = 13 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RUNNER_POUNCE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TOGGLE_SAVAGE,
	)
	use_state_flags = XACT_USE_BUCKLED
	/// Whether Savage is active or not.
	var/savage_activated = TRUE

/datum/action/xeno_action/activable/runner_pounce/on_cooldown_finish()
	owner.balloon_alert(owner, "Pounce ready")
	playsound(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/runner_pounce/alternate_action_activate()
	savage_activated = !savage_activated
	owner.balloon_alert(owner, "Savage [savage_activated ? "activated" : "deactivated"]")
	action_icon_state = "pounce_savage_[savage_activated? "on" : "off"]"
	update_button_icon()

/datum/action/xeno_action/activable/runner_pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/runner_pounce/use_ability(atom/A)
	if(owner.layer != MOB_LAYER)
		owner.layer = MOB_LAYER
		var/datum/action/xeno_action/xenohide/hide_action = owner.actions_by_path[/datum/action/xeno_action/xenohide]
		hide_action?.button?.cut_overlay(mutable_appearance('icons/Xeno/actions.dmi', "selected_purple_frame", ACTION_LAYER_ACTION_ICON_STATE, FLOAT_PLANE)) // Removes Hide action icon border
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(movement_fx))
	RegisterSignal(owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(object_hit))
	RegisterSignal(owner, COMSIG_XENO_LIVING_THROW_HIT, PROC_REF(mob_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(pounce_complete))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.usedPounce = TRUE
	xeno_owner.pass_flags |= PASS_LOW_STRUCTURE|PASS_FIRE|PASS_XENO
	xeno_owner.throw_at(A, RUNNER_POUNCE_RANGE, RUNNER_POUNCE_SPEED, xeno_owner)
	addtimer(CALLBACK(src, PROC_REF(reset_pass_flags)), 0.6 SECONDS)
	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/runner_pounce/proc/movement_fx()
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/xenomorph/afterimage(get_turf(owner), owner) //Create the after image.

/datum/action/xeno_action/activable/runner_pounce/proc/object_hit(datum/source, obj/object_target, speed)
	SIGNAL_HANDLER
	object_target.hitby(owner, speed)
	pounce_complete()

/datum/action/xeno_action/activable/runner_pounce/proc/mob_hit(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	if(living_target.stat)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(ishuman(living_target) && (living_target.dir in reverse_nearby_direction(living_target.dir)))
		var/mob/living/carbon/human/human_target = living_target
		if(!human_target.check_shields(COMBAT_TOUCH_ATTACK, 30, "melee"))
			xeno_owner.Paralyze(RUNNER_POUNCE_SHIELD_STUN_DURATION)
			xeno_owner.set_throwing(FALSE)
			return COMPONENT_KEEP_THROWING
	playsound(living_target.loc, 'sound/voice/alien_pounce.ogg', 25, TRUE)
	xeno_owner.Immobilize(RUNNER_POUNCE_STANDBY_DURATION)
	xeno_owner.forceMove(get_turf(living_target))
	living_target.Knockdown(RUNNER_POUNCE_STUN_DURATION)
	if(savage_activated)
		if(xeno_owner.plasma_stored < xeno_owner.xeno_caste.plasma_max * 0.4)
			owner.balloon_alert(owner, "Not enough plasma to Savage")
			pounce_complete()
			return
		xeno_owner.use_plasma(xeno_owner.xeno_caste.plasma_max * 0.4)
		living_target.attack_alien_harm(xeno_owner, RUNNER_POUNCE_BONUS_DAMAGE)
		GLOB.round_statistics.runner_savage_attacks++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_savage_attacks")
	pounce_complete()

/datum/action/xeno_action/activable/runner_pounce/proc/pounce_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT, COMSIG_MOVABLE_POST_THROW))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE_END)

/datum/action/xeno_action/activable/runner_pounce/proc/reset_pass_flags()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.pass_flags = initial(xeno_owner.pass_flags)

/datum/action/xeno_action/activable/runner_pounce/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/runner_pounce/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, RUNNER_POUNCE_RANGE))
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE


// ***************************************
// *********** Evasion
// ***************************************
#define RUNNER_EVASION_DURATION 2 //seconds
#define RUNNER_EVASION_MAX_DURATION 6 //seconds
#define RUNNER_EVASION_RUN_DELAY 0.5 SECONDS // If the time since the Runner last moved is equal to or greater than this, its Evasion ends.
#define RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD 120 // If we dodge this much damage times our streak count plus 1 while evading, refresh the cooldown of Evasion.

/datum/action/xeno_action/evasion
	name = "Evasion"
	action_icon_state = "evasion_on"
	desc = "Take evasive action, forcing non-friendly projectiles that would hit you to miss for a short duration so long as you keep moving. Alternate use toggles Auto Evasion off or on."
	plasma_cost = 75
	cooldown_timer = 10 SECONDS
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
	/// How much damage we need to dodge to trigger Evasion's cooldown reset.
	var/evasion_stack_target = RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD

/datum/action/xeno_action/evasion/on_cooldown_finish()
	. = ..()
	owner.balloon_alert(owner, "Evasion ready")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)

/datum/action/xeno_action/evasion/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.on_fire)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "Can't while on fire!")
		return FALSE

/datum/action/xeno_action/evasion/alternate_action_activate()
	auto_evasion = !auto_evasion
	owner.balloon_alert(owner, "Auto Evasion [auto_evasion ? "activated" : "deactivated"]")
	action_icon_state = "evasion_[auto_evasion? "on" : "off"]"
	update_button_icon()

/datum/action/xeno_action/evasion/action_activate()
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

/datum/action/xeno_action/evasion/process()
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
/datum/action/xeno_action/evasion/proc/evasion_flamer_hit(datum/source, obj/projectile/proj)
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
/datum/action/xeno_action/evasion/proc/evasion_debuff_check(datum/source, amount)
	SIGNAL_HANDLER
	if(!(amount > 0) || !evade_active)
		return
	evasion_deactivate()

/// Deactivates Evasion, clearing signals, vars, etc.
/datum/action/xeno_action/evasion/proc/evasion_deactivate()
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
	evade_active = FALSE //Evasion is no longer active
	evasion_stacks = 0
	owner.balloon_alert(owner, "Evasion ended")
	owner.playsound_local(owner, 'sound/voice/hiss5.ogg', 50)
	STOP_PROCESSING(SSprocessing, src)

/// Determines whether or not a thrown projectile is dodged while the Evasion ability is active
/datum/action/xeno_action/evasion/proc/evasion_throw_dodge(datum/source, atom/movable/proj)
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
/datum/action/xeno_action/evasion/proc/evasion_dodge(datum/source, obj/projectile/proj, cardinal_move, uncrossing)
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
	if(!(proj.ammo.flags_ammo_behavior & AMMO_SENTRY) && !xeno_owner.fire_stacks) //We ignore projectiles from automated sources/sentries for the purpose of contributions towards our cooldown refresh; also fire prevents accumulation of evasion stacks
		evasion_stacks += proj.damage //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes
	evasion_dodge_fx(proj)
	return COMPONENT_PROJECTILE_DODGE

/// Handles dodge effects and visuals for the Evasion ability.
/datum/action/xeno_action/evasion/proc/evasion_dodge_fx(atom/movable/proj)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.visible_message(span_warning("[xeno_owner] effortlessly dodges the [proj.name]!"), \
	span_xenodanger("We effortlessly dodge the [proj.name]![(evasion_stack_target - evasion_stacks) > 0 && evasion_stacks > 0 ? " We must dodge [evasion_stack_target - evasion_stacks] more projectile damage before [src]'s cooldown refreshes." : ""]"))
	xeno_owner.add_filter("runner_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/atom, remove_filter), "runner_evasion"), 0.5 SECONDS)
	xeno_owner.do_jitter_animation(4000)
	if(evasion_stacks >= RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD && cooldown_remaining()) //We have more evasion stacks than needed to refresh our cooldown, while being on cooldown.
		clear_cooldown()
		if(auto_evasion && xeno_owner.plasma_stored >= plasma_cost)
			action_activate()
	var/turf/current_turf = get_turf(xeno_owner) //location of after image SFX
	playsound(current_turf, pick('sound/effects/throw.ogg','sound/effects/alien_tail_swipe1.ogg', 'sound/effects/alien_tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/xenomorph/afterimage/after_image
	for(var/i=0 to 2) //number of after images
		after_image = new /obj/effect/temp_visual/xenomorph/afterimage(current_turf, owner) //Create the after image.
		after_image.pixel_x = pick(rand(xeno_owner.pixel_x * 3, xeno_owner.pixel_x * 1.5), rand(0, xeno_owner.pixel_x * -1)) //Variation on the X position


// ***************************************
// *********** Snatch
// ***************************************
/datum/action/xeno_action/activable/snatch
	name = "Snatch"
	action_icon_state = "snatch"
	desc = "Take an item equipped by your target in your mouth, and carry it away."
	plasma_cost = 75
	cooldown_timer = 60 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SNATCH,
	)
	target_flags = XABB_MOB_TARGET
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

/datum/action/xeno_action/activable/snatch/action_activate()
	if(!stolen_item)
		return ..()
	drop_item()

/datum/action/xeno_action/activable/snatch/can_use_ability(atom/A, silent, override_flags)
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

/datum/action/xeno_action/activable/snatch/use_ability(atom/A)
	succeed_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(owner, 0.5 SECONDS, FALSE, A, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = X.health))))
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
	add_cooldown()

///Signal handler to update the item overlay when the owner is changing dir
/datum/action/xeno_action/activable/snatch/proc/owner_turned(datum/source, old_dir, new_dir)
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
/datum/action/xeno_action/activable/snatch/proc/drop_item()
	if(!stolen_item)
		return
	owner.remove_movespeed_modifier(MOVESPEED_ID_SNATCH)
	stolen_item.forceMove(get_turf(owner))
	stolen_item = null
	owner.overlays -= stolen_appearance
	playsound(owner, 'sound/voice/alien_pounce2.ogg', 30, frequency = -1)
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)

