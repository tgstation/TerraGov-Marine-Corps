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
	BOILER_GLOB_NEURO = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_NEURO),
	BOILER_GLOB_ACID = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_ACID),
	BOILER_GLOB_NEURO_LANCE = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_NEURO_LANCE),
	BOILER_GLOB_ACID_LANCE = image('icons/Xeno/actions/boiler.dmi', icon_state = BOILER_GLOB_ACID_LANCE),
))

// ***************************************
// *********** Long range sight
// ***************************************

/datum/action/ability/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight"
	action_icon_state = "toggle_long_range"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Extend your sight off into the distance. Must remain stationary to use."
	ability_cost = 20
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LONG_RANGE_SIGHT,
	)
	use_state_flags = ABILITY_USE_LYING
	/// The offset in a direction for zoom_in
	var/tile_offset = 7
	/// The size of the zoom for zoom_in
	var/view_size = 4

/datum/action/ability/xeno_action/toggle_long_range/bull
	tile_offset = 11
	view_size = 12

/datum/action/ability/xeno_action/toggle_long_range/action_activate()
	if(xeno_owner.xeno_flags & XENO_ZOOMED)
		xeno_owner.zoom_out()
		xeno_owner.visible_message(span_notice("[xeno_owner] stops looking off into the distance."), \
		span_notice("We stop looking off into the distance."), null, 5)
	else
		xeno_owner.visible_message(span_notice("[xeno_owner] starts looking off into the distance."), \
			span_notice("We start focusing your sight to look off into the distance."), null, 5)
		if(!do_after(xeno_owner, 1 SECONDS, IGNORE_HELD_ITEM, null, BUSY_ICON_GENERIC) || (xeno_owner.xeno_flags & XENO_ZOOMED))
			return
		xeno_owner.zoom_in(tile_offset, view_size)
		..()

// ***************************************
// *********** Gas type toggle
// ***************************************

/datum/action/ability/xeno_action/toggle_bomb
	name = "Toggle Bombard Type"
	action_icon_state = "acid_globe"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Switches Boiler Bombard type between available glob types."
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_BOMB,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TOGGLE_BOMB_RADIAL,
	)

/datum/action/ability/xeno_action/toggle_bomb/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(length(xeno_owner.xeno_caste.spit_types) > 2)
		return	//They might just be skipping past a invalid type
	if((xeno_owner.corrosive_ammo + xeno_owner.neuro_ammo) >= xeno_owner.xeno_caste.max_ammo)
		if((xeno_owner.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive && xeno_owner.neuro_ammo==0) || (xeno_owner.ammo.type == /datum/ammo/xeno/boiler_gas && xeno_owner.corrosive_ammo==0))
			if (!silent)
				to_chat(xeno_owner, span_warning("We won't be able to carry this kind of globule"))
			return FALSE

/datum/action/ability/xeno_action/toggle_bomb/action_activate()
	var/list/spit_types = xeno_owner.xeno_caste.spit_types
	var/found_pos = spit_types.Find(xeno_owner.ammo?.type)
	if(!found_pos)
		xeno_owner.ammo = GLOB.ammo_list[spit_types[1]]
	else
		xeno_owner.ammo = GLOB.ammo_list[spit_types[(found_pos%length(spit_types))+1]]	//Loop around if we would exceed the length
	var/datum/ammo/xeno/boiler_gas/boiler_glob = xeno_owner.ammo
	to_chat(xeno_owner, span_notice(boiler_glob.select_text))
	update_button_icon()

/datum/action/ability/xeno_action/toggle_bomb/alternate_action_activate()
	. = COMSIG_KB_ACTIVATED
	if(!can_use_action())
		return
	if(length(xeno_owner.xeno_caste.spit_types) <= 2)	//If we only have two or less glob types, we just use default select anyways.
		action_activate()
		return
	INVOKE_ASYNC(src, PROC_REF(select_glob_radial))

