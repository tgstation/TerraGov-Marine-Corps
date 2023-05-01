///The alpha mask used on mobs submerged in liquid turfs
#define MOB_LIQUID_TURF_MASK "mob_liquid_turf_mask"
///The height of the mask itself in the icon state. Changes to the icon requires a change to this define
#define MOB_LIQUID_TURF_MASK_HEIGHT 32


/turf/open/liquid //Basic liquid turf parent
	name = "liquid"
	icon = 'icons/turf/ground_map.dmi'
	can_bloody = FALSE
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
	if(has_catwalk)
		return FALSE
	. = TRUE

	if(!iscarbon(arrived))
		return

	if(length(canSmoothWith) && !CHECK_MULTIPLE_BITFIELDS(smoothing_junction, (SOUTH_JUNCTION|EAST_JUNCTION|WEST_JUNCTION)))
		return

	var/mob/living/carbon/carbon_mob = arrived
	if(carbon_mob.get_filter(MOB_LIQUID_TURF_MASK))
		return

	var/icon/carbon_icon = icon(carbon_mob.icon)
	var/height_to_use = (64 - carbon_icon.Height()) * 0.5 //gives us the right height based on carbon's icon height relative to the 64 high alpha mask

	//The mask is spawned below the mob, then the animate() raises it up, giving the illusion of dropping into water, combining with the animate to actual drop the pixel_y into the water
	carbon_mob.add_filter(MOB_LIQUID_TURF_MASK, 1, alpha_mask_filter(0, height_to_use - MOB_LIQUID_TURF_MASK_HEIGHT, icon('icons/turf/alpha_64.dmi', "liquid_alpha"), null, MASK_INVERSE))

	animate(carbon_mob.get_filter(MOB_LIQUID_TURF_MASK), y = height_to_use - (MOB_LIQUID_TURF_MASK_HEIGHT - mob_liquid_height), time = carbon_mob.cached_multiplicative_slowdown + carbon_mob.next_move_slowdown)
	animate(carbon_mob, pixel_y = carbon_mob.pixel_y + mob_liquid_depth, time = carbon_mob.cached_multiplicative_slowdown + carbon_mob.next_move_slowdown, flags = ANIMATION_PARALLEL)

/turf/open/liquid/Exited(atom/movable/leaver, direction)
	. = ..()
	if(!iscarbon(leaver))
		return
	var/mob/living/carbon/carbon_leaver = leaver
	if(!carbon_leaver.get_filter(MOB_LIQUID_TURF_MASK))
		return

	var/turf/open/liquid/new_turf = get_step(src, direction)
	if(istype(new_turf))
		if(length(new_turf.canSmoothWith))
			if(!new_turf.has_catwalk && CHECK_MULTIPLE_BITFIELDS(new_turf.smoothing_junction, (SOUTH_JUNCTION|EAST_JUNCTION|WEST_JUNCTION)))
				return
		else if(!new_turf.has_catwalk)
			return

	var/icon/carbon_icon = icon(carbon_leaver.icon)
	animate(carbon_leaver.get_filter(MOB_LIQUID_TURF_MASK), y = ((64 - carbon_icon.Height()) * 0.5) - MOB_LIQUID_TURF_MASK_HEIGHT, time = carbon_leaver.cached_multiplicative_slowdown + carbon_leaver.next_move_slowdown)
	animate(carbon_leaver, pixel_y = carbon_leaver.pixel_y - mob_liquid_depth, time = carbon_leaver.cached_multiplicative_slowdown + carbon_leaver.next_move_slowdown, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(carbon_leaver, TYPE_PROC_REF(/atom, remove_filter), MOB_LIQUID_TURF_MASK), carbon_leaver.cached_multiplicative_slowdown + carbon_leaver.next_move_slowdown)

///Default slowdown for mobs moving through water
#define MOB_WATER_SLOWDOWN 1.75

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
	carbon_mob.clean_mob()

	if(carbon_mob.on_fire)
		carbon_mob.ExtinguishMob()

	if(isxeno(carbon_mob))
		var/mob/living/carbon/xenomorph/xeno = carbon_mob
		xeno.next_move_slowdown += xeno.xeno_caste.water_slowdown
	else
		carbon_mob.next_move_slowdown += MOB_WATER_SLOWDOWN

/turf/open/liquid/water/sea
	name = "water"
	icon_state = "water"

/turf/open/liquid/water/sea2
	name = "water"
	icon_state = "water"

/turf/open/liquid/water/sea/deep
	name = "sea"
	icon_state = "seadeep"
	mob_liquid_height = 20

//Nostromo turfs

/turf/open/liquid/water/sea/deep/ocean
	name = "ocean"
	desc = "Its a long way down to the ocean from here."

/turf/open/liquid/water/river
	name = "river"
	smoothing_groups = list(
		SMOOTH_GROUP_RIVER,
	)

/obj/effect/river_overlay
	name = "river_overlay"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = RIVER_OVERLAY_LAYER
	plane = FLOOR_PLANE

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

/turf/open/liquid/water/river/deep
	name = "river"
	icon_state = "seadeep"

/turf/open/liquid/water/river/poison/Initialize()
	. = ..()
	if(has_catwalk)
		return
	var/obj/effect/river_overlay/R = new(src)
	R.overlays += image("icon"='icons/effects/effects.dmi',"icon_state"="greenglow","layer"=RIVER_OVERLAY_LAYER)


/turf/open/liquid/water/river/poison/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/L = arrived
	L.apply_damage(55, TOX, blocked = BIO)
	UPDATEHEALTH(L)


