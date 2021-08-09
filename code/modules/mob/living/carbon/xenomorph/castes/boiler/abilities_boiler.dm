// ***************************************
// *********** Long range sight
// ***************************************

/datum/action/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight"
	action_icon_state = "toggle_long_range"
	mechanics_text = "Activates your weapon sight in the direction you are facing. Must remain stationary to use."
	plasma_cost = 20
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT

/datum/action/xeno_action/toggle_long_range/action_activate()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.is_zoomed)
		X.zoom_out()
		X.visible_message(span_notice("[X] stops looking off into the distance."), \
		span_notice("We stop looking off into the distance."), null, 5)
	else
		X.visible_message(span_notice("[X] starts looking off into the distance."), \
			span_notice("We start focusing your sight to look off into the distance."), null, 5)
		if(!do_after(X, 1 SECONDS, FALSE, null, BUSY_ICON_GENERIC) || X.is_zoomed)
			return
		X.zoom_in(11)
		..()

// ***************************************
// *********** Gas type toggle
// ***************************************

/datum/action/xeno_action/toggle_bomb
	name = "Toggle Bombard Type"
	action_icon_state = "toggle_bomb0"
	mechanics_text = "Switches Boiler Bombard type between Corrosive Acid and Neurotoxin."
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB

/datum/action/xeno_action/toggle_bomb/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if((X.corrosive_ammo + X.neuro_ammo) >= X.xeno_caste.max_ammo)
		if((X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive && X.neuro_ammo==0) || (X.ammo.type == /datum/ammo/xeno/boiler_gas && X.corrosive_ammo==0))
			if (!silent)
				to_chat(X, span_warning("We won't be able to carry this kind of globule"))
			return FALSE

/datum/action/xeno_action/toggle_bomb/action_activate()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas)
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas/corrosive]
		to_chat(X, span_notice("We will now fire corrosive acid. This is lethal!"))
	else
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas]
		to_chat(X, span_notice("We will now fire neurotoxic gas. This is nonlethal."))
	update_button_icon()

/datum/action/xeno_action/toggle_bomb/update_button_icon()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	button.overlays.Cut()
	if(X.ammo?.type == /datum/ammo/xeno/boiler_gas/corrosive)
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb1")
	else
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb0")
	return ..()

// ***************************************
// *********** Gas cloud bomb maker
// ***************************************

/datum/action/xeno_action/create_boiler_bomb
	name = "Create bomb"
	action_icon_state = "toggle_bomb0" //to be changed
	mechanics_text = "Creates a Boiler Bombard of the type currently selected."
	plasma_cost = 200
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING
	keybind_signal = COMSIG_XENOABILITY_CREATE_BOMB

/datum/action/xeno_action/create_boiler_bomb/action_activate()
	var/mob/living/carbon/xenomorph/boiler/X = owner

	if(X.is_zoomed)
		to_chat(X, span_notice("We can not prepare globules as we are now. We must stop concentrating into the distance!"))
		return

	var/current_ammo = X.corrosive_ammo + X.neuro_ammo
	if(current_ammo >= X.xeno_caste.max_ammo)
		to_chat(X, span_notice("We can carry no more globules."))
		return

	succeed_activate()
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive)
		X.corrosive_ammo++
		to_chat(X, span_notice("We prepare a corrosive acid globule."))
	else
		X.neuro_ammo++
		to_chat(X, span_notice("We prepare a neurotoxic gas globule."))
	X.update_boiler_glow()
	update_button_icon()

/datum/action/xeno_action/create_boiler_bomb/update_button_icon()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	button.overlays.Cut()
	//the bit where the ammo counter sprite updates.
	button.overlays += image('icons/xeno/actions_boiler_glob.dmi', button, "bomb_count_[X.corrosive_ammo][X.neuro_ammo]")
	return ..()

// ***************************************
// *********** Gas cloud bombs
// ***************************************
/datum/action/xeno_action/activable/bombard
	name = "Bombard"
	action_icon_state = "bombard"
	mechanics_text = "Launch a glob of neurotoxin or acid. Must remain stationary for a few seconds to use."
	ability_name = "bombard"
	keybind_signal = COMSIG_XENOABILITY_BOMBARD
	target_flags = XABB_TURF_TARGET

/datum/action/xeno_action/activable/bombard/get_cooldown()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	return X.xeno_caste.bomb_delay - ((X.neuro_ammo + X.corrosive_ammo) * X.xeno_caste.ammo_multiplier)

