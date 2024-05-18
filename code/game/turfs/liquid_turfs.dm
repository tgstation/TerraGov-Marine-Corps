///The alpha mask used on mobs submerged in liquid turfs
#define MOB_LIQUID_TURF_MASK "mob_liquid_turf_mask"
///The height of the mask itself in the icon state. Changes to the icon requires a change to this define
#define MOB_LIQUID_TURF_MASK_HEIGHT 32

#define OBJ_LIQUID_TURF_ALPHA_MULT 11

/turf/open/liquid //Basic liquid turf parent
	name = "liquid"
	icon = 'icons/turf/ground_map.dmi'
	can_bloody = FALSE
	allow_construction = FALSE
	///Multiplier on any slowdown applied to a mob moving through this turf
	var/slowdown_multiplier = 1
	///How high up on the mob water overlays sit
	var/mob_liquid_height = 11
	///How far down the mob visually drops down when in water
	var/mob_liquid_depth = -5

/turf/open/liquid/AfterChange()
	. = ..()
	baseturfs = type

/turf/open/liquid/attackby()
	return

/turf/open/liquid/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_TURF_CHECK_COVERED))
		return FALSE
	. = TRUE

	if(!isliving(arrived) || arrived.throwing)
		return
	var/mob/living/arrived_mob = arrived
	arrived_mob.next_move_slowdown += (arrived_mob.get_liquid_slowdown() * slowdown_multiplier)

////////////////////////////////////////

/atom/movable/proc/set_submerge_level(turf/new_loc, turf/old_loc)
	return

/mob/living/set_submerge_level(turf/new_loc, turf/old_loc)
	var/old_height = istype(old_loc) ? old_loc.get_submerge_height() : 0
	var/new_height = istype(new_loc) ? new_loc.get_submerge_height() : 0
	var/height_diff = new_height - old_height

	var/old_depth = istype(old_loc) ? old_loc.get_submerge_depth() : 0
	var/new_depth = istype(new_loc) ? new_loc.get_submerge_depth() : 0
	var/depth_diff = new_depth - old_depth

	if(!height_diff && !depth_diff)
		return

	var/icon/mob_icon = icon(icon)
	var/height_to_use = (64 - mob_icon.Height()) * 0.5 //gives us the right height based on carbon's icon height relative to the 64 high alpha mask

	if(!new_height && !new_depth)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_filter), MOB_LIQUID_TURF_MASK), cached_multiplicative_slowdown + next_move_slowdown)

	else if(!get_filter(MOB_LIQUID_TURF_MASK))
		//The mask is spawned below the mob, then the animate() raises it up, giving the illusion of dropping into water, combining with the animate to actual drop the pixel_y into the water
		add_filter(MOB_LIQUID_TURF_MASK, 1, alpha_mask_filter(0, height_to_use - MOB_LIQUID_TURF_MASK_HEIGHT, icon('icons/turf/alpha_64.dmi', "liquid_alpha"), null, MASK_INVERSE))

	animate(get_filter(MOB_LIQUID_TURF_MASK), y = height_to_use - (MOB_LIQUID_TURF_MASK_HEIGHT - new_height), time = cached_multiplicative_slowdown + next_move_slowdown)
	animate(src, pixel_y = src.pixel_y + depth_diff, time = cached_multiplicative_slowdown + next_move_slowdown, flags = ANIMATION_PARALLEL)

/obj/item/set_submerge_level(turf/new_loc, turf/old_loc)
	var/old_alpha_mod = istype(old_loc) ? old_loc.get_submerge_height() * OBJ_LIQUID_TURF_ALPHA_MULT : 0
	var/new_alpha_mod = istype(new_loc) ? new_loc.get_submerge_height() * OBJ_LIQUID_TURF_ALPHA_MULT : 0
	var/alpha_mod_diff = new_alpha_mod - old_alpha_mod

	alpha -= alpha_mod_diff

