// ***************************************
// *********** Runner's Pounce
// ***************************************
#define RUNNER_POUNCE_RANGE 6 // in tiles
#define RUNNER_SAVAGE_DAMAGE_MINIMUM 15
#define RUNNER_SAVAGE_COOLDOWN 30 SECONDS

/datum/action/ability/activable/xeno/pounce/runner
	desc = "Leap at your target, tackling and disarming them. Alternate use toggles Savage off or on."
	action_icon_state = "pounce_savage_on"
	action_icon = 'icons/Xeno/actions/runner.dmi'
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

/datum/action/ability/activable/xeno/pounce/runner/trigger_pounce_effect(mob/living/living_target)
	. = ..()
	if(!savage_activated)
		return
	if(!COOLDOWN_FINISHED(src, savage_cooldown))
		owner.balloon_alert(owner, "Savage on cooldown ([COOLDOWN_TIMELEFT(src, savage_cooldown) * 0.1]s)")
		return
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
	if(COOLDOWN_FINISHED(src, savage_cooldown))
		button.cut_overlay(visual_references[VREF_MUTABLE_SAVAGE_COOLDOWN])
		owner.balloon_alert(owner, "Savage ready")
		owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
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
	action_icon = 'icons/Xeno/actions/runner.dmi'
	desc = "Take evasive action, forcing non-friendly projectiles that would hit you to miss for a short duration so long as you keep moving. \
			Alternate use toggles Auto Evasion off or on. Click again while active to deactivate early. You cannot evade pointblank shots or attack while evading."
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
	owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)

/datum/action/ability/xeno_action/evasion/can_use_action(silent = FALSE, override_flags)
	. = ..()
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
	//Since both the button and the evasion extension call this proc directly, check if the cooldown timer exists
	//The evasion extension removes the cooldown before calling this proc again, so use that to differentiate if it was the player trying to cancel
	if(evade_active && cooldown_timer)
		if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_EVASION_ACTIVATION))
			return
		evasion_deactivate()
		return

	use_state_flags = ABILITY_IGNORE_COOLDOWN|ABILITY_IGNORE_PLASMA	//To allow the ability button to be clicked while on cooldown for deactivation purposes
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
	to_chat(owner, span_userdanger("We take evasive action, making us impossible to hit."))
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
	TIMER_COOLDOWN_START(src, COOLDOWN_EVASION_ACTIVATION, 0.3 SECONDS)

/datum/action/ability/xeno_action/evasion/ai_should_start_consider()
	return TRUE

/datum/action/ability/xeno_action/evasion/ai_should_use(atom/target)
	if(iscarbon(target))
		return FALSE
	var/hp_left_percent = xeno_owner.health / xeno_owner.maxHealth // minimum_health or retreating ai datum instead maybe?
	return (hp_left_percent < 0.5)

/datum/action/ability/xeno_action/evasion/process()
	hud_set_evasion(evasion_duration)
	if(evasion_duration <= 0)
		evasion_deactivate()
		return
	evasion_duration--

///Sets the evasion duration hud
/datum/action/ability/xeno_action/evasion/proc/hud_set_evasion(duration)
	var/image/holder = xeno_owner.hud_list[XENO_EVASION_HUD]
	if(!holder)
		return
	holder.overlays.Cut()
	holder.icon_state = ""
	if(xeno_owner.stat == DEAD || !duration)
		return
	holder.icon = 'icons/mob/hud/xeno.dmi'
	holder.icon_state = "evasion_duration[duration]"
	holder.pixel_x = 24
	holder.pixel_y = 24
	xeno_owner.hud_list[XENO_EVASION_HUD] = holder

/**
 * Called when the owner is hit by a flamethrower projectile.
 * Reduces evasion stacks based on the damage received.
*/
/datum/action/ability/xeno_action/evasion/proc/evasion_flamer_hit(datum/source, atom/movable/projectile/proj)
	SIGNAL_HANDLER
	if(!(proj.ammo.ammo_behavior_flags & AMMO_FLAME))
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
	use_state_flags = NONE	//To prevent the ability from being used while on cooldown now that it can no longer be deactivated
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
	hud_set_evasion(evasion_duration)