/**
 * Opens a radial menu to select a glob in and sets current ammo to the selected result.
 * * On selecting nothing, merely keeps current ammo.
 * * Dynamically adjusts depending on which globs a boiler has access to, provided the global lists are maintained, though this fact isn't too relevant unless someone adds more.
**/
/datum/action/ability/xeno_action/toggle_bomb/proc/select_glob_radial()
	var/list/available_globs = list()
	for(var/datum/ammo/xeno/boiler_gas/glob_type AS in xeno_owner.xeno_caste.spit_types)
		var/glob_image = GLOB.boiler_glob_image_list[initial(glob_type.icon_key)]
		if(!glob_image)
			continue
		available_globs[initial(glob_type.icon_key)] = glob_image

	var/glob_choice = show_radial_menu(owner, owner, available_globs, radius = 48)
	if(!glob_choice)
		return
	var/referenced_path = GLOB.boiler_glob_list[glob_choice]
	xeno_owner.ammo = GLOB.ammo_list[referenced_path]
	var/datum/ammo/xeno/boiler_gas/boiler_glob = xeno_owner.ammo
	to_chat(xeno_owner, span_notice(boiler_glob.select_text))
	update_button_icon()

/datum/action/ability/xeno_action/toggle_bomb/update_button_icon()
	var/datum/ammo/xeno/boiler_gas/boiler_glob = xeno_owner.ammo	//Should be safe as this always selects a ammo.
	action_icon_state = boiler_glob.icon_key
	return ..()

// ***************************************
// *********** Gas cloud bomb maker
// ***************************************

/datum/action/ability/xeno_action/create_boiler_bomb
	name = "Create bomb"
	action_icon_state = "create_bomb"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Creates a Boiler Bombard of the type currently selected."
	ability_cost = 200
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE_BOMB,
	)
/datum/action/ability/xeno_action/create_boiler_bomb/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/neuroglob_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER] = neuroglob_maptext
	neuroglob_maptext.pixel_x = 25
	neuroglob_maptext.pixel_y = -4
	neuroglob_maptext.maptext = MAPTEXT("<font color=yellow>[xeno_owner.neuro_ammo]")
	var/mutable_appearance/corrosiveglob_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER] = corrosiveglob_maptext
	corrosiveglob_maptext.pixel_x = 25
	corrosiveglob_maptext.pixel_y = 8
	corrosiveglob_maptext.maptext = MAPTEXT("<font color=green>[xeno_owner.corrosive_ammo]")

/datum/action/ability/xeno_action/create_boiler_bomb/New(Target)
	. = ..()
	desc = "Creates a Boiler Bombard of the type currently selected. Reduces bombard cooldown by [BOILER_BOMBARD_COOLDOWN_REDUCTION] seconds for each stored. Begins to emit light when surpassing [BOILER_LUMINOSITY_THRESHOLD] globs stored."

/datum/action/ability/xeno_action/create_boiler_bomb/action_activate()
	if(xeno_owner.xeno_flags & XENO_ZOOMED)
		xeno_owner.balloon_alert(xeno_owner,"Can't while zoomed in!")
		return

	var/current_ammo = xeno_owner.corrosive_ammo + xeno_owner.neuro_ammo
	if(current_ammo >= xeno_owner.xeno_caste.max_ammo)
		xeno_owner.balloon_alert(xeno_owner,"Globule storage full!")
		return

	succeed_activate()
	if(istype(xeno_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		xeno_owner.corrosive_ammo++
		xeno_owner.balloon_alert(xeno_owner,"Acid globule prepared")
	else
		xeno_owner.neuro_ammo++
		xeno_owner.balloon_alert(xeno_owner,"Neuro globule prepared")
	xeno_owner.update_ammo_glow()
	update_button_icon()

/datum/action/ability/xeno_action/create_boiler_bomb/update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER])
	var/mutable_appearance/corrosiveglobnumber = visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER]
	corrosiveglobnumber.maptext = MAPTEXT("<font color=green>[xeno_owner.corrosive_ammo]")
	button.add_overlay(visual_references[VREF_MUTABLE_CORROSIVEGLOB_COUNTER])
	button.cut_overlay(visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER])
	var/mutable_appearance/neuroglobnumber = visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER]
	neuroglobnumber.maptext = MAPTEXT("<font color=yellow>[xeno_owner.neuro_ammo]")
	button.add_overlay(visual_references[VREF_MUTABLE_NEUROGLOB_COUNTER])
	return ..()

// ***************************************
// *********** Gas cloud bombs
// ***************************************
/datum/action/ability/activable/xeno/bombard
	name = "Bombard"
	action_icon_state = "bombard"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Dig yourself into place in order to launch a glob of acid or neurotoxin."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BOMBARD,
	)
	target_flags = ABILITY_TURF_TARGET

/datum/action/ability/activable/xeno/bombard/get_cooldown()
	return xeno_owner.xeno_caste.bomb_delay - ((xeno_owner.neuro_ammo + xeno_owner.corrosive_ammo) * (BOILER_BOMBARD_COOLDOWN_REDUCTION SECONDS))

