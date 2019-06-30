
//turfs with density = FALSE
/turf/open
	plane = FLOOR_PLANE
	var/allow_construction = TRUE //whether you can build things like barricades on this turf.
	var/slayer = 0 //snow layer
	var/wet = 0 //whether the turf is wet (only used by floors).
	var/has_catwalk = FALSE

/turf/open/Entered(atom/A, atom/OL)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C.lying && !(C.buckled && istype(C.buckled,/obj/structure/bed/chair)))
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


// Beach

/turf/open/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'


/turf/open/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/open/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/open/beach/water
	name = "Water"
	icon_state = "water"
	can_bloody = FALSE

/turf/open/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water2","layer"=MOB_LAYER+0.1)

/turf/open/beach/water2
	name = "Water"
	icon_state = "water"
	can_bloody = FALSE

/turf/open/beach/water2/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)


//Nostromo turfs

/turf/open/nostromowater
	name = "ocean"
	desc = "Its a long way down to the ocean from here."
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "seadeep"
	can_bloody = FALSE

//SHUTTLE 'FLOORS'
//not a child of turf/open/floor because shuttle floors are magic and don't behave like real floors.

/turf/open/shuttle
	name = "floor"
	icon_state = "floor"
	icon = 'icons/turf/shuttle.dmi'
	allow_construction = FALSE

/turf/open/shuttle/dropship
	name = "floor"
	icon_state = "rasputin1"


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


// Elevator floors
/turf/open/shuttle/elevator
	icon = 'icons/turf/elevator.dmi'
	icon_state = "floor"

/turf/open/shuttle/elevator/grating
	icon_state = "floor_grating"


