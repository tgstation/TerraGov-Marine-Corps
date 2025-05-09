//List of all images used for constuction designating, in the radial selection menu
GLOBAL_LIST_INIT(designator_images_list, list(
	/obj/structure/barricade/solid = image('icons/obj/structures/barricades/metal.dmi', icon_state = "metal_0"),
	/obj/structure/barricade/solid/plasteel = image('icons/obj/structures/barricades/plasteel.dmi', icon_state = "new_plasteel_0"),
	/obj/structure/barricade/folding/metal = image('icons/obj/structures/barricades/metal.dmi', icon_state = "folding_metal_0"),
	/obj/structure/barricade/folding = image('icons/obj/structures/barricades/plasteel.dmi', icon_state = "plasteel_0"),
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
	///The typepath of what we want to construct. Typecast for initial var values
	var/obj/construct_type

/datum/action/ability/activable/build_designator/on_selection()
	RegisterSignal(owner, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(show_hologram_call))
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_owner_rotate))

/datum/action/ability/activable/build_designator/on_deselection()
	UnregisterSignal(owner, list(COMSIG_ATOM_MOUSE_ENTERED, COMSIG_ATOM_DIR_CHANGE))
	cleanup_hologram()

/datum/action/ability/activable/build_designator/use_ability(atom/A)
	if(!isturf(A) || !update_hologram(A))
		owner.balloon_alert(owner, "Invalid spot")
		return FALSE
	new /obj/effect/build_designator(A, construct_type, owner.dir)
	return TRUE

/datum/action/ability/activable/build_designator/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_structure))

///Selects the pattern from a radial menu
/datum/action/ability/activable/build_designator/proc/select_structure()
	var/construct_choice = show_radial_menu(owner, owner, GLOB.designator_images_list, radius = 48)
	if(!construct_choice)
		return
	construct_type = construct_choice

	owner.balloon_alert(owner, "[construct_type::name]")
	cleanup_hologram()
	//show_hologram(owner, get_turf(owner))

///Signal handler for the owner rotating
/datum/action/ability/activable/build_designator/proc/on_owner_rotate(datum/source, dir, newdir)
	SIGNAL_HANDLER
	if(dir == newdir)
		return
	if(!hologram)
		return
	update_hologram(new_dir = newdir)

//Wrapper for show_hologram
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

	if(!hologram)
		create_hologram(target_turf)
	update_hologram(target_turf)
	start_cleanup_timer()

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

//Updates the hologram position and validity
/datum/action/ability/activable/build_designator/proc/update_hologram(turf/target_turf = hologram.loc, new_dir = owner.dir)
	if(hologram.loc != target_turf)
		hologram.abstract_move(target_turf)

	hologram.setDir(new_dir)
	hologram.remove_filter("invalid_turf_filter")

	if(!check_turf_validity(target_turf))
		hologram.add_filter("invalid_turf_filter", 1, color_matrix_filter(rgb(233, 23, 23)))
		return FALSE
	return TRUE

/// check if the turf is valid or not for the selected build type, and apply a matrix color if not
/datum/action/ability/activable/build_designator/proc/check_turf_validity(turf/target_turf)
	if(!isturf(target_turf))
		return FALSE
	if(target_turf.density)
		return FALSE
	if(isspaceturf(target_turf))
		return FALSE
	var/border_obj = (construct_type::atom_flags & ON_BORDER) ? TRUE : FALSE
	for(var/obj/object in target_turf)
		if(!object.density)
			continue
		if(border_obj && (object.atom_flags & ON_BORDER) && (object.dir & hologram.dir))
			continue
		return FALSE
	return TRUE

///Sets the cleanup timer
/datum/action/ability/activable/build_designator/proc/start_cleanup_timer()
	delete_timer()
	cleanup_timer = addtimer(CALLBACK(src, PROC_REF(cleanup_hologram)), cleanup_time, TIMER_STOPPABLE)

///Clears the cleanup timer
/datum/action/ability/activable/build_designator/proc/delete_timer()
	deltimer(cleanup_timer)
	cleanup_timer = null

///Removes the hologram
/datum/action/ability/activable/build_designator/proc/cleanup_hologram()
	delete_timer()
	QDEL_NULL(hologram)

//The actual building hologram
/obj/effect/build_designator
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	smoothing_groups = list(SMOOTH_GROUP_HOLOGRAM)
	canSmoothWith = list(SMOOTH_GROUP_HOLOGRAM)
	alpha = 190
	var/material_type
	var/recipe

/obj/effect/build_designator/Initialize(mapload, obj/construct_type, new_dir) //construct_type is a TYPE but typecast for initial values below
	if(!construct_type)
		return INITIALIZE_HINT_QDEL

	material_type = GLOB.designator_types[construct_type]
	recipe = GLOB.stack_recipes[material_type][construct_type]
	dir = new_dir

	icon = construct_type::icon
	icon_state = construct_type::icon_state
	base_icon_state = construct_type::base_icon_state
	color = construct_type::color
	smoothing_flags = construct_type::smoothing_flags
	. = ..()
	makeHologram(0.7, FALSE)
	QDEL_IN(src, 4 MINUTES)

/obj/effect/build_designator/attackby(obj/item/I, mob/user, params)
	if(!user.dextrous)
		return ..()
	if(!istype(I, material_type))
		return ..()
	var/obj/item/stack/stack = I
	if(!stack.create_object(user, recipe, 1, loc, dir))
		return
	qdel(src)
