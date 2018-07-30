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
			cdel(src)

		if("JoinLate")
			latejoin += loc
			cdel(src)

		if("JoinLateGateway")
			latejoin_gateway += loc
			cdel(src)

		if("JoinLateCryo")
			latejoin_cryo += loc
			cdel(src)

		if("SupplyElevator")
			SupplyElevator = loc
			cdel(src)

		if("HangarUpperElevator")
			HangarUpperElevator = loc
			cdel(src)

		if("HangarLowerElevator")
			HangarLowerElevator = loc
			cdel(src)

		//prisoners
		if("prisonwarp")
			prisonwarp += loc
			cdel(src)

		if("Holding Facility")
			holdingfacility += loc
			cdel(src)

		if("tdome1")
			tdome1	+= loc
			cdel(src)

		if("tdome2")
			tdome2 += loc
			cdel(src)

		if("tdomeadmin")
			tdomeadmin	+= loc
			cdel(src)

		if("tdomeobserve")
			tdomeobserve += loc
			cdel(src)

		//not prisoners
		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			cdel(src)

		if("blobstart")
			blobstart += loc
			cdel(src)

		if("xeno_spawn")
			xeno_spawn += loc
			cdel(src)

		if("surv_spawn")
			surv_spawn += loc
			cdel(src)

		if("pred_spawn")
			pred_spawn += loc
			cdel(src)

		if("pred_elder_spawn")
			pred_elder_spawn += loc
			cdel(src)

		if("yautja_teleport_loc")
			yautja_teleport_loc += loc
			cdel(src)


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
	cdel(src)
	return