/datum/action/ability/activable/xeno/bombard/on_cooldown_finish()
	to_chat(owner, span_notice("We feel our toxin glands swell. We are able to bombard an area again."))
	if(xeno_owner.selected_ability == src)
		xeno_owner.set_bombard_pointer()
	return ..()

/datum/action/ability/activable/xeno/bombard/on_selection()
	var/current_ammo = xeno_owner.corrosive_ammo + xeno_owner.neuro_ammo
	if(current_ammo <= 0)
		to_chat(xeno_owner, span_notice("We have nothing prepared to fire."))
		return FALSE

	xeno_owner.visible_message(span_notice("\The [xeno_owner] begins digging their claws into the ground."), \
	span_notice("We begin digging ourselves into place."), null, 5)
	if(!do_after(xeno_owner, 3 SECONDS, FALSE, null, BUSY_ICON_HOSTILE))
		on_deselection()
		xeno_owner.selected_ability = null
		xeno_owner.update_action_button_icons()
		xeno_owner.reset_bombard_pointer()
		return FALSE

	xeno_owner.visible_message(span_notice("\The [xeno_owner] digs itself into the ground!"), \
		span_notice("We dig ourselves into place! If we move, we must wait again to fire."), null, 5)
	xeno_owner.set_bombard_pointer()
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED, TYPE_PROC_REF(/datum/action/ability/activable/xeno/bombard, on_ranged_attack))

/datum/action/ability/activable/xeno/bombard/on_deselection()
	if(xeno_owner?.selected_ability == src)
		xeno_owner.reset_bombard_pointer()
		to_chat(xeno_owner, span_notice("We relax our stance."))
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_RANGED)

/datum/action/ability/activable/xeno/bombard/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(A)
	var/turf/S = get_turf(owner)

	if(istype(xeno_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		if(xeno_owner.corrosive_ammo <= 0)
			xeno_owner.balloon_alert(xeno_owner, "No corrosive globules.")
			return FALSE
	else
		if(xeno_owner.neuro_ammo <= 0)
			xeno_owner.balloon_alert(xeno_owner, "No neurotoxin globules.")
			return FALSE

	if(!isturf(T) || T.z != S.z)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "Invalid target.")
		return FALSE

/datum/action/ability/activable/xeno/bombard/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target))
		return

	to_chat(xeno_owner, span_xenonotice("We begin building up pressure."))

	if(!do_after(xeno_owner, 2 SECONDS, IGNORE_HELD_ITEM, target, BUSY_ICON_DANGER))
		to_chat(xeno_owner, span_warning("We decide not to launch."))
		return fail_activate()

	if(!can_use_ability(target, FALSE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] launches a huge glob of acid hurling into the distance!"), \
	span_xenowarning("We launch a huge glob of acid hurling into the distance!"), null, 5)

	var/atom/movable/projectile/P = new /atom/movable/projectile(xeno_owner.loc)
	P.generate_bullet(xeno_owner.ammo)
	P.fire_at(target, xeno_owner, xeno_owner, xeno_owner.ammo.max_range, xeno_owner.ammo.shell_speed)
	playsound(xeno_owner, 'sound/effects/blobattack.ogg', 25, 1)
	if(istype(xeno_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		GLOB.round_statistics.boiler_acid_smokes++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_acid_smokes")
		xeno_owner.corrosive_ammo--
	else
		GLOB.round_statistics.boiler_neuro_smokes++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "boiler_neuro_smokes")
		xeno_owner.neuro_ammo--
	owner.record_war_crime()

	xeno_owner.update_ammo_glow()
	update_button_icon()
	add_cooldown()

/datum/action/ability/activable/xeno/bombard/clean_action()
	xeno_owner.reset_bombard_pointer()
	return ..()

/// Signal proc for clicking at a distance
/datum/action/ability/activable/xeno/bombard/proc/on_ranged_attack(mob/living/carbon/xenomorph/xeno_owner, atom/A, params)
	SIGNAL_HANDLER
	if(can_use_ability(A, TRUE))
		INVOKE_ASYNC(src, PROC_REF(use_ability), A)

/mob/living/carbon/xenomorph/boiler/Moved(atom/OldLoc,Dir)
	. = ..()
	if(selected_ability?.type == /datum/action/ability/activable/xeno/bombard)
		var/datum/action/ability/activable/bomb = actions_by_path[/datum/action/ability/activable/xeno/bombard]
		bomb.on_deselection()
		selected_ability.button.icon_state = "template"
		selected_ability = null
		update_action_button_icons()

/// Set the boiler's mouse cursor to the green firing cursor.
/mob/living/carbon/xenomorph/proc/set_bombard_pointer() //todo:roll into ability
	if(client)
		client.mouse_pointer_icon = 'icons/mecha/mecha_mouse.dmi'

/// Resets the boiler's mouse cursor to the default cursor.
/mob/living/carbon/xenomorph/proc/reset_bombard_pointer() //todo:roll into ability
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)

// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/line/boiler
	cooldown_duration = 9 SECONDS

/datum/action/ability/activable/xeno/acid_shroud
	name = "Acid Shroud"
	action_icon_state = "acid_shroud"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Create a smokescreen of gas, setting your Bombard on a longer cooldown. Does not require or consume a reserved globule."
	ability_cost = 200
	cooldown_duration = 30 SECONDS
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_SHROUD,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_ACID_SHROUD_SELECT,
	)