/// Determines whether or not a thrown projectile is dodged while the Evasion ability is active
/datum/action/ability/xeno_action/evasion/proc/evasion_throw_dodge(datum/source, atom/movable/proj)
	SIGNAL_HANDLER
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
/datum/action/ability/xeno_action/evasion/proc/evasion_dodge(datum/source, atom/movable/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(!evade_active) //If evasion is not active we don't dodge
		return FALSE
	if((xeno_owner.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return FALSE
	if(xeno_owner.issamexenohive(proj.firer)) //We automatically dodge allied projectiles at no cost, and no benefit to our evasion stacks
		return COMPONENT_PROJECTILE_DODGE
	if(proj.ammo.ammo_behavior_flags & AMMO_FLAME) //We can't dodge literal fire
		return FALSE
	if(proj.original_target == xeno_owner && proj.distance_travelled < 2) //Pointblank shot.
		return FALSE
	if(!xeno_owner.fire_stacks)
		evasion_stacks += proj.damage //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes, fire negates this
	evasion_dodge_fx(proj)
	return COMPONENT_PROJECTILE_DODGE

/// Handles dodge effects and visuals for the Evasion ability.
/datum/action/ability/xeno_action/evasion/proc/evasion_dodge_fx(atom/movable/proj)
	xeno_owner.visible_message(span_warning("[xeno_owner] effortlessly dodges the [proj.name]!"), \
	span_xenodanger("We effortlessly dodge the [proj.name]![(RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks) > 0 && evasion_stacks > 0 ? " We must dodge [RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks] more projectile damage before [src]'s cooldown refreshes." : ""]"))
	xeno_owner.add_filter("runner_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/datum, remove_filter), "runner_evasion"), 0.5 SECONDS)
	xeno_owner.do_jitter_animation(4000)
	if(evasion_stacks >= RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD && cooldown_remaining()) //We have more evasion stacks than needed to refresh our cooldown, while being on cooldown.
		clear_cooldown()
		if(auto_evasion && xeno_owner.plasma_stored >= ability_cost)
			action_activate()
	var/turf/current_turf = get_turf(xeno_owner) //location of after image SFX
	playsound(current_turf, pick('sound/effects/throw.ogg','sound/effects/alien/tail_swipe1.ogg', 'sound/effects/alien/tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/after_image/after_image
	for(var/i=0 to 2) //number of after images
		after_image = new /obj/effect/temp_visual/after_image(current_turf, owner) //Create the after image.
		after_image.pixel_x = pick(randfloat(xeno_owner.pixel_x * 3, xeno_owner.pixel_x * 1.5), rand(0, xeno_owner.pixel_x * -1)) //Variation on the X position


// ***************************************
// *********** Snatch
// ***************************************
/datum/action/ability/activable/xeno/snatch
	name = "Snatch"
	action_icon_state = "snatch"
	action_icon = 'icons/Xeno/actions/runner.dmi'
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
	if(!do_after(owner, 0.5 SECONDS, IGNORE_HELD_ITEM, A, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = xeno_owner.health))))
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
	playsound(owner, 'sound/voice/alien/pounce2.ogg', 30)
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
	GLOB.round_statistics.runner_items_stolen++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_items_stolen")
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.items_snatched++

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
	playsound(owner, 'sound/voice/alien/pounce2.ogg', 30, frequency = -1)
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)

/datum/action/ability/activable/xeno/corrosive_acid/melter
	desc = "Cover an object with acid to slowly melt it. Takes less time than usual."
	ability_cost = 25
	acid_type = /obj/effect/xenomorph/acid/weak
	acid_speed_multiplier = 0.75 // 50% faster

/datum/action/ability/activable/xeno/charge/acid_dash/melter
	ability_cost = 50
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_DASH_MELTER,
	)
	charge_range = 7
	do_acid_spray_act = FALSE

/datum/action/ability/activable/xeno/melter_shroud
	name = "Melter Shroud"
	action_icon_state = "acid_shroud"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Creates see-through acid smoke below yourself."
	ability_cost = 50
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	cooldown_duration = 32 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_SHROUD_MELTER,
	)

/datum/action/ability/activable/xeno/melter_shroud/use_ability(atom/A)
	var/datum/effect_system/smoke_spread/emitted_gas = new /datum/effect_system/smoke_spread/xeno/acid(xeno_owner)
	emitted_gas.set_up(2, get_turf(xeno_owner))
	emitted_gas.start()
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/charge/acid_dash/melter/mob_hit(datum/source, mob/living/living_target)
	. = ..()
	if(living_target.stat || isxeno(living_target) || !(iscarbon(living_target)))
		return
	var/mob/living/carbon/carbon_victim = living_target
	carbon_victim.apply_damage(20, BURN, null, ACID)

/datum/action/ability/activable/xeno/acidic_missile
	name = "Acidic Missile"
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	desc = "Slowly build up acid in preparation to launch yourself as an acidic missile. Can launch yourself early if desired. Will slow you down initially, but will ramp up speed at maximum acid of 5x5."
	ability_cost = 100
	cooldown_duration = 60 SECONDS
	use_state_flags = ABILITY_USE_BUSY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACIDIC_MISSILE,
	)
	/// The particles effects from activation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// The acid level of the ability. Affects radius and movement speed.
	var/acid_level = 0

/datum/action/ability/activable/xeno/acidic_missile/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(xeno_owner.plasma_stored < ability_cost)
		return FALSE
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		return

/datum/action/ability/activable/xeno/acidic_missile/use_ability(atom/A)
	if(!acid_level)
		if(length(xeno_owner.do_actions) && LAZYACCESS(xeno_owner.do_actions, xeno_owner))
			return
		particle_holder = new(owner, /particles/melter_steam)
		particle_holder.pixel_y = -8
		particle_holder.pixel_x = 10
		increase_acid_level(FALSE)
		return
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_complete))
	RegisterSignal(xeno_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_stagger))
	xeno_owner.xeno_flags |= XENO_LEAPING
	xeno_owner.throw_at(A, HUNTER_POUNCE_RANGE, XENO_POUNCE_SPEED, xeno_owner)