//Desert River
/turf/open/liquid/water/river/desertdam
	name = "river"
	icon = 'icons/turf/desertdam_map.dmi'

/turf/open/liquid/water/river/desertdam/Initialize() //needed to avoid visual bugs with the river
	return

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

//TOXIC
/turf/open/liquid/water/river/desertdam/toxic
	name = "toxic river"
	icon_state = "shallow_water_toxic"

//shallow water
/turf/open/liquid/water/river/desertdam/toxic/shallow_water_toxic
	icon_state = "shallow_water_toxic"

//shallow water transition to deep
/turf/open/liquid/water/river/desertdam/toxic/shallow_edge_toxic
	icon_state = "shallow_to_deep_toxic_water"

/turf/open/liquid/water/river/desertdam/toxic/shallow_edge_toxic/alt
	icon_state = "shallow_to_deep_toxic_water1"

/turf/open/liquid/water/river/desertdam/toxic/shallow_edge_toxic/edge
	icon_state = "shallow_to_deep_toxic_edge"

//deep water
/turf/open/liquid/water/river/desertdam/toxic/deep_water_toxic
	icon_state = "deep_water_toxic"

//shallow water coast
/turf/open/liquid/water/river/desertdam/toxic/shallow_water_desert_coast_toxic
	icon_state = "shallow_water_desert_coast_toxic"

/turf/open/liquid/water/river/desertdam/toxic/shallow_water_desert_coast_toxic/edge
	icon_state = "shallow_water_desert_coast_toxic_edge"

//desert floor waterway
/turf/open/liquid/water/river/desertdam/toxic/shallow_water_desert_waterway_toxic
	icon_state = "desert_waterway_toxic"

/turf/open/liquid/water/river/desertdam/toxic/shallow_water_desert_waterway_toxic/edge
	icon_state = "desert_waterway_toxic_edge"

//shallow water cave coast
/turf/open/liquid/water/river/desertdam/toxic/shallow_water_cave_coast_toxic
	icon_state = "shallow_water_cave_coast_toxic"

/turf/open/liquid/water/river/desertdam/toxic/shallow_water_cave_coast_toxic/edge
	icon_state = "shallow_water_cave_coast_toxic_edge"

//cave floor waterway
/turf/open/liquid/water/river/desertdam/toxic/shallow_water_cave_waterway_toxic
	icon_state = "shallow_water_cave_waterway_toxic"

/turf/open/liquid/water/river/desertdam/toxic/shallow_water_cave_waterway_toxic/edge
	icon_state = "shallow_water_cave_waterway_toxic_edge"

//Sweet refreshing jungle juice
/turf/open/liquid/water/jungle_water
	name = "murky water"
	desc = "thick, murky water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"

/turf/open/liquid/water/jungle_water/Initialize(mapload, ...)
	. = ..()
	for(var/obj/structure/bush/B in src)
		qdel(B)


/turf/open/liquid/water/jungle_water/Entered(atom/movable/arrived, direction)
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


/turf/open/liquid/water/jungle_water/deep
	density = TRUE
	icon_state = "water2"


// LAVA

#define LAVA_TILE_BURN_DAMAGE 20

/turf/open/liquid/lava
	name = "lava"
	icon = 'icons/turf/lava.dmi'
	icon_state = "full"
	light_system = STATIC_LIGHT //theres a lot of lava, dont change this
	light_range = 2
	light_power = 1.4
	light_color = LIGHT_COLOR_LAVA
	minimap_color = MINIMAP_LAVA

/turf/open/liquid/lava/is_weedable()
	return FALSE

/turf/open/liquid/lava/Initialize(mapload)
	. = ..()
	var/turf/current_turf = get_turf(src)
	if(current_turf && density)
		current_turf.flags_atom |= AI_BLOCKED

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

/turf/open/liquid/lava/proc/burn_stuff(AM)
	. = FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(ismecha(thing))
			var/obj/vehicle/sealed/mecha/burned_mech = thing
			burned_mech.take_damage(rand(40, 120), BURN)
			. = TRUE

		else if(isobj(thing))
			var/obj/O = thing
			O.fire_act(10000, 1000)

		else if (isliving(thing))
			var/mob/living/L = thing

			if(L.stat == DEAD)
				continue

			if(!L.on_fire || L.getFireLoss() <= 200)
				var/damage_amount = max(L.modify_by_armor(LAVA_TILE_BURN_DAMAGE, FIRE), LAVA_TILE_BURN_DAMAGE * 0.3) //snowflakey interaction to stop complete lava immunity
				L.take_overall_damage(damage_amount, BURN, updating_health = TRUE)
				if(!CHECK_BITFIELD(L.flags_pass, PASSFIRE))//Pass fire allow to cross lava without igniting
					L.adjust_fire_stacks(20)
					L.IgniteMob()
				. = TRUE

/turf/open/liquid/lava/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/turf/open/lavaland/catwalk/H = locate(/turf/open/lavaland/catwalk, src)
		if(H)
			to_chat(user, span_warning("There is already a catwalk here!"))
			return
		if(!do_after(user, 5 SECONDS, FALSE))
			to_chat(user, span_warning("It takes time to construct a catwalk!"))
			return
		if(R.use(4))
			to_chat(user, span_notice("You construct a heatproof catwalk."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			ChangeTurf(/turf/open/lavaland/catwalk/built)
			var/turf/current_turf = get_turf(src)
			if(current_turf && density)
				current_turf.flags_atom &= ~AI_BLOCKED
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
