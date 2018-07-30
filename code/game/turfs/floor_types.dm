



//Floors

/turf/open/floor/almayer
	icon = 'icons/turf/almayer.dmi'
	icon_state = "default"




/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_tile = null
	intact_tile = 0

/turf/open/floor/plating/almayer
	icon = 'icons/turf/almayer.dmi'

/turf/open/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"

	New()
		..()
		name = "plating"

/turf/open/floor/plating/icefloor
	icon_state = "plating"
	name = "ice colony plating"

	New()
		..()
		name = "plating"

/turf/open/floor/plating/plating_catwalk
	icon = 'icons/turf/almayer.dmi'
	icon_state = "plating_catwalk"
	var/base_state = "plating" //Post mapping
	name = "catwalk"
	desc = "Cats really don't like these things."
	var/covered = 1 //1 for theres the cover, 0 if there isn't.

	New()
		..()
		icon_state = base_state
		update_turf_overlay()

/turf/open/floor/plating/plating_catwalk/proc/update_turf_overlay()
	var/image/reusable/I = rnew(/image/reusable, list(icon, src, "catwalk", CATWALK_LAYER))
	switch(covered)
		if(0)
			overlays -= I
			cdel(I)
		if(1) overlays += I

/turf/open/floor/plating/plating_catwalk/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/tool/crowbar))
		if(covered)
			var/obj/item/stack/catwalk/R = new(usr.loc)
			R.add_to_stacks(usr)
			covered = 0
			update_turf_overlay()
			return
	if(istype(W, /obj/item/stack/catwalk))
		if(!covered)
			var/obj/item/stack/catwalk/E = W
			E.use(1)
			covered = 1
			update_turf_overlay()
			return
	..()


/turf/open/floor/plating/plating_catwalk/prison
	icon = 'icons/turf/prison.dmi'



/turf/open/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"



/turf/open/floor/plating/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Cats really don't like these things."









//Cargo elevator
/turf/open/floor/almayer/empty
	name = "empty space"
	desc = "There seems to be an awful lot of machinery down below"
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"

/turf/open/floor/almayer/empty/is_weedable()
	return FALSE

/turf/open/floor/almayer/empty/ex_act(severity) //Should make it indestructable
	return

/turf/open/floor/almayer/empty/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/floor/almayer/empty/attackby() //This should fix everything else. No cables, etc
	return

/turf/open/floor/almayer/empty/Entered(var/atom/movable/AM)
	..()
	spawn(2)
		if(AM.throwing == 0 && istype(get_turf(AM), /turf/open/floor/almayer/empty))
			AM.visible_message("<span class='warning'>[AM] falls into the depths!</span>", "<span class='warning'>You fall into the depths!</span>")
			if(get_area(src) == get_area(get_turf(HangarUpperElevator)))
				var/list/droppoints = list()
				for(var/turf/TL in get_area(get_turf(HangarLowerElevator)))
					droppoints += TL
				AM.forceMove(pick(droppoints))
				if(ishuman(AM))
					var/mob/living/carbon/human/human = AM
					human.take_overall_damage(50, 0, "Blunt Trauma")
					human.KnockDown(2)
				for(var/mob/living/carbon/human/landedon in AM.loc)
					if(AM == landedon)
						continue
					landedon.KnockDown(3)
					landedon.take_overall_damage(50, 0, "Blunt Trauma")
				if(isXeno(AM))
					var/list/L = orange(rand(2,4))		// Not actually the fruit
					for (var/mob/living/carbon/human/H in L)
						H.KnockDown(3)
						H.take_overall_damage(10, 0, "Blunt Trauma")
				playsound(AM.loc, 'sound/effects/bang.ogg', 10, 0)
			else
				for(var/obj/structure/disposaloutlet/retrieval/R in structure_list)
					if(R.z != src.z)	continue
					var/obj/structure/disposalholder/H = new()
					AM.loc = H
					sleep(10)
					H.loc = R
					for(var/mob/living/M in H)
						M.take_overall_damage(100, 0, "Blunt Trauma")
					sleep(20)
					for(var/mob/living/M in H)
						M.take_overall_damage(20, 0, "Blunt Trauma")
					for(var/obj/effect/decal/cleanable/C in contents) //get rid of blood
						cdel(C)
					R.expel(H)
					return

				cdel(AM)

		else
			for(var/obj/effect/decal/cleanable/C in contents) //for the off chance of someone bleeding mid=flight
				cdel(C)


//Others
/turf/open/floor/almayer/uscm
	icon_state = "logo_c"
	name = "\improper USCM Logo"

/turf/open/floor/almayer/uscm/directional
	icon_state = "logo_directional"



// RESEARCH STUFF
/turf/open/floor/almayer/research/containment/entrance
	icon_state = "containment_entrance"

/turf/open/floor/almayer/research/containment/floor1
	icon_state = "containment_floor_1"

/turf/open/floor/almayer/research/containment/floor2
	icon_state = "containment_floor_2"

/turf/open/floor/almayer/research/containment/corner
	icon_state = "containment_corner"

