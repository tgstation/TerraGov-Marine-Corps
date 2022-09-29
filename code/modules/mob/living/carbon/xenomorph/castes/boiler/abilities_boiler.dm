//Defines for boiler globs. Their icon states, specifically. Also used to reference their typepaths and for the radials.
#define BOILER_GLOB_NEURO "neuro_glob"
#define BOILER_GLOB_ACID "acid_glob"
#define BOILER_GLOB_NEURO_LANCE	"neuro_lance_glob"
#define BOILER_GLOB_ACID_LANCE	"acid_lance_glob"

///List of globs, keyed by icon state. Used for radial selection.
GLOBAL_LIST_INIT(boiler_glob_list, list(
		BOILER_GLOB_NEURO = /datum/ammo/xeno/boiler_gas,
		BOILER_GLOB_ACID = /datum/ammo/xeno/boiler_gas/corrosive,
		BOILER_GLOB_NEURO_LANCE = /datum/ammo/xeno/boiler_gas/lance,
		BOILER_GLOB_ACID_LANCE = /datum/ammo/xeno/boiler_gas/corrosive/lance,
		))

///List of glob action button images, used for radial selection.
GLOBAL_LIST_INIT(boiler_glob_image_list, list(
		BOILER_GLOB_NEURO = image('icons/mob/actions.dmi', icon_state = BOILER_GLOB_NEURO),
		BOILER_GLOB_ACID = image('icons/mob/actions.dmi', icon_state = BOILER_GLOB_ACID),
		BOILER_GLOB_NEURO_LANCE = image('icons/mob/actions.dmi', icon_state = BOILER_GLOB_NEURO_LANCE),
		BOILER_GLOB_ACID_LANCE = image('icons/mob/actions.dmi', icon_state = BOILER_GLOB_ACID_LANCE),
		))


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
	mechanics_text = "Switches Boiler Bombard type between available glob types."
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB
	alternate_keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB_RADIAL

/datum/action/xeno_action/toggle_bomb/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(length(X.xeno_caste.spit_types) > 2)
		return	//They might just be skipping past a invalid type
	if((X.corrosive_ammo + X.neuro_ammo) >= X.xeno_caste.max_ammo)
		if((X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive && X.neuro_ammo==0) || (X.ammo.type == /datum/ammo/xeno/boiler_gas && X.corrosive_ammo==0))
			if (!silent)
				to_chat(X, span_warning("We won't be able to carry this kind of globule"))
			return FALSE

/datum/action/xeno_action/toggle_bomb/action_activate()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	var/list/spit_types = X.xeno_caste.spit_types
	var/found_pos = spit_types.Find(X.ammo?.type)
	if(!found_pos)
		X.ammo = GLOB.ammo_list[spit_types[1]]
	else
		X.ammo = GLOB.ammo_list[spit_types[(found_pos%length(spit_types))+1]]	//Loop around if we would exceed the length
	var/datum/ammo/xeno/boiler_gas/boiler_glob = X.ammo
	to_chat(X, span_notice(boiler_glob.select_text))
	update_button_icon()

/datum/action/xeno_action/toggle_bomb/alternate_action_activate()
	. = COMSIG_KB_ACTIVATED
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(!can_use_action())
		return
	if(length(X.xeno_caste.spit_types) <= 2)	//If we only have two or less glob types, we just use default select anyways.
		action_activate()
		return
	INVOKE_ASYNC(src, .proc/select_glob_radial)

/**
 * Opens a radial menu to select a glob in and sets current ammo to the selected result.
 * * On selecting nothing, merely keeps current ammo.
 * * Dynamically adjusts depending on which globs a boiler has access to, provided the global lists are maintained, though this fact isn't too relevant unless someone adds more.
**/
/datum/action/xeno_action/toggle_bomb/proc/select_glob_radial()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	var/list/available_globs = list()
	for(var/datum/ammo/xeno/boiler_gas/glob_type AS in X.xeno_caste.spit_types)
		var/glob_image = GLOB.boiler_glob_image_list[initial(glob_type.icon_key)]
		if(!glob_image)
			continue
		available_globs[initial(glob_type.icon_key)] = glob_image

	var/glob_choice = show_radial_menu(owner, owner, available_globs, radius = 48)
	if(!glob_choice)
		return
	var/referenced_path = GLOB.boiler_glob_list[glob_choice]
	X.ammo = GLOB.ammo_list[referenced_path]
	var/datum/ammo/xeno/boiler_gas/boiler_glob = X.ammo
	to_chat(X, span_notice(boiler_glob.select_text))
	update_button_icon()

/datum/action/xeno_action/toggle_bomb/update_button_icon()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	var/datum/ammo/xeno/boiler_gas/boiler_glob = X.ammo	//Should be safe as this always selects a ammo.
	action_icon_state = boiler_glob.icon_key
	return ..()

// ***************************************
// *********** Gas cloud bomb maker
// ***************************************

/datum/action/xeno_action/create_boiler_bomb
	name = "Create bomb"
	action_icon_state = "toggle_bomb0" //to be changed
	action_icon = 'icons/xeno/actions_boiler_glob.dmi'
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
	if(istype(X.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		X.corrosive_ammo++
		to_chat(X, span_notice("We prepare a corrosive acid globule."))
	else
		X.neuro_ammo++
		to_chat(X, span_notice("We prepare a neurotoxic gas globule."))
	X.update_boiler_glow()
	update_button_icon()

/datum/action/xeno_action/create_boiler_bomb/update_button_icon()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	action_icon_state = "bomb_count_[X.corrosive_ammo][X.neuro_ammo]"
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
		client.mouse_pointer_icon = 'icons/mecha/mecha_mouse.dmi'

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

	if(istype(X.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
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
	if(istype(X.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
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
