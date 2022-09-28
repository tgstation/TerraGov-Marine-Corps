#define LAVA_TILE_BURN_DAMAGE 20

//turfs with density = FALSE
/turf/open
	plane = FLOOR_PLANE
	var/allow_construction = TRUE //whether you can build things like barricades on this turf.
	var/slayer = 0 //snow layer
	var/wet = 0 //whether the turf is wet (only used by floors).
	var/has_catwalk = FALSE
	var/shoefootstep = FOOTSTEP_FLOOR
	var/barefootstep = FOOTSTEP_HARD
	var/mediumxenofootstep = FOOTSTEP_HARD
	var/heavyxenofootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs) //todo refactor this entire proc is garbage
	if(iscarbon(arrived))
		var/mob/living/carbon/C = arrived
		if(!C.lying_angle && !(C.buckled && istype(C.buckled,/obj/structure/bed/chair)))
			if(ishuman(C))
				var/mob/living/carbon/human/H = C

				// Tracking blood
				var/list/bloodDNA = null
				var/bloodcolor=""
				if(H.shoes)
					var/obj/item/clothing/shoes/S = H.shoes
					if(S.track_blood && S.blood_overlay)
						bloodcolor=S.blood_color
						S.track_blood--
				else
					if(H.track_blood && H.feet_blood_color)
						bloodcolor=H.feet_blood_color
						H.track_blood--

				if (bloodDNA && !locate(/obj/structure) in contents)
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,H.dir,0,bloodcolor) // Coming
					var/turf/from = get_step(H,REVERSE_DIR(H.dir))
					if(istype(from) && from)
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,0,H.dir,bloodcolor) // Going

					bloodDNA = null


			switch (wet)
				if(FLOOR_WET_WATER)
					if(!C.slip(null, 5, 3, TRUE))
						C.inertia_dir = 0

				if(FLOOR_WET_LUBE) //lube
					if(C.slip(null, 10, 10, FALSE, TRUE, 4))
						C.take_limb_damage(2)

				if(FLOOR_WET_ICE) // Ice
					if(!C.slip("icy floor", 4, 3, FALSE, TRUE, 1))
						C.inertia_dir = 0


	..()




/turf/open/examine(mob/user)
	. = ..()
	. += ceiling_desc()

/turf/open/river
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER


// Beach

/turf/open/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND

/turf/open/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/open/beach/coastline
	name = "coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/open/beach/water
	name = "water"
	icon_state = "water"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER

/turf/open/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water2","layer"=MOB_LAYER+0.1)

/obj/effect/beach_overlay
	name = "beach_overlay"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = RIVER_OVERLAY_LAYER
	plane = FLOOR_PLANE

/turf/open/beach/water/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(has_catwalk)
		return
	if(iscarbon(arrived))
		var/mob/living/carbon/C = arrived
		var/beachwater_slowdown = 1.75

		if(ishuman(C))
			var/mob/living/carbon/human/H = arrived
			cleanup(H)

		else if(isxeno(C))
			if(!isxenoboiler(C))
				beachwater_slowdown = 1.3
			else
				beachwater_slowdown = -0.5

		if(C.on_fire)
			C.ExtinguishMob()

		C.next_move_slowdown += beachwater_slowdown


/turf/open/beach/water/proc/cleanup(mob/living/carbon/human/H)
	if(H.back?.clean_blood())
		H.update_inv_back()
	if(H.wear_suit?.clean_blood())
		H.update_inv_wear_suit()
	if(H.w_uniform?.clean_blood())
		H.update_inv_w_uniform()
	if(H.gloves?.clean_blood())
		H.update_inv_gloves()
	if(H.shoes?.clean_blood())
		H.update_inv_shoes()
	H.clean_blood()

/turf/open/beach/water2
	name = "water"
	icon_state = "water"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER

/turf/open/beach/water2/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

/turf/open/beach/sea
	name = "sea"
	icon_state = "seadeep"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER

