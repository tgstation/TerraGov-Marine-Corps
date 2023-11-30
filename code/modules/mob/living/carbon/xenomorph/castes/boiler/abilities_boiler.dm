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
		BOILER_GLOB_NEURO = image('icons/Xeno/actions.dmi', icon_state = BOILER_GLOB_NEURO),
		BOILER_GLOB_ACID = image('icons/Xeno/actions.dmi', icon_state = BOILER_GLOB_ACID),
		BOILER_GLOB_NEURO_LANCE = image('icons/Xeno/actions.dmi', icon_state = BOILER_GLOB_NEURO_LANCE),
		BOILER_GLOB_ACID_LANCE = image('icons/Xeno/actions.dmi', icon_state = BOILER_GLOB_ACID_LANCE),
		))


// ***************************************
// *********** Long range sight
// ***************************************

/datum/action/ability/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight"
	action_icon_state = "toggle_long_range"
	desc = "Activates your weapon sight in the direction you are facing. Must remain stationary to use."
	ability_cost = 20
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LONG_RANGE_SIGHT,
	)
	use_state_flags = ABILITY_USE_ROOTED

/datum/action/ability/xeno_action/toggle_long_range/action_activate()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.is_zoomed)
		X.zoom_out()
		X.visible_message(span_notice("[X] stops looking off into the distance."), \
		span_notice("We stop looking off into the distance."), null, 5)
	else
		X.visible_message(span_notice("[X] starts looking off into the distance."), \
			span_notice("We start focusing your sight to look off into the distance."), null, 5)
		if(!do_after(X, 1 SECONDS, IGNORE_HELD_ITEM, null, BUSY_ICON_GENERIC) || X.is_zoomed)
			return
		X.zoom_in(11)
		..()

// ***************************************
// *********** Gas type toggle
// ***************************************

/datum/action/ability/xeno_action/toggle_bomb
	name = "Toggle Bombard Type"
	action_icon_state = "toggle_bomb0"
	desc = "Switches Boiler Bombard type between available glob types."
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING|ABILITY_USE_ROOTED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_BOMB,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TOGGLE_BOMB_RADIAL,
	)

/datum/action/ability/xeno_action/toggle_bomb/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(length(X.xeno_caste.spit_types) > 2)
		return	//They might just be skipping past a invalid type
	if((X.corrosive_ammo + X.neuro_ammo) >= X.xeno_caste.max_ammo)
		if((X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive && X.neuro_ammo==0) || (X.ammo.type == /datum/ammo/xeno/boiler_gas && X.corrosive_ammo==0))
			if (!silent)
				to_chat(X, span_warning("We won't be able to carry this kind of globule"))
			return FALSE

/datum/action/ability/xeno_action/toggle_bomb/action_activate()
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

/datum/action/ability/xeno_action/toggle_bomb/alternate_action_activate()
	. = COMSIG_KB_ACTIVATED
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(!can_use_action())
		return
	if(length(X.xeno_caste.spit_types) <= 2)	//If we only have two or less glob types, we just use default select anyways.
		action_activate()
		return
	INVOKE_ASYNC(src, PROC_REF(select_glob_radial))

/**
 * Opens a radial menu to select a glob in and sets current ammo to the selected result.
 * * On selecting nothing, merely keeps current ammo.
 * * Dynamically adjusts depending on which globs a boiler has access to, provided the global lists are maintained, though this fact isn't too relevant unless someone adds more.
**/
/datum/action/ability/xeno_action/toggle_bomb/proc/select_glob_radial()
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

/datum/action/ability/xeno_action/toggle_bomb/update_button_icon()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	var/datum/ammo/xeno/boiler_gas/boiler_glob = X.ammo	//Should be safe as this always selects a ammo.
	action_icon_state = boiler_glob.icon_key
	return ..()

// ***************************************
// *********** Gas cloud bomb maker
// ***************************************

/datum/action/ability/xeno_action/create_boiler_bomb
	name = "Create bomb"
	action_icon_state = "toggle_bomb0" //to be changed
	action_icon = 'icons/xeno/actions_boiler_glob.dmi'
	desc = "Creates a Boiler Bombard of the type currently selected."
	ability_cost = 200
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING|ABILITY_USE_ROOTED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE_BOMB,
	)

/datum/action/ability/xeno_action/create_boiler_bomb/New(Target)
	. = ..()
	desc = "Creates a Boiler Bombard of the type currently selected. Reduces bombard cooldown by [BOILER_BOMBARD_COOLDOWN_REDUCTION] seconds for each stored. Begins to emit light when surpassing [BOILER_LUMINOSITY_THRESHOLD] globs stored."

/datum/action/ability/xeno_action/create_boiler_bomb/action_activate()
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

/datum/action/ability/xeno_action/create_boiler_bomb/update_button_icon()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	action_icon_state = "bomb_count_[X.corrosive_ammo][X.neuro_ammo]"
	return ..()

// ***************************************
// *********** Gas cloud bombs
// ***************************************
/datum/action/ability/activable/xeno/bombard
	name = "Bombard"
	action_icon_state = "bombard"
	desc = "Launch a glob of neurotoxin or acid. Must be rooted to use."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BOMBARD,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_ROOT,
	)
	target_flags = ABILITY_TURF_TARGET
	use_state_flags = ABILITY_USE_ROOTED

/datum/action/ability/activable/xeno/bombard/get_cooldown()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	return X.xeno_caste.bomb_delay - ((X.neuro_ammo + X.corrosive_ammo) * (BOILER_BOMBARD_COOLDOWN_REDUCTION SECONDS))

