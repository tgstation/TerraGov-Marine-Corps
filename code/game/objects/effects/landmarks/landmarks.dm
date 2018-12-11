/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	unacidable = 1

/obj/effect/landmark/New()

	..()
	tag = "landmark*[name]"
	invisibility = 101

	switch(name)			//some of these are probably obsolete

		if("start")
			newplayer_start += loc
			qdel(src)

		if("JoinLate")
			latejoin += loc
			qdel(src)

		if("JoinLateGateway")
			latejoin_gateway += loc
			qdel(src)

		if("JoinLateCryo")
			latejoin_cryo += loc
			qdel(src)

		if("SupplyElevator")
			SupplyElevator = loc
			qdel(src)

		if("HangarUpperElevator")
			HangarUpperElevator = loc
			qdel(src)

		if("HangarLowerElevator")
			HangarLowerElevator = loc
			qdel(src)

		//prisoners
		if("prisonwarp")
			prisonwarp += loc
			qdel(src)

		if("Holding Facility")
			holdingfacility += loc
			qdel(src)

		if("tdome1")
			tdome1	+= loc
			qdel(src)

		if("tdome2")
			tdome2 += loc
			qdel(src)

		if("tdomeadmin")
			tdomeadmin	+= loc
			qdel(src)

		if("tdomeobserve")
			tdomeobserve += loc
			qdel(src)

		//not prisoners
		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			qdel(src)

		if("blobstart")
			blobstart += loc
			qdel(src)

		if("xeno_spawn")
			xeno_spawn += loc
			qdel(src)

		if("surv_spawn")
			surv_spawn += loc
			qdel(src)

		if("pred_spawn")
			pred_spawn += loc
			qdel(src)

		if("pred_elder_spawn")
			pred_elder_spawn += loc
			qdel(src)

		if("yautja_teleport_loc")
			yautja_teleport_loc += loc
			qdel(src)


	landmarks_list += src
	return 1

/obj/effect/landmark/Dispose()
	landmarks_list -= src
	. = ..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	invisibility = 101

	return 1

/obj/effect/landmark/map_tag
	name = "mapping tag"

/obj/effect/landmark/map_tag/New()
	map_tag = name
	qdel(src)
	return