/turf/proc/get_submerge_height()
	return 0

/turf/open/liquid/get_submerge_height()
	if(SEND_SIGNAL(src, COMSIG_TURF_CHECK_COVERED))
		return 0
	if(length(canSmoothWith) && !CHECK_MULTIPLE_BITFIELDS(smoothing_junction, (SOUTH_JUNCTION|EAST_JUNCTION|WEST_JUNCTION)))
		return 0
	return mob_liquid_height

/turf/proc/get_submerge_depth()
	return 0

/turf/open/liquid/get_submerge_depth()
	if(SEND_SIGNAL(src, COMSIG_TURF_CHECK_COVERED))
		return 0
	if(length(canSmoothWith) && !CHECK_MULTIPLE_BITFIELDS(smoothing_junction, (SOUTH_JUNCTION|EAST_JUNCTION|WEST_JUNCTION)))
		return 0
	return mob_liquid_depth

////////////////////////////////////
/turf/open/liquid/water
	name = "river"
	icon_state = "seashallow"
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER
	minimap_color = MINIMAP_WATER

/turf/open/liquid/water/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!.)
		return

	if(!iscarbon(arrived))
		return

	var/mob/living/carbon/carbon_mob = arrived
	carbon_mob.wash()

	if(carbon_mob.on_fire)
		carbon_mob.ExtinguishMob()

/turf/open/liquid/water/sea
	name = "water"
	icon_state = "seadeep"

/turf/open/liquid/water/river
	name = "river"
	smoothing_groups = list(
		SMOOTH_GROUP_RIVER,
	)

/turf/open/liquid/water/river/deep
	icon_state = "seashallow_deep"
	mob_liquid_height = 18
	mob_liquid_depth = -8

/turf/open/liquid/water/river/deep/Initialize(mapload)
	. = ..()
	icon_state = "seashallow"

/turf/open/liquid/water/river/autosmooth
	icon = 'icons/turf/floors/river.dmi'
	icon_state = "river-icon"
	base_icon_state = "river"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_RIVER)
	canSmoothWith = list(
		SMOOTH_GROUP_RIVER,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_LATTICE,
		SMOOTH_GROUP_GRILLE,
		SMOOTH_GROUP_MINERAL_STRUCTURES,
	)

/turf/open/liquid/water/river/autosmooth/deep
	icon_state = "river_deep-icon"
	mob_liquid_height = 18
	mob_liquid_depth = -8
	slowdown_multiplier = 1.5

//Desert River
/turf/open/liquid/water/river/desertdam
	name = "river"
	icon = 'icons/turf/desertdam_map.dmi'

/turf/open/liquid/water/river/desertdam/Initialize() //needed to avoid visual bugs with the river
	return INITIALIZE_HINT_NORMAL //haha totally normal, TODO DEAL WITH THIS INSTEAD OF THIS BANDAID

//shallow water
/turf/open/liquid/water/river/desertdam/clean/shallow
	icon_state = "shallow_water_clean"

//shallow water transition to deep
/turf/open/liquid/water/river/desertdam/clean/shallow_edge
	icon_state = "shallow_to_deep_clean_water"

/turf/open/liquid/water/river/desertdam/clean/shallow_edge/corner
	icon_state = "shallowcorner1"

/turf/open/liquid/water/river/desertdam/clean/shallow_edge/corner2
	icon_state = "shallowcorner2"

/turf/open/liquid/water/river/desertdam/clean/shallow_edge/alt
	icon_state = "shallow_to_deep_clean_water1"

//deep water
/turf/open/liquid/water/river/desertdam/clean/deep_water_clean
	icon_state = "deep_water_clean"

//shallow water coast
/turf/open/liquid/water/river/desertdam/clean/shallow_water_desert_coast
	icon_state = "shallow_water_desert_coast"

/turf/open/liquid/water/river/desertdam/clean/shallow_water_desert_coast/edge
	icon_state = "shallow_water_desert_coast_edge"