//Nostromo turfs

/turf/open/nostromowater
	name = "ocean"
	desc = "Its a long way down to the ocean from here."
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "seadeep"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER

//SHUTTLE 'FLOORS'
//not a child of turf/open/floor because shuttle floors are magic and don't behave like real floors.

/turf/open/shuttle
	name = "floor"
	icon_state = "floor"
	icon = 'icons/turf/shuttle.dmi'
	allow_construction = FALSE
	shoefootstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD
	mediumxenofootstep = FOOTSTEP_PLATING
	smoothing_behavior = NO_SMOOTHING


/turf/open/shuttle/check_alien_construction(mob/living/builder, silent = FALSE, planned_building)
	if(ispath(planned_building, /turf/closed/wall/)) // Shuttles move and will leave holes in the floor during transit
		if(!silent)
			to_chat(builder, span_warning("This place seems unable to support a wall."))
		return FALSE
	return ..()

/turf/open/shuttle/blackfloor
	icon_state = "floor7"

/turf/open/shuttle/dropship
	name = "floor"
	icon_state = "rasputin1"

/turf/open/shuttle/dropship/two
	icon_state = "rasputin2"

/turf/open/shuttle/dropship/three
	icon_state = "rasputin3"

/turf/open/shuttle/dropship/four
	icon_state = "rasputin4"

/turf/open/shuttle/dropship/five
	icon_state = "rasputin5"

/turf/open/shuttle/dropship/six
	icon_state = "rasputin6"

/turf/open/shuttle/dropship/seven
	icon_state = "rasputin7"

/turf/open/shuttle/dropship/eight
	icon_state = "rasputin8"

/turf/open/shuttle/dropship/nine
	icon_state = "rasputin9"

/turf/open/shuttle/dropship/ten
	icon_state = "rasputin10"

/turf/open/shuttle/dropship/eleven
	icon_state = "rasputin11"

/turf/open/shuttle/dropship/twelve
	icon_state = "rasputin12"

/turf/open/shuttle/dropship/thirteen
	icon_state = "rasputin13"

/turf/open/shuttle/dropship/fourteen
	icon_state = "floor6"

/turf/open/shuttle/dropship/grating
	icon = 'icons/turf/elevator.dmi'
	icon_state = "floor_grating"

//not really plating, just the look
/turf/open/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/open/floor/plating/heatinggrate
	icon_state = "heatinggrate"

/turf/open/shuttle/brig // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/open/shuttle/escapepod
	icon = 'icons/turf/escapepods.dmi'
	icon_state = "floor3"

/turf/open/shuttle/escapepod/plain
	icon_state = "floor1"

/turf/open/shuttle/escapepod/zero
	icon_state = "floor0"

/turf/open/shuttle/escapepod/two
	icon_state = "floor2"

/turf/open/shuttle/escapepod/four
	icon_state = "floor4"

/turf/open/shuttle/escapepod/five
	icon_state = "floor5"

/turf/open/shuttle/escapepod/six
	icon_state = "floor6"

/turf/open/shuttle/escapepod/seven
	icon_state = "floor7"

/turf/open/shuttle/escapepod/eight
	icon_state = "floor8"

/turf/open/shuttle/escapepod/nine
	icon_state = "floor9"

/turf/open/shuttle/escapepod/ten
	icon_state = "floor10"

/turf/open/shuttle/escapepod/eleven
	icon_state = "floor11"

/turf/open/shuttle/escapepod/twelve
	icon_state = "floor12"

// Elevator floors
/turf/open/shuttle/elevator
	icon = 'icons/turf/elevator.dmi'
	icon_state = "floor"

/turf/open/shuttle/elevator/grating
	icon_state = "floor_grating"

// LAVA

/turf/open/lavaland
	icon = 'icons/turf/lava.dmi'
	plane = FLOOR_PLANE
	baseturfs = /turf/open/lavaland/lava


