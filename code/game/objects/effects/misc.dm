//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = FALSE


/obj/effect/beam
	name = "beam"
	var/def_zone
	allow_pass_flags = PASS_LOW_STRUCTURE


/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = TRUE




/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = TRUE

/obj/effect/soundplayer
	anchored = TRUE
	opacity = FALSE
	icon_state = "speaker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///The sound we want to loop
	var/datum/looping_sound/loop_sound
	///The typepath of our looping sound datum
	var/sound_type
	///Do we start immediately
	var/start_on_init = TRUE

/obj/effect/soundplayer/Initialize(mapload)
	. = ..()
	if(!sound_type)
		return INITIALIZE_HINT_QDEL
	icon_state = ""
	loop_sound = new sound_type(null, FALSE)
	if(start_on_init)
		loop_sound.start(src)

/obj/effect/soundplayer/Destroy()
	. = ..()
	QDEL_NULL(loop_sound)

/obj/effect/soundplayer/deltaplayer
	sound_type = /datum/looping_sound/alarm_loop
	start_on_init = FALSE

/obj/effect/soundplayer/deltaplayer/Initialize(mapload)
	. = ..()
	GLOB.ship_alarms += src
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_alert_change))

/// Start/stop our active sound player when the alert level changes to/from `SEC_LEVEL_DELTA`
/obj/effect/soundplayer/deltaplayer/proc/on_alert_change(datum/source, datum/security_level/next_level, datum/security_level/previous_level)
	SIGNAL_HANDLER
	if(!(next_level.sec_level_flags & SEC_LEVEL_FLAG_STATE_OF_EMERGENCY))
		loop_sound.stop(src)
	else
		loop_sound.start(src)

/obj/effect/soundplayer/deltaplayer/Destroy()
	. = ..()
	GLOB.ship_alarms -= src

/obj/effect/soundplayer/riverplayer
	sound_type = /datum/looping_sound/river_loop

/obj/effect/soundplayer/dripplayer
	sound_type = /datum/looping_sound/drip_loop

/obj/effect/soundplayer/waterreservoirplayer
	sound_type = /datum/looping_sound/water_res_loop

/obj/effect/forcefield
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	icon_state = "blocker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = RESIST_ALL

/obj/effect/forcefield/Initialize(mapload)
	. = ..()
	if(icon_state == "blocker")
		icon_state = ""

/obj/effect/forcefield/allow_bullet_travel
	resistance_flags = RESIST_ALL | PROJECTILE_IMMUNE

/obj/effect/forcefield/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	opacity = TRUE
	explosion_block = INFINITY

/obj/effect/forcefield/fog/Initialize(mapload)
	. = ..()
	dir = pick(CARDINAL_DIRS)
	GLOB.fog_blockers += src

/obj/effect/forcefield/fog/Destroy()
	GLOB.fog_blockers -= src
	return ..()


/obj/effect/forcefield/fog/attack_hand(mob/living/user)
	to_chat(user, span_notice("You peer through the fog, but it's impossible to tell what's on the other side..."))
	return TRUE


/obj/effect/forcefield/fog/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	return attack_hand(xeno_attacker)


/obj/effect/forcefield/fog/attack_animal(M)
	return attack_hand(M)


/obj/effect/forcefield/fog/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isobj(mover)) //No grenades/bullets should cross this
		return FALSE
	if(isxeno(mover))
		return TRUE
	if(ishuman(mover) && !issynth(mover))
		var/mob/living/carbon/human/H = mover
		if(HAS_TRAIT(H, TRAIT_UNDEFIBBABLE)) // Allow pulled perma-dead humans to cross
			return TRUE
	return FALSE

/obj/effect/forcefield/fog/passable_fog
	name = "fog"
	desc = "It looks dangerous to traverse."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	density = FALSE
	resistance_flags = RESIST_ALL|PROJECTILE_IMMUNE

/obj/effect/forcefield/fog/passable_fog/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/effect/forcefield/fog/passable_fog/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	return TRUE

/obj/effect/forcefield/fog/passable_fog/proc/on_cross(datum/source, atom/movable/mover, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!opacity)
		return
	set_opacity(FALSE)
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	addtimer(CALLBACK(src, PROC_REF(reset)), 30 SECONDS)