//desert floor waterway
/turf/open/liquid/water/river/desertdam/clean/shallow_water_desert_waterway
	icon_state = "desert_waterway"

/turf/open/liquid/water/river/desertdam/clean/shallow_water_desert_waterway/edge
	icon_state = "desert_waterway_edge"

//shallow water cave coast
/turf/open/liquid/water/river/desertdam/clean/shallow_water_cave_coast
	icon_state = "shallow_water_cave_coast"

//cave floor waterway
/turf/open/liquid/water/river/desertdam/clean/shallow_water_cave_waterway
	icon_state = "shallow_water_cave_waterway"

/turf/open/liquid/water/river/desertdam/clean/shallow_water_cave_waterway/edge
	icon_state = "shallow_water_cave_waterway_edge"

// LAVA
/turf/open/liquid/lava
	name = "lava"
	icon = 'icons/turf/lava.dmi'
	icon_state = "full"
	light_system = STATIC_LIGHT //theres a lot of lava, dont change this
	light_range = 2
	light_power = 1.4
	light_color = LIGHT_COLOR_LAVA
	minimap_color = MINIMAP_LAVA
	slowdown_multiplier = 1.5

/turf/open/liquid/lava/is_weedable()
	return FALSE

/turf/open/liquid/lava/Initialize(mapload)
	. = ..()
	var/turf/current_turf = get_turf(src)
	if(current_turf && density)
		current_turf.atom_flags |= AI_BLOCKED

/turf/open/liquid/lava/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(burn_stuff(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/liquid/lava/Exited(atom/movable/leaver, direction)
	. = ..()
	if(isliving(leaver))
		var/mob/living/L = leaver
		if(!islava(get_step(src, direction)) && !L.on_fire)
			L.update_fire()

/turf/open/liquid/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSobj, src)

///Handles burning turf contents or an entering AM. Returns true to keep processing
/turf/open/liquid/lava/proc/burn_stuff(AM)
	var/thing_to_check = AM ? list(AM) : src
	for(var/atom/thing AS in thing_to_check)
		if(thing.lava_act())
			. = TRUE

/turf/open/liquid/lava/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/turf/open/lavaland/catwalk/H = locate(/turf/open/lavaland/catwalk, src)
		if(H)
			to_chat(user, span_warning("There is already a catwalk here!"))
			return
		if(!do_after(user, 5 SECONDS, IGNORE_HELD_ITEM))
			to_chat(user, span_warning("It takes time to construct a catwalk!"))
			return
		if(R.use(4))
			to_chat(user, span_notice("You construct a heatproof catwalk."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			ChangeTurf(/turf/open/lavaland/catwalk/built)
			var/turf/current_turf = get_turf(src)
			if(current_turf && density)
				current_turf.atom_flags &= ~AI_BLOCKED
		else
			to_chat(user, span_warning("You need four rods to build a heatproof catwalk."))
		return

/turf/open/liquid/lava/corner
	icon_state = "corner"

/turf/open/liquid/lava/side
	icon_state = "side"

/turf/open/liquid/lava/lpiece
	icon_state = "lpiece"

/turf/open/liquid/lava/single/
	icon_state = "single"

/turf/open/liquid/lava/single/intersection
	icon_state = "single_intersection"

/turf/open/liquid/lava/single_intersection/direction
	icon_state = "single_intersection_direction"

/turf/open/liquid/lava/single/middle
	icon_state = "single_middle"

/turf/open/liquid/lava/single/end
	icon_state = "single_end"

/turf/open/liquid/lava/single/corners
	icon_state = "single_corners"

/turf/open/liquid/lava/autosmoothing
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "lava-icon"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA, SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE)
	base_icon_state = "lava"

#undef MOB_LIQUID_TURF_MASK
#undef MOB_LIQUID_TURF_MASK_HEIGHT
#undef OBJ_LIQUID_TURF_ALPHA_MULT
