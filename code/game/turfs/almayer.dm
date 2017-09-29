//-----USS Almayer Turfs ---//

/turf/simulated/wall/almayer
	name = "hull"
	desc = "A huge chunk of metal used to seperate rooms and make up the ship."
	icon = 'icons/turf/almayer.dmi'
	icon_state = "testwall0"
	walltype = "testwall"

	damage = 0
	damage_cap = 10000 //Wall will break down to girders if damage reaches this point

	max_temperature = 18000 //K, walls will take damage if they're next to a fire hotter than this

	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

/turf/simulated/wall/almayer/handle_icon_junction(junction)
	if (!walltype)
		return
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
	//icon_state = "testwall0_debug" //Uncomment to check hull in the map editor.
	walltype = "testwall"
	hull = 1 //Impossible to destroy or even damage. Used for outer walls that would breach into space, potentially some special walls

/turf/simulated/wall/almayer/white
	walltype = "wwall"
	icon_state = "wwall0"

/turf/simulated/wall/almayer/white/handle_icon_junction(junction)
	icon_state = "[walltype][junction]"


/turf/simulated/shuttle/wall/dropship1
	name = "\improper Alamo"
	icon = 'icons/turf/dropship.dmi'
	icon_state = "1"

/turf/simulated/shuttle/wall/dropship1/transparent
	opacity = 0

/turf/simulated/shuttle/wall/dropship2
	name = "\improper Normandy"
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "1"

/turf/simulated/shuttle/wall/dropship2/transparent
	opacity = 0

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
	icon_state = "plating_catwalk"
	var/base_state = "plating" //Post mapping
	name = "catwalk"
	desc = "Cats really don't like these things."
	var/covered = 1 //1 for theres the cover, 0 if there isn't.

	New()
		..()
		icon_state = base_state
		update_turf_overlay()

/turf/simulated/floor/almayer/plating/catwalk/proc/update_turf_overlay()
	var/image/reusable/I = rnew(/image/reusable, list('icons/turf/almayer.dmi', src, "catwalk", CATWALK_LAYER))
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



//Outerhull

/turf/unsimulated/floor/almayer_hull
	icon = 'icons/turf/almayer.dmi'
	icon_state = "outerhull"
	name = "hull"
	oxygen = 0.00
	nitrogen = 0.00
	temperature = TCMB

//Others
/turf/simulated/floor/almayer/uscm
	icon_state = "logo_c"
	name = "\improper USCM Logo"

/turf/simulated/floor/almayer/uscm/directional
	icon_state = "logo_directional"



// RESEARCH STUFF
/turf/simulated/floor/almayer/research/containment/entrance
	icon_state = "containment_entrance"

/turf/simulated/floor/almayer/research/containment/floor1
	icon_state = "containment_floor_1"

/turf/simulated/floor/almayer/research/containment/floor2
	icon_state = "containment_floor_2"

/turf/simulated/floor/almayer/research/containment/corner
	icon_state = "containment_corner"

/turf/simulated/floor/almayer/research/containment/corner1
	icon_state = "containment_corner_1"

/turf/simulated/floor/almayer/research/containment/corner2
	icon_state = "containment_corner_2"

/turf/simulated/floor/almayer/research/containment/corner3
	icon_state = "containment_corner_3"

/turf/simulated/floor/almayer/research/containment/corner_var1
	icon_state = "containment_corner_variant_1"

/turf/simulated/floor/almayer/research/containment/corner_var2
	icon_state = "containment_corner_variant_2"

/turf/simulated/wall/almayer/research/containment/wall
	name = "cell wall"
	tiles_with = null
	walltype = null

/turf/simulated/wall/almayer/research/containment/wall/corner
	icon_state = "containment_wall_corner"

/turf/simulated/wall/almayer/research/containment/wall/divide
	icon_state = "containment_wall_divide"

/turf/simulated/wall/almayer/research/containment/wall/south
	icon_state = "containment_wall_south"

/turf/simulated/wall/almayer/research/containment/wall/west
	icon_state = "containment_wall_w"

/turf/simulated/wall/almayer/research/containment/wall/connect_e
	icon_state = "containment_wall_connect_e"

/turf/simulated/wall/almayer/research/containment/wall/connect3
	icon_state = "containment_wall_connect3"

/turf/simulated/wall/almayer/research/containment/wall/connect_w
	icon_state = "containment_wall_connect_w"

/turf/simulated/wall/almayer/research/containment/wall/connect_w2
	icon_state = "containment_wall_connect_w2"

/turf/simulated/wall/almayer/research/containment/wall/east
	icon_state = "containment_wall_e"

/turf/simulated/wall/almayer/research/containment/wall/north
	icon_state = "containment_wall_n"

/turf/simulated/wall/almayer/research/containment/wall/connect_e2
	name = "\improper cell wall."
	icon_state = "containment_wall_connect_e2"

/turf/simulated/wall/almayer/research/containment/wall/connect_s1
	icon_state = "containment_wall_connect_s1"

/turf/simulated/wall/almayer/research/containment/wall/connect_s2
	icon_state = "containment_wall_connect_s2"

/turf/simulated/wall/almayer/research/containment/wall/purple
	name = "cell window"
	icon_state = "containment_window"
	opacity = 0