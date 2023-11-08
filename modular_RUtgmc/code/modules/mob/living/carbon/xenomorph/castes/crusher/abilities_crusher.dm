// ***************************************
// *********** Regenerate Skin
// ***************************************
/datum/action/xeno_action/regenerate_skin
	name = "Regenerate Armor"
	action_icon_state = "regenerate_skin"
	desc = "Regenerate your hard exoskeleton armor, removing all sunder."
	ability_name = "regenerate skin"
	use_state_flags = XACT_TARGET_SELF|XACT_IGNORE_SELECTED_ABILITY|XACT_KEYBIND_USE_ABILITY
	plasma_cost = 400
	cooldown_timer = 3 MINUTES
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REGENERATE_SKIN,
	)

/datum/action/xeno_action/regenerate_skin/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We feel we are ready to shred our armor and grow another."))
	return ..()

/datum/action/xeno_action/regenerate_skin/action_activate()
	var/mob/living/carbon/xenomorph/crusher/X = owner

	if(!can_use_action(TRUE))
		return fail_activate()

	if(X.on_fire)
		to_chat(X, span_xenowarning("We can't use that while on fire."))
		return fail_activate()

	X.emote("roar")
	X.visible_message(span_warning("The armor on \the [X] shreds and a new layer can be seen in it's place!"),
		span_notice("We shed our armor, showing the fresh new layer underneath!"))

	X.do_jitter_animation(1000)
	X.set_sunder(0)
	add_cooldown()
	return succeed_activate()