/turf/open/lavaland/lava
	name = "lava"
	icon_state = "full"
	light_system = STATIC_LIGHT //theres a lot of lava, dont change this
	light_range = 2
	light_power = 1.4
	light_color = LIGHT_COLOR_LAVA

/turf/open/lavaland/lava/is_weedable()
	return FALSE

/turf/open/lavaland/lava/corner
	icon_state = "corner"

/turf/open/lavaland/lava/side
	icon_state = "side"

/turf/open/lavaland/lava/lpiece
	icon_state = "lpiece"

/turf/open/lavaland/lava/single/
	icon_state = "single"

/turf/open/lavaland/lava/single/intersection
	icon_state = "single_intersection"

/turf/open/lavaland/lava/single_intersection/direction
	icon_state = "single_intersection_direction"

/turf/open/lavaland/lava/single/middle
	icon_state = "single_middle"

/turf/open/lavaland/lava/single/end
	icon_state = "single_end"

/turf/open/lavaland/lava/single/corners
	icon_state = "single_corners"

/turf/open/lavaland/lava/Initialize()
	. = ..()
	var/turf/current_turf = get_turf(src)
	if(current_turf && density)
		current_turf.flags_atom |= AI_BLOCKED

/turf/open/lavaland/lava/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(burn_stuff(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/lavaland/lava/Exited(atom/movable/leaver, direction)
	. = ..()
	if(isliving(leaver))
		var/mob/living/L = leaver
		if(!islava(get_step(src, direction)) && !L.on_fire)
			L.update_fire()

/turf/open/lavaland/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSobj, src)

/turf/open/lavaland/lava/proc/burn_stuff(AM)
	. = 0

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			O.fire_act(10000, 1000)

		else if (isliving(thing))
			var/mob/living/L = thing

			if(L.stat == DEAD)
				continue

			if(!L.on_fire || L.getFireLoss() <= 200)
				L.take_overall_damage(0, LAVA_TILE_BURN_DAMAGE * clamp(L.get_fire_resist(), 0.2, 1), updating_health = TRUE)
				if(!CHECK_BITFIELD(L.flags_pass, PASSFIRE))//Pass fire allow to cross lava without igniting
					L.adjust_fire_stacks(20)
					L.IgniteMob()
				. = 1

/turf/open/lavaland/lava/attackby(obj/item/C, mob/user, params)
	..()
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

/turf/open/lavaland/basalt
	name = "basalt"
	icon_state = "basalt"
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND

/turf/open/lavaland/basalt/cave
	name = "cave"
	icon_state = "basalt_to_cave"

/turf/open/lavaland/basalt/cave/corner
	name = "cave"
	icon_state = "basalt_to_cave_corner"

/turf/open/lavaland/basalt/dirt
	name = "dirt"
	icon_state = "basalt_to_dirt"

/turf/open/lavaland/basalt/dirt/corner
	name = "dirt"
	icon_state = "basalt_to_dirt_corner"

/turf/open/lavaland/basalt/glowing
	icon_state = "basaltglow"
	light_system = STATIC_LIGHT
	light_range = 4
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA

/turf/open/lavaland/catwalk
	name = "catwalk"
	icon_state = "lavacatwalk"
	light_system = STATIC_LIGHT
	light_range = 1.4
	light_power = 2
	light_color = LIGHT_COLOR_LAVA
	shoefootstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	mediumxenofootstep = FOOTSTEP_CATWALK

/turf/open/lavaland/catwalk/built
	var/deconstructing = FALSE

/turf/open/lavaland/catwalk/built/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return
	if(X.a_intent != INTENT_HARM)
		return
	if(deconstructing)
		return
	deconstructing = TRUE
	if(!do_after(X, 10 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		deconstructing = FALSE
		return
	deconstructing = FALSE
	playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
	var/turf/current_turf = get_turf(src)
	if(current_turf)
		current_turf.flags_atom |= AI_BLOCKED
	ChangeTurf(/turf/open/lavaland/lava)