/// Completes the ability and triggers the acid explosion.
/datum/action/ability/activable/xeno/acidic_missile/proc/throw_complete(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(acid_explosion), TRUE, TRUE, FALSE, TRUE)

/// Completes the ability and triggers the acid explosion at a reduced acid level.
/datum/action/ability/activable/xeno/acidic_missile/proc/on_stagger(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	acid_level = max(0, acid_level - 1)
	INVOKE_ASYNC(src, PROC_REF(acid_explosion), TRUE, TRUE, FALSE, TRUE)

/// Increases acid level and handles its associated effects.
/datum/action/ability/activable/xeno/acidic_missile/proc/increase_acid_level(require_acid_level = TRUE)
	switch(acid_level)
		if(0)
			xeno_owner.add_atom_colour("#bcff70", FIXED_COLOR_PRIORITY)
			xeno_owner.do_jitter_animation(100)
			xeno_owner.add_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE, TRUE, 0, NONE, TRUE, 1.5)
		if(1)
			xeno_owner.do_jitter_animation(500)
			xeno_owner.add_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE, TRUE, 0, NONE, TRUE, 1)
		if(2)
			xeno_owner.do_jitter_animation(1000)
			xeno_owner.add_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE, TRUE, 0, NONE, TRUE, 0.5)
		if(3)
			xeno_owner.do_jitter_animation(4000)
			xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE)
			xeno_owner.emote("roar2")
			if(do_after(owner, 2.5 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(do_after_checks))))
				acid_level--
			if(!(xeno_owner.xeno_flags & XENO_LEAPING))
				acid_explosion()
			return
	if(do_after(xeno_owner, 1.6 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), require_acid_level)))
		acid_level++
		increase_acid_level()
		return
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		return
	acid_level = max(0, acid_level - 1)
	acid_explosion()

/// Additional checks for do_after. They must have acid level, enough plasma, and must not be leaping.
/datum/action/ability/activable/xeno/acidic_missile/proc/do_after_checks(require_acid_level = TRUE)
	if(require_acid_level && !acid_level)
		return FALSE
	if(xeno_owner.plasma_stored < ability_cost)
		return FALSE
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		return FALSE
	return TRUE

/// Resets everything related to the ability and ends/completes the ability.
/datum/action/ability/activable/xeno/acidic_missile/proc/end_ability()
	QDEL_NULL(particle_holder)
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_POST_THROW, COMSIG_LIVING_STATUS_STAGGER))
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE)
	xeno_owner.remove_atom_colour(FIXED_COLOR_PRIORITY, "#bcff70")
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		xeno_owner.xeno_flags &= ~XENO_LEAPING
	acid_level = 0
	add_cooldown()
	succeed_activate()

/// Explodes with a radius based on acid level.
/datum/action/ability/activable/xeno/acidic_missile/proc/acid_explosion(end_ability_afterward = TRUE, requires_plasma = TRUE, disallow_leaping = TRUE, do_emote = FALSE)
	if(!acid_level || (requires_plasma && xeno_owner.plasma_stored < ability_cost) || (disallow_leaping && (xeno_owner.xeno_flags & XENO_LEAPING)))
		if(end_ability_afterward)
			end_ability()
		return
	for(var/turf/acid_tile AS in RANGE_TURFS(acid_level - 1, xeno_owner.loc))
		if(!line_of_sight(xeno_owner.loc, acid_tile))
			continue
		new /obj/effect/temp_visual/acid_splatter(acid_tile)
		if(!locate(/obj/effect/xenomorph/spray) in acid_tile.contents)
			new /obj/effect/xenomorph/spray(acid_tile, 3 SECONDS, 16)
			for (var/atom/movable/atom_in_acid AS in acid_tile)
				atom_in_acid.acid_spray_act(xeno_owner)
	if(do_emote)
		xeno_owner.emote("roar4")
	if(end_ability_afterward)
		end_ability()

/particles/melter_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	width = 100
	height = 300
	count = 50
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 3 SECONDS
	velocity = list(0, 0.3, 0)
	position = list(5, 16, 0)
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, 0.95)
	grow = 0.1