/obj/effect/forcefield/fog/passable_fog/proc/reset()
	alpha = initial(alpha)
	mouse_opacity = initial(mouse_opacity)
	set_opacity(TRUE)

//used to control opacity of multitiles doors
/obj/effect/opacifier
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_AIRLOCK)

/obj/effect/opacifier/Initialize(mapload, initial_opacity)
	. = ..()
	set_opacity(initial_opacity)

/obj/effect/opacifier/Destroy()
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(loc)

/obj/effect/supplypod_selector
	icon_state = "supplypod_selector"
	layer = FLY_LAYER


/obj/effect/dummy/lighting_obj
	name = "lighting fx obj"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_color = "#FFFFFF"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_system = MOVABLE_LIGHT
	blocks_emissive = EMISSIVE_BLOCK_NONE

/obj/effect/dummy/lighting_obj/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!isnull(_range))
		set_light_range(_range)
	if(!isnull(_power))
		set_light_power(_power)
	if(!isnull(_color))
		set_light_color(_color)
	if(_duration)
		QDEL_IN(src, _duration)


/obj/effect/dummy/lighting_obj/moblight
	name = "mob lighting fx"


/obj/effect/dummy/lighting_obj/moblight/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!ismob(loc))
		return INITIALIZE_HINT_QDEL


/obj/effect/overlay/temp/timestop_effect
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	plane = GAME_PLANE
	alpha = 70

/obj/effect/build_hologram
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	smoothing_groups = list(SMOOTH_GROUP_HOLOGRAM)
	canSmoothWith = list(SMOOTH_GROUP_HOLOGRAM)
	alpha = 190

/obj/effect/build_hologram/Initialize(mapload, atom/copy_type)
	if(ispath(copy_type))
		icon = initial(copy_type.icon)
		icon_state = initial(copy_type.icon_state)
		base_icon_state = initial(copy_type.base_icon_state)
		color = initial(copy_type.color)
		smoothing_flags = initial(copy_type.smoothing_flags)
	. = ..()
	makeHologram(0.7, FALSE)

/////////
/obj/effect/build_designator
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	smoothing_groups = list(SMOOTH_GROUP_HOLOGRAM)
	canSmoothWith = list(SMOOTH_GROUP_HOLOGRAM)
	alpha = 190
	var/material_type
	var/recipe

/obj/effect/build_designator/Initialize(mapload, material, obj/construct_type, new_dir) //construct_type is a TYPE but typecast for initial values below
	if(!material)
		return INITIALIZE_HINT_QDEL
	if(!construct_type)
		return INITIALIZE_HINT_QDEL

	material_type = material
	recipe = GLOB.stack_recipes[material][construct_type]
	dir = new_dir

	icon = construct_type::icon
	icon_state = construct_type::icon_state
	base_icon_state = construct_type::base_icon_state
	color = construct_type::color
	smoothing_flags = construct_type::smoothing_flags
	. = ..()
	makeHologram(0.7, FALSE)
	QDEL_IN(src, 1 MINUTES)

/obj/effect/build_designator/attackby(obj/item/I, mob/user, params)
	if(!user.dextrous)
		return ..()
	if(!istype(I, material_type))
		return ..()
	var/obj/item/stack/stack = I
	if(!stack.create_object(user, recipe, 1, loc, dir))
		return
	qdel(src)

/////////////////////////////////
// Construction Designator
/////////////////////////////////


//List of all images used for constuction designating, in the radial selection menu
GLOBAL_LIST_INIT(designator_images_list, list(
	/obj/structure/barricade/solid = image('icons/obj/structures/barricades/metal.dmi', icon_state = "metal_0"),
	/obj/structure/barricade/solid/plasteel = image('icons/obj/structures/barricades/plasteel.dmi', icon_state = "new_plasteel_0"),
	/obj/structure/barricade/folding/metal = image('icons/obj/structures/barricades/metal.dmi', icon_state = "folding_metal_0"),
	/obj/structure/barricade/folding = image('icons/obj/structures/barricades/plasteel.dmi', icon_state = "new_plasteel_0"),
))

