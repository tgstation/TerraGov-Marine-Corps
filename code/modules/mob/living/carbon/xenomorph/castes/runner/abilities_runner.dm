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
	cooldown_duration = 6
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
	if(!COOLDOWN_CHECK(src, savage_cooldown))
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
	if(COOLDOWN_CHECK(src, savage_cooldown))
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

