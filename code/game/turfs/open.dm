
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

/turf/open/Entered(atom/A, atom/OL)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
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
					var/turf/from = get_step(H,reverse_direction(H.dir))
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
	..()
	ceiling_desc(user)

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

/turf/open/beach/water/Entered(atom/movable/AM)
	. = ..()
	if(has_catwalk)
		return
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		var/beachwater_slowdown = 1.75

		if(ishuman(C))
			var/mob/living/carbon/human/H = AM
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


/turf/open/shuttle/check_alien_construction(mob/living/builder, silent = FALSE, planned_building)
	if(ispath(planned_building, /turf/closed/wall/)) // Shuttles move and will leave holes in the floor during transit
		if(!silent)
			to_chat(builder, "<span class='warning'>This place seems unable to support a wall.</span>")
		return FALSE
	return ..()

/turf/open/shuttle/blackfloor
	icon_state = "floor7"

/turf/open/shuttle/dropship
	name = "floor"
	icon_state = "rasputin1"

/turf/open/shuttle/dropship/three
	icon_state = "rasputin3"

/turf/open/shuttle/dropship/five
	icon_state = "rasputin5"

/turf/open/shuttle/dropship/seven
	icon_state = "rasputin7"

/turf/open/shuttle/dropship/eight
	icon_state = "rasputin8"

//not really plating, just the look
/turf/open/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

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

// Elevator floors
/turf/open/shuttle/elevator
	icon = 'icons/turf/elevator.dmi'
	icon_state = "floor"

/turf/open/shuttle/elevator/grating
	icon_state = "floor_grating"
