//100% pure aqua

/turf/open/ground/water
	name = "river"
	icon_state = "seashallow"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER
	minimap_color = MINIMAP_WATER

/turf/open/ground/water/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(has_catwalk || !iscarbon(arrived))
		return
	var/mob/living/carbon/C = arrived
	C.clean_mob()
	if(!C.get_filter("water_obscuring"))
		var/icon/carbon_icon = icon(C.icon)
		var/height_to_use = (64 - carbon_icon.Height()) * 0.5 //gives us the right height based on carbon's icon height relative to the 64 high alpha mask
		C.add_filter("water_obscuring", 1, alpha_mask_filter(0, -11 + height_to_use, icon('icons/turf/alpha_64.dmi', "water_alpha"), null, MASK_INVERSE))
		animate(C.get_filter("water_obscuring"), y = height_to_use, time = 3)

	if(isxeno(C))
		var/mob/living/carbon/xenomorph/xeno = C
		xeno.next_move_slowdown += xeno.xeno_caste.water_slowdown
	else
		C.next_move_slowdown += 1.75

	if(C.on_fire)
		C.ExtinguishMob()

/turf/open/ground/water/Exited(atom/movable/leaver, direction)
	. = ..()
	if(!iscarbon(leaver))
		return
	var/mob/living/carbon/carbon_leaver = leaver
	if(!carbon_leaver.get_filter("water_obscuring"))
		return
	if(istype(get_step(src, direction), type)) //todo replace type with a parent water turf type
		return
	var/icon/carbon_icon = icon(carbon_leaver.icon)
	var/height_to_use = (64 - carbon_icon.Height()) * 0.5
	animate(carbon_leaver.get_filter("water_obscuring"), y = -11 + height_to_use, time = 3)
	addtimer(CALLBACK(carbon_leaver, TYPE_PROC_REF(/atom, remove_filter), "water_obscuring"), 0.3 SECONDS)

/turf/open/ground/water/sea
	name = "water"
	icon_state = "water"

/turf/open/ground/water/sea2
	name = "water"
	icon_state = "water"

/turf/open/ground/water/sea/deep
	name = "sea"
	icon_state = "seadeep"

//Nostromo turfs

/turf/open/ground/water/sea/deep/ocean
	name = "ocean"
	desc = "Its a long way down to the ocean from here."

/turf/open/ground/water/river
	name = "river"
	smoothing_groups = list(
		SMOOTH_GROUP_RIVER,
	)

/obj/effect/river_overlay
	name = "river_overlay"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = RIVER_OVERLAY_LAYER
	plane = FLOOR_PLANE

/turf/open/ground/water/river/autosmooth
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

/turf/open/ground/water/river/deep
	name = "river"
	icon_state = "seadeep"

/turf/open/ground/water/river/poison/Initialize()
	. = ..()
	if(has_catwalk)
		return
	var/obj/effect/river_overlay/R = new(src)
	R.overlays += image("icon"='icons/effects/effects.dmi',"icon_state"="greenglow","layer"=RIVER_OVERLAY_LAYER)


/turf/open/ground/water/river/poison/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/L = arrived
	L.apply_damage(55, TOX, blocked = BIO)
	UPDATEHEALTH(L)


//Desert River
/turf/open/ground/water/river/desertdam
	name = "river"
	icon = 'icons/turf/desertdam_map.dmi'

/turf/open/ground/water/river/desertdam/Initialize() //needed to avoid visual bugs with the river
	return

//shallow water
/turf/open/ground/water/river/desertdam/clean/shallow
	icon_state = "shallow_water_clean"

//shallow water transition to deep
/turf/open/ground/water/river/desertdam/clean/shallow_edge
	icon_state = "shallow_to_deep_clean_water"

/turf/open/ground/water/river/desertdam/clean/shallow_edge/corner
	icon_state = "shallowcorner1"

/turf/open/ground/water/river/desertdam/clean/shallow_edge/corner2
	icon_state = "shallowcorner2"

/turf/open/ground/water/river/desertdam/clean/shallow_edge/alt
	icon_state = "shallow_to_deep_clean_water1"

//deep water
/turf/open/ground/water/river/desertdam/clean/deep_water_clean
	icon_state = "deep_water_clean"

//shallow water coast
/turf/open/ground/water/river/desertdam/clean/shallow_water_desert_coast
	icon_state = "shallow_water_desert_coast"