/datum/action/ability/activable/xeno/acid_shroud/use_ability(atom/A)
	var/datum/effect_system/smoke_spread/emitted_gas //The gas that will emit when the ability activates, can be either acid or neuro.

	if(istype(xeno_owner.ammo, /datum/ammo/xeno/boiler_gas/corrosive))
		emitted_gas = new /datum/effect_system/smoke_spread/xeno/acid/opaque(xeno_owner)
	else
		emitted_gas = new /datum/effect_system/smoke_spread/xeno/neuro(xeno_owner)

	emitted_gas.set_up(2, get_turf(xeno_owner))
	emitted_gas.start()
	succeed_activate()
	add_cooldown()
	var/datum/action/ability/activable/xeno/bombard/bombard_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(bombard_action?.cooldown_timer) //You need to clear a cooldown to add another, so that is done here.
		deltimer(bombard_action.cooldown_timer)
		bombard_action.cooldown_timer = null
		bombard_action.countdown.stop()
	bombard_action?.add_cooldown(xeno_owner.xeno_caste.bomb_delay + 8.5 SECONDS - ((xeno_owner.neuro_ammo + xeno_owner.corrosive_ammo) * (BOILER_BOMBARD_COOLDOWN_REDUCTION SECONDS))) //The cooldown of Bombard that is added when this ability is used. It is the calculation of Bombard cooldown + 10 seconds.

// ***************************************
// *********** Steam Rush
// ***************************************

/datum/action/ability/xeno_action/steam_rush
	name = "Steam Rush"
	action_icon_state = "steam_rush"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Gain a short-lived speed boost. Slashes deal extra burn damage and extend the duration of the sped boost.."
	ability_cost = 100
	cooldown_duration = 25 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_STEAM_RUSH,
	)
	/// Holds the particles instead of the mob.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// The increase of speed when ability is active.
	var/speed_buff = -1
	/// How long the ability will last?
	var/duration = 1.5 SECONDS
	///Timer for steam rush's duration
	var/steam_rush_duration
	/// How much extra burn damage is dealt on slash
	var/steam_damage = 10

/datum/action/ability/xeno_action/steam_rush/action_activate()
	var/mob/living/carbon/xenomorph/boiler/sizzler/X = owner

	if(X.steam_rush)
		to_chat(X, span_xenodanger("Our body is already spewing steam!"))
		return

	X.emote("roar")
	X.visible_message(span_danger("[X]'s body starts to hiss with steam!"), \
	span_xenowarning("We feel steam spraying from our body!"))

	X.steam_rush = TRUE

	steam_rush_duration = addtimer(CALLBACK(src, PROC_REF(steam_rush_deactivate)), duration, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

	X.add_movespeed_modifier(MOVESPEED_ID_BOILER_SIZZLER_STEAM_RUSH, TRUE, 0, NONE, TRUE, speed_buff)

	particle_holder = new(owner, /particles/sizzler_steam)
	particle_holder.pixel_y = -8
	particle_holder.pixel_x = 10

	RegisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(steam_slash))

	succeed_activate()
	add_cooldown()