///Assoc list of construction types to source material
GLOBAL_LIST_INIT(designator_types, list (
	/obj/structure/barricade/solid = /obj/item/stack/sheet/metal,
	/obj/structure/barricade/solid/plasteel = /obj/item/stack/sheet/plasteel,
	/obj/structure/barricade/folding/metal = /obj/item/stack/sheet/metal,
	/obj/structure/barricade/folding = /obj/item/stack/sheet/plasteel,
))

/datum/action/ability/activable/build_designator
	name = "Construction Designator"
	desc = "Place a designator for construction."
	action_icon_state = "square2x2"
	action_icon = 'icons/Xeno/patterns.dmi'
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_PATTERN,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_SELECT_PATTERN,
	)
	///personal hologram designator
	var/obj/effect/build_hologram/hologram
	/// timerid before we cleanup the hologram
	var/cleanup_timer
	/// how long a hologram lasts without movement
	var/cleanup_time = 4 SECONDS
	///The typepath of what we want to construct
	var/construct_type

/datum/action/ability/activable/build_designator/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_structure))

/datum/action/ability/activable/build_designator/on_selection()
	RegisterSignal(owner, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(show_hologram_call))

/datum/action/ability/activable/build_designator/on_deselection()
	UnregisterSignal(owner, COMSIG_ATOM_MOUSE_ENTERED)
	cleanup_hologram()

// don't slow down the other signals
/datum/action/ability/activable/build_designator/proc/show_hologram_call(mob/user, atom/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(show_hologram), user, target)

/// move or create a hologram on mousemove, and also start the cleanup timer and check turf validity
/datum/action/ability/activable/build_designator/proc/show_hologram(mob/user, atom/target)
	SIGNAL_HANDLER
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		cleanup_hologram()
		return

	if(hologram)
		hologram.abstract_move(target_turf)
		hologram.setDir(owner.dir)
	else
		create_hologram(target_turf)
	check_turf_validity(target_turf, hologram)
	start_cleanup_timer()


/// check if the turf is valid or not for the selected build type, and apply a matrix color if not
/datum/action/ability/activable/build_designator/proc/check_turf_validity(turf/target_turf, obj/effect/hologram)
	hologram.remove_filter("invalid_turf_filter")
	if(target_turf.density)
		hologram.add_filter("invalid_turf_filter", 1, color_matrix_filter(rgb(233, 23, 23)))
		return
	//TODO: ADD MORE


/// creates the hologram and quickly fades it in, step_size is increased to make movement smoother
/datum/action/ability/activable/build_designator/proc/create_hologram(turf/target_turf)
	var/atom/selected = construct_type
	var/obj/effect/build_hologram/new_hologram = new(target_turf, selected)
	new_hologram.alpha = 0
	new_hologram.layer = ABOVE_OBJ_LAYER
	new_hologram.step_size = 4 * ICON_SIZE_ALL
	animate(new_hologram, 1 SECONDS, alpha = initial(new_hologram.alpha))
	new_hologram.setDir(owner.dir)
	hologram = new_hologram

/datum/action/ability/activable/build_designator/proc/start_cleanup_timer()
	delete_timer()
	cleanup_timer = addtimer(CALLBACK(src, PROC_REF(cleanup_hologram)), cleanup_time, TIMER_STOPPABLE)

/datum/action/ability/activable/build_designator/proc/delete_timer()
	deltimer(cleanup_timer)
	cleanup_timer = null

/datum/action/ability/activable/build_designator/proc/cleanup_hologram()
	delete_timer()
	QDEL_NULL(hologram)

///Selects the pattern from a radial menu
/datum/action/ability/activable/build_designator/proc/select_structure()
	var/construct_choice = show_radial_menu(owner, owner, GLOB.designator_images_list, radius = 48)
	if(!construct_choice)
		return
	construct_type = construct_choice

	owner.balloon_alert(owner, "[construct_choice]")
	cleanup_hologram()
	show_hologram(owner, get_turf(owner))

/datum/action/ability/activable/build_designator/use_ability(atom/A)
	if(!isopenturf(A) || isspaceturf(A))
		owner.balloon_alert(owner, "no valid ground found")
		return FALSE
	// check if one is successful, if none, we output a visible error
	//var/success = FALSE
	new /obj/effect/build_designator(A, GLOB.designator_types[construct_type], construct_type, owner.dir)
	return TRUE