/datum/action/ability/activable/xeno/bombard/on_cooldown_finish()
	to_chat(owner, span_notice("We feel your toxin glands swell. We are able to bombard an area again."))
	return ..()

/datum/action/ability/activable/xeno/bombard/on_selection()
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED, TYPE_PROC_REF(/datum/action/ability/activable/xeno/bombard, on_ranged_attack))

/datum/action/ability/activable/xeno/bombard/on_deselection()
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_RANGED)

/// Signal proc for clicking at a distance
/datum/action/ability/activable/xeno/bombard/proc/on_ranged_attack(mob/living/carbon/xenomorph/X, atom/A, params)
	SIGNAL_HANDLER
	if(can_use_ability(A, TRUE))
		INVOKE_ASYNC(src, PROC_REF(use_ability), A)

/datum/action/ability/activable/xeno/bombard/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(A)
	var/turf/S = get_turf(owner)
	var/mob/living/carbon/xenomorph/boiler/boiler_owner = owner

	if(!HAS_TRAIT_FROM(owner, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		if(!silent)
			to_chat(owner, span_warning("We need to be rooted to fire!"))
		return FALSE

	if(istype(boiler_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		if(boiler_owner.corrosive_ammo <= 0)
			boiler_owner.balloon_alert(boiler_owner, "No corrosive globules.")
			return FALSE
	else
		if(boiler_owner.neuro_ammo <= 0)
			boiler_owner.balloon_alert(boiler_owner, "No neurotoxin globules.")
			return FALSE

	if(!HAS_TRAIT_FROM(boiler_owner, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		boiler_owner.balloon_alert(boiler_owner, "We need to be rooted to the ground to fire!")
		return FALSE

	if(!isturf(T) || T.z != S.z)
		if(!silent)
			boiler_owner.balloon_alert(boiler_owner, "Invalid target.")
		return FALSE

	if(get_dist(T, S) <= 5) //Magic number
		if(!silent)
			boiler_owner.balloon_alert(boiler_owner, "Too close!")
		return FALSE

/datum/action/ability/activable/xeno/bombard/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/boiler/boiler_owner = owner
	var/turf/target = get_turf(A)

	if(!istype(target))
		return

	to_chat(boiler_owner, span_xenonotice("We begin building up pressure."))

	if(!do_after(boiler_owner, 2 SECONDS, IGNORE_HELD_ITEM, target, BUSY_ICON_DANGER))
		to_chat(boiler_owner, span_warning("We decide not to launch."))
		return fail_activate()

	if(!can_use_ability(target, FALSE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	boiler_owner.visible_message(span_xenowarning("\The [boiler_owner] launches a huge glob of acid hurling into the distance!"), \
	span_xenowarning("We launch a huge glob of acid hurling into the distance!"), null, 5)

	var/obj/projectile/P = new /obj/projectile(boiler_owner.loc)
	P.generate_bullet(boiler_owner.ammo)
	P.fire_at(target, boiler_owner, null, boiler_owner.ammo.max_range, boiler_owner.ammo.shell_speed)
	playsound(boiler_owner, 'sound/effects/blobattack.ogg', 25, 1)
	if(istype(boiler_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		GLOB.round_statistics.boiler_acid_smokes++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_acid_smokes")
		boiler_owner.corrosive_ammo--
	else
		GLOB.round_statistics.boiler_neuro_smokes++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_neuro_smokes")
		boiler_owner.neuro_ammo--
	owner.record_war_crime()

	boiler_owner.update_boiler_glow()
	update_button_icon()
	add_cooldown()


/datum/action/ability/activable/xeno/bombard/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(root))
	return COMSIG_KB_ACTIVATED

/// The alternative action of bombard, rooting. It begins the rooting/unrooting process.
/datum/action/ability/activable/xeno/bombard/proc/root()
	if(HAS_TRAIT_FROM(owner, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		owner.balloon_alert_to_viewers("Rooting out of place...")
		if(!do_after(owner, 3 SECONDS, IGNORE_HELD_ITEM, null, BUSY_ICON_HOSTILE))
			owner.balloon_alert(owner, "Interrupted!")
			return
		owner.balloon_alert(owner, "Unrooted!")
		set_rooted(FALSE)
		return

	if(HAS_TRAIT_FROM(owner, TRAIT_FLOORED, RESTING_TRAIT))
		owner.balloon_alert(owner, "Cannot while lying down!")
		return

	owner.balloon_alert_to_viewers("Rooting into place...")
	if(!do_after(owner, 3 SECONDS, IGNORE_HELD_ITEM, null, BUSY_ICON_HOSTILE))
		owner.balloon_alert(owner, "Interrupted!")
		return

	owner.balloon_alert_to_viewers("Rooted into place!")
	set_rooted(TRUE)

/// Proc that actually does the rooting, makes us immobile and anchors us in place. Similar to defender's fortify.
/datum/action/ability/activable/xeno/bombard/proc/set_rooted(on)
	var/mob/living/carbon/xenomorph/boiler/boiler_owner = owner
	if(on)
		ADD_TRAIT(boiler_owner, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT)
		if(boiler_owner.client)
			boiler_owner.client.mouse_pointer_icon = 'icons/mecha/mecha_mouse.dmi'
	else
		REMOVE_TRAIT(boiler_owner, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT)
		if(boiler_owner.client)
			boiler_owner.client.mouse_pointer_icon = initial(boiler_owner.client.mouse_pointer_icon)

	boiler_owner.anchored = on


// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/line/boiler
	cooldown_duration = 9 SECONDS
	use_state_flags = ABILITY_USE_ROOTED
