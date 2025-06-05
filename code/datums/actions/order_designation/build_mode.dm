//build mode designation specific procs

///Designator alt appearance key
#define HOLO_BUILD_DESIGNATOR_ALT_APPEARANCE "holo_build_designator_alt_appearance"

//List of all images used for constuction designating, in the radial selection menu
GLOBAL_LIST_INIT(designator_images_list, list(
	INTERACT_DESIGNATOR_MODE = image('icons/mob/actions.dmi', icon_state = "interact_designator"),
	/obj/structure/barricade/solid = image('icons/obj/structures/barricades/metal.dmi', icon_state = "metal_0"),
	/obj/structure/barricade/solid/plasteel = image('icons/obj/structures/barricades/plasteel.dmi', icon_state = "new_plasteel_0"),
	/obj/structure/barricade/folding/metal = image('icons/obj/structures/barricades/metal.dmi', icon_state = "folding_metal_0"),
	/obj/structure/barricade/folding = image('icons/obj/structures/barricades/plasteel.dmi', icon_state = "plasteel_0"),
))

/datum/action/ability/activable/build_designator
	///personal hologram designator
	var/obj/effect/build_hologram/hologram
	///The typepath of what we want to construct. Typecast for initial var values
	var/obj/construct_type

///Assoc list of construction types to source material
GLOBAL_LIST_INIT(designator_types, list (
	/obj/structure/barricade/solid = /obj/item/stack/sheet/metal,
	/obj/structure/barricade/solid/plasteel = /obj/item/stack/sheet/plasteel,
	/obj/structure/barricade/folding/metal = /obj/item/stack/sheet/metal,
	/obj/structure/barricade/folding = /obj/item/stack/sheet/plasteel,
))

///build designation side of use_ability
/datum/action/ability/activable/build_designator/proc/use_build_ability(atom/target)
	if(!isturf(target) || !update_hologram(target))
		owner.balloon_alert(owner, "Invalid spot")
		return FALSE
	new /obj/effect/build_designator(target, construct_type, owner)
	return TRUE

///Selects the pattern from a radial menu
/datum/action/ability/activable/build_designator/proc/select_structure()
	var/construct_choice = show_radial_menu(owner, owner?.client?.eye, GLOB.designator_images_list)
	if(!construct_choice)
		return
	if(construct_choice == INTERACT_DESIGNATOR_MODE)
		swap_mode(INTERACT_DESIGNATOR_MODE)
		return

	construct_type = construct_choice

	owner.balloon_alert(owner, "[construct_type::name]")
	cleanup_hologram()

///Signal handler for the owner rotating
/datum/action/ability/activable/build_designator/proc/on_owner_rotate(datum/source, dir, newdir)
	SIGNAL_HANDLER
	if(dir == newdir)
		return
	if(!hologram)
		return
	update_hologram(new_dir = newdir)

///Wrapper for show_hologram
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

/// creates the hologram and quickly fades it in, step_size is increased to make movement smoother
/datum/action/ability/activable/build_designator/proc/create_hologram(turf/target_turf)
	var/atom/selected = construct_type
	var/obj/effect/build_hologram/new_hologram = new(target_turf, selected, TRUE, owner)
	new_hologram.alpha = 0
	new_hologram.layer = ABOVE_OBJ_LAYER
	new_hologram.glide_size = 32
	animate(new_hologram, 1 SECONDS, alpha = initial(new_hologram.alpha))
	new_hologram.setDir(owner.dir)
	hologram = new_hologram

///Updates the hologram position and validity
/datum/action/ability/activable/build_designator/proc/update_hologram(turf/target_turf = hologram.loc, new_dir = owner.dir)
	if(!hologram)
		return FALSE
	if(hologram.loc != target_turf)
		hologram.abstract_move(target_turf)

	hologram.setDir(new_dir)
	hologram.remove_filter("invalid_turf_filter")

	if(!check_turf_validity(target_turf))
		hologram.add_filter("invalid_turf_filter", 1, color_matrix_filter(rgb(233, 23, 23)))
		return FALSE
	return TRUE

/// check if the turf is valid or not for the selected build type, and apply a matrix color if not
/datum/action/ability/activable/build_designator/proc/check_turf_validity(turf/open/target_turf)
	if(!isopenturf(target_turf))
		return FALSE
	if(!target_turf.allow_construction)
		return FALSE
	var/area/area = get_area(target_turf)
	if(area.area_flags & NO_CONSTRUCTION)
		return FALSE
	if(isspaceturf(target_turf))
		return FALSE
	var/border_obj = construct_type::atom_flags & ON_BORDER
	for(var/obj/object in target_turf)
		if(!object.density)
			continue
		if(border_obj && (object.atom_flags & ON_BORDER) && !(object.dir & hologram.dir))
			continue
		return FALSE
	return TRUE

///Removes the hologram
/datum/action/ability/activable/build_designator/proc/cleanup_hologram()
	QDEL_NULL(hologram)

//The actual building hologram

/obj/effect/build_designator
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	hud_possible = list(ORDER_HUD)
	///Material needed for the recipe
	var/obj/material_type
	///Recipe for what we are building
	var/datum/stack_recipe/recipe
	///Mob that is currently trying to build the recipe
	var/mob/builder

/obj/effect/build_designator/Initialize(mapload, obj/construct_type, mob/builder) //construct_type is a TYPE but typecast for initial values below
	if(!construct_type)
		return INITIALIZE_HINT_QDEL

	material_type = GLOB.designator_types[construct_type]
	recipe = GLOB.stack_recipes[material_type][construct_type]

	//Because we only want this hologram visible via the right hud, but we want all the nice effects, we fully configure the appearance,
	//then make a blank alt appearance for other factions to 'see'

	dir = builder.dir
	icon = construct_type::icon
	icon_state = construct_type::icon_state
	faction = builder.faction

	name = "holo [construct_type::name]"
	desc = "A holographic representation of a [construct_type::name]. Apply [recipe.req_amount] [material_type::name] to build it."
	. = ..()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HOLO_BUILD_INITIALIZED, src)
	makeHologram(0.7)

	var/image/disguised_icon = image(loc = src)
	disguised_icon.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/not_faction, HOLO_BUILD_DESIGNATOR_ALT_APPEARANCE, disguised_icon, builder.faction)

	QDEL_IN(src, 4 MINUTES)

/obj/effect/build_designator/Destroy()
	remove_alt_appearance(HOLO_BUILD_DESIGNATOR_ALT_APPEARANCE)
	builder = null
	return ..()

/obj/effect/build_designator/attackby(obj/item/I, mob/user, params)
	if(!user.dextrous)
		return ..()
	if(!istype(I, material_type))
		return ..()
	var/obj/item/stack/stack = I
	builder = user
	if(!stack.create_object(user, recipe, 1, loc, dir, TRUE)) //override stack loc for NPC use. It should be impossible to reach this without being an npc
		builder = null
		return
	qdel(src)