///Adds burn damage and resets timer during steam rush buff
/datum/action/ability/xeno_action/steam_rush/proc/steam_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	var/mob/living/rusher = owner
	var/datum/action/ability/xeno_action/steam_rush/steam_rush_ability = rusher.actions_by_path[/datum/action/ability/xeno_action/steam_rush]
	var/mob/living/carbon/carbon_target = target

	carbon_target.apply_damage(steam_damage, damagetype = BURN, blocked = ACID)
	playsound(carbon_target, 'sound/voice/alien/hiss2.ogg', 25)
	to_chat(carbon_target, span_danger("You are burned by the hot steam!")) //I'm just going to operate under the assumption that xvx combat will never be a meaningful thing.

	if(steam_rush_ability.steam_rush_duration)
		deltimer(steam_rush_ability.steam_rush_duration)
		steam_rush_ability.steam_rush_duration = addtimer(CALLBACK(src, PROC_REF(steam_rush_deactivate)), duration + 1 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

///Called when we want to end the steam rush ability
/datum/action/ability/xeno_action/steam_rush/proc/steam_rush_deactivate()
	if(QDELETED(owner))
		return
	var/mob/living/carbon/xenomorph/X = owner

	X.remove_movespeed_modifier(MOVESPEED_ID_BOILER_SIZZLER_STEAM_RUSH)

	X.playsound_local(X, 'sound/voice/alien/hiss2.ogg', 50)

	X.steam_rush = FALSE
	QDEL_NULL(particle_holder)
	UnregisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING)

/datum/action/ability/xeno_action/steam_rush/on_cooldown_finish()
	owner.balloon_alert(owner, "Steam rush ready.")
	owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	return ..()

/particles/sizzler_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	width = 100
	height = 300
	count = 50
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 3 SECONDS
	velocity = list(0, 0.3, 0)
	position = list(5, 32, 0)
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, 0.95)
	grow = 0.1

// ***************************************
// *********** Smokescreen Spit
// ***************************************

/datum/action/ability/xeno_action/smokescreen_spit
	name = "Smokescreen Spit"
	action_icon_state = "acid_glob"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Empower your next spit, causing it to create a wide smokescreen."
	ability_cost = 350
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SMOKESCREEN_SPIT,
	)
	use_state_flags = ABILITY_USE_STAGGERED
	/// Timer for the window you have to fire smokescreen spit
	var/smokescreen_spit_window
	/// Duration of the window you have to fire smokescreen spit
	var/window_duration = 1.5 SECONDS

/datum/action/ability/xeno_action/smokescreen_spit/action_activate()
	var/mob/living/carbon/xenomorph/boiler/sizzler/X = owner

	X.ammo = /datum/ammo/xeno/acid/airburst/heavy
	X.update_spits(TRUE)
	X.balloon_alert(owner, "We prepare to fire a smokescreen!")

	smokescreen_spit_window = addtimer(CALLBACK(src, PROC_REF(smokescreen_spit_deactivate)), window_duration, TIMER_UNIQUE)

	succeed_activate()
	add_cooldown()

///Called when smokescreen ability ends to reset our ammo
/datum/action/ability/xeno_action/smokescreen_spit/proc/smokescreen_spit_deactivate()
	if(QDELETED(owner))
		return
	var/mob/living/carbon/xenomorph/boiler/sizzler/X = owner

	X.ammo = /datum/ammo/xeno/acid/airburst
	X.update_spits(TRUE)
	X.balloon_alert(owner, "Our spit returns to normal.")

// ***************************************
// *********** High-Pressure Spit
// ***************************************
/datum/action/ability/activable/xeno/high_pressure_spit
	name = "High-Pressure Spit"
	action_icon_state = "acid_lance_glob"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Fire a high pressure glob of acid that knocks back, stuns, and shatters the target."
	ability_cost = 150
	cooldown_duration = 25 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HIGH_PRESSURE_SPIT,
	)

/datum/action/ability/activable/xeno/high_pressure_spit/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner

	new /obj/effect/temp_visual/wraith_warp(get_turf(owner))

	if(!do_after(X, 1 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	playsound(X.loc, 'sound/voice/alien/hiss2.ogg', 50, 1)

	var/datum/ammo/xeno/acid/heavy/high_pressure_spit/high_pressure_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/high_pressure_spit]

	var/atom/movable/projectile/newspit = new(get_turf(X))
	newspit.generate_bullet(high_pressure_spit)
	newspit.def_zone = X.get_limbzone_target()

	newspit.fire_at(target, X, X, newspit.ammo.max_range)

	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/high_pressure_spit/on_cooldown_finish()
	owner.balloon_alert(owner, "High-pressure spit ready.")
	owner.playsound_local(owner, 'sound/voice/alien/hiss2.ogg', 25, 0, 1)
	return ..()