/turf/open/ground/water/river/desertdam/clean/shallow_water_desert_coast/edge
	icon_state = "shallow_water_desert_coast_edge"

//desert floor waterway
/turf/open/ground/water/river/desertdam/clean/shallow_water_desert_waterway
	icon_state = "desert_waterway"

/turf/open/ground/water/river/desertdam/clean/shallow_water_desert_waterway/edge
	icon_state = "desert_waterway_edge"

//shallow water cave coast
/turf/open/ground/water/river/desertdam/clean/shallow_water_cave_coast
	icon_state = "shallow_water_cave_coast"

//cave floor waterway
/turf/open/ground/water/river/desertdam/clean/shallow_water_cave_waterway
	icon_state = "shallow_water_cave_waterway"

/turf/open/ground/water/river/desertdam/clean/shallow_water_cave_waterway/edge
	icon_state = "shallow_water_cave_waterway_edge"

//TOXIC
/turf/open/ground/water/river/desertdam/toxic
	name = "toxic river"
	icon_state = "shallow_water_toxic"

//shallow water
/turf/open/ground/water/river/desertdam/toxic/shallow_water_toxic
	icon_state = "shallow_water_toxic"

//shallow water transition to deep
/turf/open/ground/water/river/desertdam/toxic/shallow_edge_toxic
	icon_state = "shallow_to_deep_toxic_water"

/turf/open/ground/water/river/desertdam/toxic/shallow_edge_toxic/alt
	icon_state = "shallow_to_deep_toxic_water1"

/turf/open/ground/water/river/desertdam/toxic/shallow_edge_toxic/edge
	icon_state = "shallow_to_deep_toxic_edge"

//deep water
/turf/open/ground/water/river/desertdam/toxic/deep_water_toxic
	icon_state = "deep_water_toxic"

//shallow water coast
/turf/open/ground/water/river/desertdam/toxic/shallow_water_desert_coast_toxic
	icon_state = "shallow_water_desert_coast_toxic"

/turf/open/ground/water/river/desertdam/toxic/shallow_water_desert_coast_toxic/edge
	icon_state = "shallow_water_desert_coast_toxic_edge"

//desert floor waterway
/turf/open/ground/water/river/desertdam/toxic/shallow_water_desert_waterway_toxic
	icon_state = "desert_waterway_toxic"

/turf/open/ground/water/river/desertdam/toxic/shallow_water_desert_waterway_toxic/edge
	icon_state = "desert_waterway_toxic_edge"

//shallow water cave coast
/turf/open/ground/water/river/desertdam/toxic/shallow_water_cave_coast_toxic
	icon_state = "shallow_water_cave_coast_toxic"

/turf/open/ground/water/river/desertdam/toxic/shallow_water_cave_coast_toxic/edge
	icon_state = "shallow_water_cave_coast_toxic_edge"

//cave floor waterway
/turf/open/ground/water/river/desertdam/toxic/shallow_water_cave_waterway_toxic
	icon_state = "shallow_water_cave_waterway_toxic"

/turf/open/ground/water/river/desertdam/toxic/shallow_water_cave_waterway_toxic/edge
	icon_state = "shallow_water_cave_waterway_toxic_edge"

//Sweet refreshing jungle juice
/turf/open/ground/water/jungle_water
	name = "murky water"
	desc = "thick, murky water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"

/turf/open/ground/water/jungle_water/Initialize(mapload, ...)
	. = ..()
	for(var/obj/structure/bush/B in src)
		qdel(B)


/turf/open/ground/water/jungle_water/Entered(atom/movable/arrived, direction)
	. = ..()
	if(!istype(arrived, /mob/living))
		return
	var/mob/living/L = arrived
	//slip in the murky water if we try to run through it
	if(prob(10 + (L.m_intent == MOVE_INTENT_RUN ? 40 : 0)))
		to_chat(L, pick(span_notice(" You slip on something slimy."), span_notice("You fall over into the murk.")))
		L.Stun(40)
		L.Paralyze(20)

	//piranhas
	if(prob(25))
		to_chat(L, pick(span_warning(" Something sharp bites you!"),span_warning(" Sharp teeth grab hold of you!"),span_warning(" You feel something take a chunk out of your leg!")))
		L.apply_damage(1, BRUTE, sharp = TRUE)


/turf/open/ground/water/jungle_water/deep
	density = TRUE
	icon_state = "water2"