/turf/open/floor/almayer/research/containment/corner1
	icon_state = "containment_corner_1"

/turf/open/floor/almayer/research/containment/corner2
	icon_state = "containment_corner_2"

/turf/open/floor/almayer/research/containment/corner3
	icon_state = "containment_corner_3"

/turf/open/floor/almayer/research/containment/corner4
	icon_state = "containment_corner_4"

/turf/open/floor/almayer/research/containment/corner_var1
	icon_state = "containment_corner_variant_1"

/turf/open/floor/almayer/research/containment/corner_var2
	icon_state = "containment_corner_variant_2"






//Outerhull

/turf/open/floor/almayer_hull
	icon = 'icons/turf/almayer.dmi'
	icon_state = "outerhull"
	name = "hull"
	hull_floor = TRUE








//////////////////////////////////////////////////////////////////////





/turf/open/floor/airless
	icon_state = "floor"
	name = "airless floor"

	New()
		..()
		name = "floor"

/turf/open/floor/icefloor
	icon_state = "floor"
	name = "ice colony floor"

	New()
		..()
		name = "floor"


/turf/open/floor/light
	name = "Light floor"
	luminosity = 5
	icon_state = "light_on"
	floor_tile = new/obj/item/stack/tile/light

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		var/n = name //just in case commands rename it in the ..() call
		..()
		spawn(4)
			if(src)
				update_icon()
				name = n


/turf/open/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_tile = new/obj/item/stack/tile/wood

/turf/open/floor/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"



/turf/open/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	intact_tile = 0
	breakable_tile = FALSE
	burnable_tile = FALSE

/turf/open/floor/engine/make_plating()
	return

/turf/open/floor/engine/attackby(obj/item/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/tool/wrench))
		user.visible_message("<span class='notice'>[user] starts removing [src]'s protective cover.</span>",
		"<span class='notice'>You start removing [src]'s protective cover.</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 25, 1)
		if(do_after(user, 30, TRUE, 5, BUSY_ICON_BUILD))
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/open/floor)
			var/turf/open/floor/F = src
			F.make_plating()


/turf/open/floor/engine/ex_act(severity)
	switch(severity)
		if(1)
			break_tile_to_plating()
		if(2)
			if(prob(25))
				break_tile_to_plating()


/turf/open/floor/engine/nitrogen

/turf/open/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"


/turf/open/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"


/turf/open/floor/engine/mars/exterior
	name = "floor"
	icon_state = "ironsand1"





/turf/open/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/open/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"


/turf/open/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/open/floor))
						var/turf/open/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/turf/open/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	floor_tile = new/obj/item/stack/tile/carpet

	New()
		floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
		if(!icon_state)
			icon_state = "carpet"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in list(1,2,4,8,5,6,9,10))
					if(istype(get_step(src,direction),/turf/open/floor))
						var/turf/open/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

// Start Prison tiles

/turf/open/floor/prison
	icon = 'icons/turf/prison.dmi'
	icon_state = "floor"

/turf/open/floor/prison/trim/red
	icon_state = "darkred2"








////// Mechbay /////////////////:


/turf/open/floor/mech_bay_recharge_floor
	name = "Mech Bay Recharge Station"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"
	var/obj/machinery/mech_bay_recharge_port/recharge_port
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/obj/mecha/recharging_mecha = null

/turf/open/floor/mech_bay_recharge_floor/Entered(var/obj/mecha/mecha)
	. = ..()
	if(istype(mecha))
		mecha.occupant_message("<b>Initializing power control devices.</b>")
		init_devices()
		if(recharge_console && recharge_port)
			recharging_mecha = mecha
			recharge_console.mecha_in(mecha)
			return
		else if(!recharge_console)
			mecha.occupant_message("<font color='red'>Control console not found. Terminating.</font>")
		else if(!recharge_port)
			mecha.occupant_message("<font color='red'>Power port not found. Terminating.</font>")
	return

/turf/open/floor/mech_bay_recharge_floor/Exited(atom)
	. = ..()
	if(atom == recharging_mecha)
		recharging_mecha = null
		if(recharge_console)
			recharge_console.mecha_out()
	return

/turf/open/floor/mech_bay_recharge_floor/proc/init_devices()
	if(!recharge_console)
		recharge_console = locate() in range(1,src)
	if(!recharge_port)
		recharge_port = locate() in get_step(src, WEST)

	if(recharge_console)
		recharge_console.recharge_floor = src
		if(recharge_port)
			recharge_console.recharge_port = recharge_port
	if(recharge_port)
		recharge_port.recharge_floor = src
		if(recharge_console)
			recharge_port.recharge_console = recharge_console
	return

// temporary fix for broken icon until somebody gets around to make these player-buildable
/turf/open/floor/mech_bay_recharge_floor/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(floor_tile)
		icon_state = "recharge_floor"
	else
		icon_state = "support_lattice"


/turf/open/floor/mech_bay_recharge_floor/break_tile()
	if(broken) return
	ChangeTurf(/turf/open/floor/plating)
	broken = TRUE
