//-----USS Almayer Turfs ---//

// alls

/turf/simulated/wall/almayer
	name = "hull"
	desc = "A huge chunk of metal used to seperate rooms and make up the ship."
	icon = 'icons/turf/almayer.dmi'
	icon_state = "testwall0"
//	mineral = "silver"
	walltype = "testwall"
	hull = 1 //1 = Can't be deconstructed by tools or thermite. Used for Sulaco walls

	damage = 0
	damage_cap = 10000 //Wall will break down to girders if damage reaches this point

	max_temperature = 18000 //K, walls will take damage if they're next to a fire hotter than this

	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

/turf/simulated/wall/almayer/handle_icon_junction(junction)
	//lets make some detailed randomized shit happen.
	var/r1 = rand(0,10) //Make a random chance for this to happen
	var/r2 = rand(0,3) // Which wall if we do choose it
	if(junction == 12)
		switch(r1)
			if(0 to 8)
				icon_state = "[walltype]12"
			if(9 to 10)
				icon_state = "almayer_deco_wall[r2]"
	else
		icon_state = "[walltype][junction]"

/turf/simulated/wall/almayer/outer
	name = "outer hull"
	desc = "A huge chunk of metal used to seperate space from the ship"
	icon_state = "testwall0"
	walltype = "testwall"
//	mineral = "testwall"
//	unacidable = 1

/turf/simulated/wall/almayer/white
	walltype = "wwall"
	icon_state = "wwall0"

/turf/simulated/wall/almayer/white/handle_icon_junction(junction)
	icon_state = "[walltype][junction]"

/obj/effect/decal/wall_transition
	icon = 'icons/turf/almayer.dmi'
	icon_state = "transition_s"
	layer = 2

/obj/effect/decal/wall_transition/New()
	. = ..()

	loc.overlays += src
	del src

/turf/simulated/shuttle/wall/dropship1
	name = "wall"
	icon = 'icons/turf/dropship.dmi'
	icon_state = "1"

/turf/simulated/shuttle/wall/escapepod
	name = "wall"
	icon = 'icons/turf/escapepods.dmi'
	icon_state = "wall0"

/turf/simulated/shuttle/floor/escapepod
	icon = 'icons/turf/escapepods.dmi'
	icon_state = "floor3"

//Floors

/turf/simulated/floor/almayer
	icon = 'icons/turf/almayer.dmi'
	icon_state = "default"

/turf/simulated/floor/almayer/plating
	name = "plating"
	icon_state = "plating"
	floor_tile = null
	intact = 0

/turf/simulated/floor/almayer/plating/catwalk
	icon = 'icons/turf/almayer.dmi'
	icon_state = "plating"
	name = "catwalk"
	desc = "Cats really don't like these things."
	var/covered = 1 //1 for theres the cover, 0 if there isn't.

	New()
		..()
		update_turf_overlay()

/turf/simulated/floor/almayer/plating/catwalk/proc/update_turf_overlay()
	var/image/reusable/I = rnew(/image/reusable, list('icons/turf/almayer.dmi',src,"catwalk",2.5))
	switch(covered)
		if(0)
			overlays -= I
			cdel(I)
		if(1) overlays += I

/turf/simulated/floor/almayer/plating/catwalk/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/crowbar))
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

/obj/item/stack/catwalk
	name = "catwalk mesh"
	singular_name = "catwalk mesh"
	desc = "Those could work as a pretty decent throwing weapon"
	icon = 'icons/turf/almayer.dmi'
	icon_state = "catwalk_tile"
	w_class = 3.0
	force = 6.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	flags_atom = FPRINT|CONDUCT
	max_amount = 60

//Outerhull

/turf/unsimulated/floor/almayer_hull
	icon = 'icons/turf/almayer.dmi'
	icon_state = "outerhull"
	name = "hull"
	oxygen = 0.00
	nitrogen = 0.00
	temperature = TCMB

//Others

//------ Grilles -----///

/obj/structure/grille/almayer
	icon = 'icons/turf/almayer.dmi'
	icon_state = "grille0"
	tiles_with = list(
		/turf/simulated/wall,
		/obj/machinery/door/airlock)

/obj/structure/grille/almayer/New()
	spawn(10)
		relativewall()
		relativewall_neighbours()

/obj/structure/grille/almayer/update_icon()
	relativewall()

//------ Windows -----//

/obj/structure/window/reinforced/almayer
	name = "reinforced glass"
	desc = "A very tough looking window, probably bullet proof."
	icon = 'icons/turf/almayer.dmi'
	icon_state = "rwindow0"
	basestate = "rwindow"
	health = 600
	reinf = 1
	dir = 5

	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

/obj/structure/window/reinforced/almayer/New()
	spawn(10)
		relativewall()
		relativewall_neighbours()

/obj/structure/window/reinforced/almayer/update_nearby_icons()
	relativewall_neighbours()

/obj/structure/window/reinforced/almayer/update_icon()
	relativewall()

/obj/structure/window/reinforced/almayer/white
	icon_state = "mwindow0"
	basestate = "mwindow"