/datum/action/xeno_action/activable/bombard/on_cooldown_finish()
	to_chat(owner, span_notice("We feel your toxin glands swell. We are able to bombard an area again."))
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.selected_ability == src)
		X.set_bombard_pointer()
	return ..()

/datum/action/xeno_action/activable/bombard/on_activation()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	var/current_ammo = X.corrosive_ammo + X.neuro_ammo
	if(current_ammo <= 0)
		to_chat(X, span_notice("We have nothing prepared to fire."))
		return FALSE

	X.visible_message(span_notice("\The [X] begins digging their claws into the ground."), \
	span_notice("We begin digging ourselves into place."), null, 5)
	if(!do_after(X, 3 SECONDS, FALSE, null, BUSY_ICON_HOSTILE))
		on_deactivation()
		X.selected_ability = null
		X.update_action_button_icons()
		X.reset_bombard_pointer()
		return FALSE

	X.visible_message(span_notice("\The [X] digs itself into the ground!"), \
		span_notice("We dig ourselves into place! If we move, we must wait again to fire."), null, 5)
	X.set_bombard_pointer()
	RegisterSignal(X, COMSIG_MOB_ATTACK_RANGED, /datum/action/xeno_action/activable/bombard/proc.on_ranged_attack)


/datum/action/xeno_action/activable/bombard/on_deactivation()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.selected_ability == src)
		X.reset_bombard_pointer()
		to_chat(X, span_notice("We relax our stance."))
	UnregisterSignal(X, COMSIG_MOB_ATTACK_RANGED)


/datum/action/xeno_action/activable/bombard/proc/on_ranged_attack(mob/living/carbon/xenomorph/X, atom/A, params)
	SIGNAL_HANDLER
	if(can_use_ability(A))
		INVOKE_ASYNC(src, .proc/use_ability, A)


/mob/living/carbon/xenomorph/boiler/Moved(atom/OldLoc,Dir)
	. = ..()
	if(selected_ability?.type == /datum/action/xeno_action/activable/bombard)
		var/datum/action/xeno_action/activable/bomb = actions_by_path[/datum/action/xeno_action/activable/bombard]
		bomb.on_deactivation()
		selected_ability.button.icon_state = "template"
		selected_ability = null
		update_action_button_icons()

/mob/living/carbon/xenomorph/boiler/proc/set_bombard_pointer()
	if(client)
		client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")

/mob/living/carbon/xenomorph/boiler/proc/reset_bombard_pointer()
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)

/datum/action/xeno_action/activable/bombard/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(A)
	var/turf/S = get_turf(owner)
	if(!isturf(T) || T.z != S.z)
		if(!silent)
			to_chat(owner, span_warning("This is not a valid target."))
		return FALSE
	if(get_dist(T, S) <= 5) //Magic number
		if(!silent)
			to_chat(owner, span_warning("We are too close! We must be at least 7 meters from the target due to the trajectory arc."))
		return FALSE

/datum/action/xeno_action/activable/bombard/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/boiler/X = owner
	var/turf/target = get_turf(A)

	if(!istype(target))
		return

	if(X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive)
		if(X.corrosive_ammo <= 0)
			to_chat(X, span_warning("We have no corrosive globules available."))
			return
	else
		if(X.neuro_ammo <= 0)
			to_chat(X, span_warning("We have no neurotoxin globules available."))
			return

	to_chat(X, span_xenonotice("We begin building up pressure."))

	if(!do_after(X, 2 SECONDS, FALSE, target, BUSY_ICON_DANGER))
		to_chat(X, span_warning("We decide not to launch."))
		return fail_activate()

	if(!can_use_ability(target, FALSE, XACT_IGNORE_PLASMA))
		return fail_activate()

	X.visible_message(span_xenowarning("\The [X] launches a huge glob of acid hurling into the distance!"), \
	span_xenowarning("We launch a huge glob of acid hurling into the distance!"), null, 5)

	var/obj/projectile/P = new /obj/projectile(X.loc)
	P.generate_bullet(X.ammo)
	P.fire_at(target, X, null, X.ammo.max_range, X.ammo.shell_speed)
	playsound(X, 'sound/effects/blobattack.ogg', 25, 1)
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive)
		GLOB.round_statistics.boiler_acid_smokes++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_acid_smokes")
		X.corrosive_ammo--
	else
		GLOB.round_statistics.boiler_neuro_smokes++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_neuro_smokes")
		X.neuro_ammo--

	X.update_boiler_glow()
	update_button_icon()
	add_cooldown()
	X.reset_bombard_pointer()

// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/xeno_action/activable/spray_acid/line/boiler
	cooldown_timer = 9 SECONDS
