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


/turf/open/liquid/Initialize(mapload)
	AddElement(/datum/element/submerge) //added first so it loads all the contents correctly
	RegisterSignals(src, list(COMSIG_TURF_JUMP_ENDED_HERE, COMSIG_TURF_THROW_ENDED_HERE), PROC_REF(atom_entered))
	return ..()

/turf/open/liquid/Destroy(force)
	if(!(get_submerge_height() - mob_liquid_height) && !(get_submerge_depth() - mob_liquid_depth))
		RemoveElement(/datum/element/submerge)
	return ..()

/turf/open/liquid/AfterChange()
	. = ..()
	baseturfs = type

/turf/open/liquid/is_weedable()
	return FALSE

/turf/open/liquid/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	return atom_entered(src, arrived)

/turf/open/liquid/get_submerge_height(turf_only = FALSE)
	. = ..()
	if(is_covered())
		return
	if(length(canSmoothWith) && !CHECK_MULTIPLE_BITFIELDS(smoothing_junction, (SOUTH_JUNCTION|EAST_JUNCTION|WEST_JUNCTION)))
		return
	. += mob_liquid_height

/turf/open/liquid/get_submerge_depth()
	if(is_covered())
		return 0
	if(length(canSmoothWith) && !CHECK_MULTIPLE_BITFIELDS(smoothing_junction, (SOUTH_JUNCTION|EAST_JUNCTION|WEST_JUNCTION)))
		return 0
	return mob_liquid_depth

///Effects applied to anything that lands in the liquid
/turf/open/liquid/proc/atom_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!check_submerge(arrived))
		return FALSE
	entry_effects(arrived)
	return TRUE

///Returns TRUE if the AM is actually in the liquid instead of above it
/turf/open/liquid/proc/check_submerge(atom/movable/submergee)
	if(is_covered())
		return FALSE
	if(submergee.throwing)
		return FALSE
	if(HAS_TRAIT(submergee, TRAIT_NOSUBMERGE))
		return FALSE
	return TRUE

///Applies liquid effects to an AM
/turf/open/liquid/proc/entry_effects(atom/movable/target)
	if(!isliving(target))
		return
	var/mob/living_target = target
	living_target.next_move_slowdown += (living_target.get_liquid_slowdown() * slowdown_multiplier)

/turf/open/liquid/water
	name = "river"
	icon_state = "seashallow"
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER
	minimap_color = MINIMAP_WATER

/turf/open/liquid/water/Initialize(mapload)
	. = ..()
	if(mob_liquid_height > 15)
		shoefootstep = FOOTSTEP_SWIM
		barefootstep = FOOTSTEP_SWIM
		mediumxenofootstep = FOOTSTEP_SWIM
		heavyxenofootstep = FOOTSTEP_SWIM

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

/turf/open/liquid/water/river/autosmooth/desert
	icon = 'icons/turf/floors/river_desert.dmi'

/turf/open/liquid/water/river/autosmooth/desert/deep
	icon_state = "river_deep-icon"
	mob_liquid_height = 18
	mob_liquid_depth = -8
	slowdown_multiplier = 1.5

/turf/open/liquid/water/river/autosmooth/deep
	icon_state = "river_deep-icon"
	mob_liquid_height = 18
	mob_liquid_depth = -8
	slowdown_multiplier = 1.5

//Desert River
/turf/open/liquid/water/river/desertdam
	name = "river"
	icon = 'icons/turf/desertdam_map.dmi'

//shallow water
/turf/open/liquid/water/river/desertdam/clean/shallow
	icon_state = "shallow_water_clean"

/turf/open/liquid/water/river/desertdam/clean/shallow/dirty
	icon_state = "shallow_water_dirty"

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

// desert dam turf that doesnt make you sink when ya step on it
ww
/turf/open/liquid/water/river/desertdam/notliquid
	name = "shallow river"
	desc = "It looks shallow enough to walk in with ease."
	icon = 'icons/turf/desertdam_map.dmi'
	mob_liquid_height = 0
	mob_liquid_depth = 0
	slowdown_multiplier = 0.25

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow
	icon_state = "shallow_water_clean"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow/dirty
	icon_state = "shallow_water_dirty"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_edge
	icon_state = "shallow_to_deep_clean_water"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_edge/corner
	icon_state = "shallowcorner1"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_edge/corner2
	icon_state = "shallowcorner2"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_edge/alt
	icon_state = "shallow_to_deep_clean_water1"

/turf/open/liquid/water/river/desertdam/notliquid/clean/deep_water_clean
	icon_state = "deep_water_clean"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_water_desert_coast
	icon_state = "shallow_water_desert_coast"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_water_desert_coast/edge
	icon_state = "shallow_water_desert_coast_edge"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_water_desert_waterway
	icon_state = "desert_waterway"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_water_desert_waterway/edge
	icon_state = "desert_waterway_edge"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_water_cave_coast
	icon_state = "shallow_water_cave_coast"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_water_cave_waterway
	icon_state = "shallow_water_cave_waterway"

/turf/open/liquid/water/river/desertdam/notliquid/clean/shallow_water_cave_waterway/edge
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

/turf/open/liquid/lava/Exited(atom/movable/leaver, direction)
	. = ..()
	if(isliving(leaver))
		var/mob/living/L = leaver
		if(!islava(get_step(src, direction)) && !L.on_fire)
			L.update_fire()

/turf/open/liquid/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSobj, src)

/turf/open/liquid/lava/entry_effects(atom/movable/target)
	. = ..()
	if(burn_stuff(target))
		START_PROCESSING(SSobj, src)

///Handles burning turf contents or an entering AM. Returns true to keep processing
/turf/open/liquid/lava/proc/burn_stuff(AM)
	var/thing_to_check = AM ? list(AM) : src
	for(var/atom/thing AS in thing_to_check)
		if(thing.lava_act())
			. = TRUE

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

//Mapping helpers
/turf/open/liquid/lava/catwalk
	icon_state = "lavacatwalk"

/turf/open/liquid/lava/catwalk/Initialize(mapload)
	. = ..()
	icon_state = "full"
	new /obj/structure/catwalk(src)

/turf/open/liquid/lava/autosmoothing/catwalk
	icon_state = "lavacatwalk"

/turf/open/liquid/lava/autosmoothing/catwalk/Initialize(mapload)
	. = ..()
	new /obj/structure/catwalk(src)
